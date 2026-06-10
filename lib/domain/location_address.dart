enum OrderDirection { topToBottom, leftToRight, frontToBack }

String formatLocationCode({
  required int wardrobe,
  required int zone,
  required int compartment,
  required int group,
  required int item,
}) {
  String twoDigit(int value) => value.toString().padLeft(2, '0');

  return 'W${twoDigit(wardrobe)}-Z${twoDigit(zone)}-C${twoDigit(compartment)}-G${twoDigit(group)}-I${twoDigit(item)}';
}

String _directionLabel(OrderDirection orderDirection, int orderIndex) {
  return switch (orderDirection) {
    OrderDirection.leftToRight => '从左到右第 $orderIndex 件',
    OrderDirection.frontToBack => '从前往后第 $orderIndex 件',
    OrderDirection.topToBottom => '从上往下第 $orderIndex 件',
  };
}

String formatLocationLabel({
  required String wardrobeName,
  required String zoneName,
  required String compartmentName,
  required String groupName,
  required OrderDirection orderDirection,
  required int orderIndex,
}) {
  return [
    wardrobeName,
    zoneName,
    compartmentName,
    groupName,
    _directionLabel(orderDirection, orderIndex),
  ].join(' / ');
}