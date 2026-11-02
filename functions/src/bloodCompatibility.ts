/**
 * Kan grubu uyumluluk motoru ve yasaklı kelime filtresi (Cloud Functions).
 * Dart (`BloodCompatibilityEngine` & `ProhibitedContentFilter`) ile birebir aynı mantıkta çalışır.
 * Kızılay ve Sağlık Bakanlığı güncel kurallarıyla doğrulanmalıdır.
 */
export type BloodTypeCode =
  | "A+"
  | "A-"
  | "B+"
  | "B-"
  | "AB+"
  | "AB-"
  | "0+"
  | "0-"
  | "UNKNOWN";

export type BloodProductCode =
  | "whole_blood"
  | "erythrocyte"
  | "platelet"
  | "plasma";

function aboGroup(type: BloodTypeCode): string {
  if (type.startsWith("AB")) return "AB";
  if (type.startsWith("A")) return "A";
  if (type.startsWith("B")) return "B";
  if (type.startsWith("0")) return "0";
  return "";
}

function isRhPositive(type: BloodTypeCode): boolean {
  return type.endsWith("+");
}

function isRhCompatibleForCells(
  donor: BloodTypeCode,
  recipient: BloodTypeCode
): boolean {
  if (isRhPositive(donor) && !isRhPositive(recipient)) {
    return false;
  }
  return true;
}

export function isBloodCompatible(
  donor: BloodTypeCode,
  recipient: BloodTypeCode,
  productType: BloodProductCode
): boolean {
  if (donor === "UNKNOWN" || recipient === "UNKNOWN") return false;

  const dAbo = aboGroup(donor);
  const rAbo = aboGroup(recipient);

  switch (productType) {
    case "whole_blood":
      return donor === recipient;
    case "erythrocyte":
      if (!isRhCompatibleForCells(donor, recipient)) return false;
      if (dAbo === "0") return true;
      if (dAbo === "A") return rAbo === "A" || rAbo === "AB";
      if (dAbo === "B") return rAbo === "B" || rAbo === "AB";
      if (dAbo === "AB") return rAbo === "AB";
      return false;
    case "plasma":
      if (dAbo === "AB") return true;
      if (dAbo === "A") return rAbo === "A" || rAbo === "0";
      if (dAbo === "B") return rAbo === "B" || rAbo === "0";
      if (dAbo === "0") return rAbo === "0";
      return false;
    case "platelet":
      return dAbo === rAbo && isRhCompatibleForCells(donor, recipient);
  }
}

const BANNED_KEYWORDS = [
  "para",
  "ücret",
  "ucret",
  "nakit",
  "tl",
  "lira",
  "dolar",
  "euro",
  "iban",
  "ödeme",
  "odeme",
  "satılık",
  "satilik",
  "fiyat",
  "komisyon",
  "bahşiş",
  "bahsis",
  "karşılığında",
  "karsiliginda",
  "maddi",
  "havale",
  "eft",
];

export function containsProhibitedContent(text: string): boolean {
  const normalized = (text || "")
    .trim()
    .replace(/İ/g, "i")
    .replace(/I/g, "ı")
    .toLowerCase();
  if (!normalized) return false;

  if (/\btr\s*\d{2}[\d\s]{10,30}\b/i.test(normalized)) return true;
  if (/(\d+\s*(tl|₺|\$|€|usd|eur|bin\s*tl))/i.test(normalized)) return true;

  const words = normalized.split(/[^a-z0-9çğıöşü]+/).filter(Boolean);
  return words.some((w) => BANNED_KEYWORDS.includes(w));
}
