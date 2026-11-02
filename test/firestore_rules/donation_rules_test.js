/**
 * Türkiye Kan Ağı — Bağış Geçmişi ve Sağlık Anketi (KVKK Özel Nitelikli Veri)
 * Firestore Güvenlik Kuralları Emulator Testleri
 */
const { describe, it, before, after, beforeEach } = require('node:test');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'demo-turkiye-kan-agi-donation';

describe('Firestore Security Rules — donation_history & health_surveys (KVKK Madde 6)', () => {
  let testEnv;

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: fs.readFileSync(
          path.resolve(__dirname, '../../firestore.rules'),
          'utf8',
        ),
      },
    });
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  it('Açık rıza (healthDataConsent == true) olmadan bağış geçmişi ve sağlık anketi yazılamaz', async () => {
    const aliceDb = testEnv.authenticatedContext('alice').firestore();

    await assertFails(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('donation_history')
        .doc('d1')
        .set({
          donatedAt: '2026-10-01T10:00:00.000Z',
          place: 'Kızılay Çankaya',
          productType: 'whole_blood',
          source: 'manual',
          createdAt: '2026-10-01T10:00:00.000Z',
        }),
    );

    await assertFails(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('health_surveys')
        .doc('s1')
        .set({
          completedAt: '2026-10-01T10:00:00.000Z',
          outcome: 'looks_eligible',
          answers: { active_illness: 'no' },
          questionnaireVersion: '1.0.0',
        }),
    );
  });

  it('Açık rıza verildikten sonra kullanıcı yalnızca kendi manuel bağış kaydını ve anketini yazabilir; başkası okuyamaz', async () => {
    const aliceDb = testEnv.authenticatedContext('alice').firestore();
    const bobDb = testEnv.authenticatedContext('bob').firestore();

    await assertSucceeds(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('private_data')
        .doc('consents')
        .set({
          healthDataConsent: true,
          locationConsent: true,
          notificationConsent: true,
          consentedAt: '2026-10-01T09:00:00.000Z',
          policyVersion: '1.0.0',
        }),
    );

    await assertSucceeds(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('donation_history')
        .doc('d1')
        .set({
          donatedAt: '2026-10-01T10:00:00.000Z',
          place: 'Kızılay Çankaya',
          productType: 'whole_blood',
          source: 'manual',
          createdAt: '2026-10-01T10:00:00.000Z',
        }),
    );

    await assertSucceeds(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('health_surveys')
        .doc('s1')
        .set({
          completedAt: '2026-10-01T10:00:00.000Z',
          outcome: 'looks_eligible',
          answers: { active_illness: 'no' },
          questionnaireVersion: '1.0.0',
        }),
    );

    // Başka kullanıcı (bob) alice'in bağış geçmişini ve sağlık anketini OKUYAMAZ
    await assertFails(
      bobDb
        .collection('users')
        .doc('alice')
        .collection('donation_history')
        .doc('d1')
        .get(),
    );

    await assertFails(
      bobDb
        .collection('users')
        .doc('alice')
        .collection('health_surveys')
        .doc('s1')
        .get(),
    );
  });

  it('İstemci source=="request" olan bağış kaydını sahteleyemez ve silemez; manuel kaydı silebilir', async () => {
    const aliceDb = testEnv.authenticatedContext('alice').firestore();

    await assertSucceeds(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('private_data')
        .doc('consents')
        .set({
          healthDataConsent: true,
          locationConsent: true,
          notificationConsent: true,
        }),
    );

    // İstemci doğrudan source == 'request' yazamaz (yalnızca Cloud Function Admin SDK yazar)
    await assertFails(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('donation_history')
        .doc('req-forged')
        .set({
          donatedAt: '2026-10-01T10:00:00.000Z',
          place: 'Hastane',
          productType: 'whole_blood',
          source: 'request',
          createdAt: '2026-10-01T10:00:00.000Z',
        }),
    );

    // Admin (Cloud Function) tarafından yazılmış talep kaydını simüle et
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context
        .firestore()
        .collection('users')
        .doc('alice')
        .collection('donation_history')
        .doc('req-1')
        .set({
          donatedAt: '2026-10-01T10:00:00.000Z',
          place: 'Ankara Şehir Hastanesi',
          productType: 'platelet',
          source: 'request',
          createdAt: '2026-10-01T10:00:00.000Z',
        });
    });

    // İstemci talep akışı kaydını silemez
    await assertFails(
      aliceDb
        .collection('users')
        .doc('alice')
        .collection('donation_history')
        .doc('req-1')
        .delete(),
    );
  });
});
