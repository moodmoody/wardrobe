const PHYSICAL_ANCHORS = new Set(['nfc_scan', 'qr_scan', 'rfid_scan']);

function countEvidence(evidence, value) {
  return evidence.filter((item) => item === value).length;
}

export function calculateTwinState({
  evidence,
  daysSinceVerified,
  hasSimilarItems,
  locationState = 'known',
}) {
  const evidenceList = Array.isArray(evidence) ? evidence : [];
  let confidence = 0;

  if (evidenceList.includes('main_photo')) {
    confidence += 20;
  }

  const detailPhotoCount = countEvidence(evidenceList, 'detail_photo');
  if (detailPhotoCount === 1) {
    confidence += 10;
  } else if (detailPhotoCount >= 2) {
    confidence += 20;
  }

  if (evidenceList.includes('manual_confirm')) {
    confidence += 25;
  }

  if (evidenceList.some((item) => PHYSICAL_ANCHORS.has(item))) {
    confidence += 40;
  }

  if (typeof daysSinceVerified === 'number' && daysSinceVerified <= 30) {
    confidence += 5;
  }

  if (typeof daysSinceVerified === 'number' && daysSinceVerified > 90) {
    confidence -= 10;
  }

  if (hasSimilarItems) {
    confidence -= 10;
  }

  if (locationState === 'missing') {
    confidence -= 50;
  }

  confidence = Math.max(0, Math.min(100, confidence));

  if (locationState === 'missing') {
    return { status: 'missing', confidence };
  }

  if (confidence === 0) {
    return { status: 'unbound', confidence };
  }

  if (evidenceList.some((item) => PHYSICAL_ANCHORS.has(item)) && confidence >= 80) {
    return { status: 'anchored', confidence };
  }

  if (confidence < 50 || (typeof daysSinceVerified === 'number' && daysSinceVerified > 90)) {
    return { status: 'review', confidence };
  }

  return { status: 'mapped', confidence };
}