function twoDigit(value) {
  return String(value).padStart(2, '0');
}

export function formatLocationCode({ wardrobe, zone, compartment, group, item }) {
  return `W${twoDigit(wardrobe)}-Z${twoDigit(zone)}-C${twoDigit(compartment)}-G${twoDigit(group)}-I${twoDigit(item)}`;
}

function directionLabel(orderDirection, orderIndex) {
  if (orderDirection === 'left_to_right') {
    return `从左到右第 ${orderIndex} 件`;
  }

  if (orderDirection === 'front_to_back') {
    return `从前往后第 ${orderIndex} 件`;
  }

  return `从上往下第 ${orderIndex} 件`;
}

export function formatLocationLabel({
  wardrobeName,
  zoneName,
  compartmentName,
  groupName,
  orderDirection,
  orderIndex,
}) {
  return [
    wardrobeName,
    zoneName,
    compartmentName,
    groupName,
    directionLabel(orderDirection, orderIndex),
  ].join(' / ');
}