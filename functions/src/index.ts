import * as admin from "firebase-admin";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { onSchedule } from "firebase-functions/v2/scheduler";
import {
  BloodProductCode,
  BloodTypeCode,
  containsProhibitedContent,
  isBloodCompatible,
} from "./bloodCompatibility";

admin.initializeApp();

/**
 * KVKK Madde 11 & Unutulma Hakkı:
 * Kullanıcının public profilini, tüm private_data alt koleksiyonlarını,
 * Storage profil fotoğrafını ve Firebase Auth kaydını kalıcı olarak siler.
 */
export const deleteUserAccount = onCall(async (request) => {
  const callerUid = request.auth?.uid;
  if (!callerUid) {
    throw new HttpsError(
      "unauthenticated",
      "Hesap silme işlemi için oturum açmış olmanız gerekir."
    );
  }

  const db = admin.firestore();
  const userDocRef = db.collection("users").doc(callerUid);
  await db.recursiveDelete(userDocRef);

  try {
    const bucket = admin.storage().bucket();
    await bucket.deleteFiles({ prefix: `users/${callerUid}/` });
  } catch (_) {}

  try {
    await admin.auth().deleteUser(callerUid);
  } catch (_) {}

  return { success: true, deletedUid: callerUid };
});

/**
 * Yeni kan talebi oluşturulduğunda:
 * 1. Para/ücret yasaklı kelime kontrolü yapar (ihlalse talebi iptal eder).
 * 2. Uygun (`isAvailableToDonate == true`), son bağış aralığını doldurmuş ve
 *    kan grubu/ürün tipi uyumlu bağışçıları bulur.
 * 3. Sessiz saat ve yarıçap tercihlerine saygı göstererek ilk kademe (dar yarıçap) FCM bildirimi gönderir.
 * Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
 */
export const onBloodRequestCreated = onDocumentCreated(
  "blood_requests/{requestId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const data = snap.data();
    const requestId = event.params.requestId;

    if (
      containsProhibitedContent(data.notes || "") ||
      containsProhibitedContent(data.department || "")
    ) {
      await snap.ref.update({
        status: "cancelled",
        moderationNote: "Prohibited monetary content detected.",
      });
      return;
    }

    const db = admin.firestore();
    const usersSnap = await db
      .collection("users")
      .where("isAvailableToDonate", "==", true)
      .where("province", "==", data.province)
      .get();

    const recipientBlood = data.bloodType as BloodTypeCode;
    const productType = data.productType as BloodProductCode;
    const isCritical = data.urgency === "critical";

    for (const userDoc of usersSnap.docs) {
      if (userDoc.id === data.requesterUid) continue;

      const sensitiveSnap = await userDoc.ref
        .collection("private_data")
        .doc("sensitive_profile")
        .get();
      const donorBlood = (sensitiveSnap.data()?.bloodType ??
        "UNKNOWN") as BloodTypeCode;

      if (!isBloodCompatible(donorBlood, recipientBlood, productType)) {
        continue;
      }

      const prefsSnap = await userDoc.ref
        .collection("private_data")
        .doc("notification_preferences")
        .get();
      const prefs = prefsSnap.data() || {};
      const quietEnabled = Boolean(prefs.quietHoursEnabled);
      const allowCritical = prefs.allowCriticalInQuietHours !== false;

      const currentHour = new Date().getUTCHours();
      if (quietEnabled && (currentHour >= 23 || currentHour < 7)) {
        if (!(isCritical && allowCritical)) continue;
      }

      await userDoc.ref.collection("notifications").add({
        title: `Acil ${recipientBlood} Kan Çağrısı`,
        body: `${data.hospital?.name || data.province} için uyumlu gönüllü aranıyor.`,
        requestId,
        isCritical,
        isRead: false,
        createdAt: new Date().toISOString(),
      });
    }
  }
);

/**
 * Kademeli bildirim ve otomatik süre dolumu (Zamanlanmış Görev):
 * - Süresi (`expiresAt`) geçmiş açık talepleri `expired` durumuna çeker.
 * - Belirli süre yanıt alamamış açık taleplerin bildirim yarıçapını genişletir.
 */
export const expireAndExpandRequests = onSchedule(
  "every 15 minutes",
  async () => {
    const db = admin.firestore();
    const nowIso = new Date().toISOString();

    const expiredSnap = await db
      .collection("blood_requests")
      .where("status", "==", "open")
      .where("expiresAt", "<=", nowIso)
      .get();

    const batch = db.batch();
    for (const doc of expiredSnap.docs) {
      batch.update(doc.ref, { status: "expired" });
    }
    await batch.commit();
  }
);

/**
 * Bağışçı teklif durumu güncellendiğinde:
 * - Talep sahibine ve bağışçıya durum bildirimi yazar.
 * - Durum `confirmed` olduğunda bağışçının `donation_history` alt koleksiyonuna kayıt ekler.
 */
export const onDonationOfferUpdated = onDocumentUpdated(
  "blood_requests/{requestId}/offers/{donorUid}",
  async (event) => {
    const after = event.data?.after.data();
    if (!after) return;

    const { requestId, donorUid } = event.params;
    const db = admin.firestore();

    if (after.status === "confirmed") {
      const reqSnap = await db.collection("blood_requests").doc(requestId).get();
      const reqData = reqSnap.data() || {};
      const nowIso = new Date().toISOString();
      const place =
        reqData.hospital?.name || reqData.province || "Kan Bağışı Merkezi";
      const productType = reqData.productType || "whole_blood";

      const userRef = db.collection("users").doc(donorUid);
      await userRef
        .collection("donation_history")
        .doc(requestId)
        .set({
          requestId,
          donorUid,
          donatedAt: nowIso,
          confirmedAt: nowIso,
          place,
          productType,
          source: "request",
          createdAt: nowIso,
        });

      await userRef.set(
        {
          isAvailableToDonate: false,
          updatedAt: nowIso,
        },
        { merge: true }
      );
      await userRef
        .collection("private_data")
        .doc("donation_status")
        .set(
          {
            autoPaused: true,
            updatedAt: nowIso,
          },
          { merge: true }
        );
    }
  }
);
