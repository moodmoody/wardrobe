enum TwinStatus { unbound, mapped, anchored, review, missing }

enum LocationState { known, missing }

class TwinState {
  const TwinState({required this.status, required this.confidence});

  final TwinStatus status;
  final int confidence;
}

const _physicalAnchors = {'nfc_scan', 'qr_scan', 'rfid_scan'};

TwinState calculateTwinState({
  required List<String> evidence,
  required int? daysSinceVerified,
  required bool hasSimilarItems,
  LocationState locationState = LocationState.known,
}) {
  var confidence = 0;

  if (evidence.contains('main_photo')) {
    confidence += 20;
  }

  final detailPhotoCount = evidence.where((item) => item == 'detail_photo').length;
  if (detailPhotoCount == 1) {
    confidence += 10;
  } else if (detailPhotoCount >= 2) {
    confidence += 20;
  }

  if (evidence.contains('manual_confirm')) {
    confidence += 25;
  }

  final hasPhysicalAnchor = evidence.any(_physicalAnchors.contains);
  if (hasPhysicalAnchor) {
    confidence += 40;
  }

  if (daysSinceVerified != null && daysSinceVerified <= 30) {
    confidence += 5;
  }

  if (daysSinceVerified != null && daysSinceVerified > 90) {
    confidence -= 10;
  }

  if (hasSimilarItems) {
    confidence -= 10;
  }

  if (locationState == LocationState.missing) {
    confidence -= 50;
  }

  confidence = confidence.clamp(0, 100);

  if (locationState == LocationState.missing) {
    return TwinState(status: TwinStatus.missing, confidence: confidence);
  }

  if (confidence == 0) {
    return TwinState(status: TwinStatus.unbound, confidence: confidence);
  }

  if (hasPhysicalAnchor && confidence >= 80) {
    return TwinState(status: TwinStatus.anchored, confidence: confidence);
  }

  if (confidence < 50 || (daysSinceVerified != null && daysSinceVerified > 90)) {
    return TwinState(status: TwinStatus.review, confidence: confidence);
  }

  return TwinState(status: TwinStatus.mapped, confidence: confidence);
}