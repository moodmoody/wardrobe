class StoredWardrobeItem {
  const StoredWardrobeItem({
    this.itemId = '',
    required this.name,
    required this.nodeId,
    required this.nodeName,
    this.category = '',
    this.color = '',
    this.material = '',
    this.brand = '',
    this.size = '',
    this.locationIndex = 0,
    this.twinStatus = 'pending',
    this.lastConfirmedAt = '',
    this.visualSignature = '',
    this.primaryPhotoRef = '',
    this.presenceStatus = 'unknown',
  });

  factory StoredWardrobeItem.fromJson(Map<String, Object?> json) {
    return StoredWardrobeItem(
      itemId: json['itemId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nodeId: json['nodeId'] as String? ?? '',
      nodeName: json['nodeName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      material: json['material'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      size: json['size'] as String? ?? '',
      locationIndex: _readInt(json['locationIndex']),
      twinStatus: json['twinStatus'] as String? ?? 'pending',
      lastConfirmedAt: json['lastConfirmedAt'] as String? ?? '',
      visualSignature: json['visualSignature'] as String? ?? '',
      primaryPhotoRef: json['primaryPhotoRef'] as String? ?? '',
      presenceStatus: json['presenceStatus'] as String? ?? 'unknown',
    );
  }

  final String itemId;
  final String name;
  final String nodeId;
  final String nodeName;
  final String category;
  final String color;
  final String material;
  final String brand;
  final String size;
  final int locationIndex;
  final String twinStatus;
  final String lastConfirmedAt;
  final String visualSignature;
  final String primaryPhotoRef;
  final String presenceStatus;

  StoredWardrobeItem copyWith({
    String? itemId,
    String? name,
    String? nodeId,
    String? nodeName,
    String? category,
    String? color,
    String? material,
    String? brand,
    String? size,
    int? locationIndex,
    String? twinStatus,
    String? lastConfirmedAt,
    String? visualSignature,
    String? primaryPhotoRef,
    String? presenceStatus,
  }) {
    return StoredWardrobeItem(
      itemId: itemId ?? this.itemId,
      name: name ?? this.name,
      nodeId: nodeId ?? this.nodeId,
      nodeName: nodeName ?? this.nodeName,
      category: category ?? this.category,
      color: color ?? this.color,
      material: material ?? this.material,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      locationIndex: locationIndex ?? this.locationIndex,
      twinStatus: twinStatus ?? this.twinStatus,
      lastConfirmedAt: lastConfirmedAt ?? this.lastConfirmedAt,
      visualSignature: visualSignature ?? this.visualSignature,
      primaryPhotoRef: primaryPhotoRef ?? this.primaryPhotoRef,
      presenceStatus: presenceStatus ?? this.presenceStatus,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'itemId': itemId,
      'name': name,
      'nodeId': nodeId,
      'nodeName': nodeName,
      'category': category,
      'color': color,
      'material': material,
      'brand': brand,
      'size': size,
      'locationIndex': locationIndex,
      'twinStatus': twinStatus,
      'lastConfirmedAt': lastConfirmedAt,
      'visualSignature': visualSignature,
      'primaryPhotoRef': primaryPhotoRef,
      'presenceStatus': presenceStatus,
    };
  }

  static int _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class WardrobeSession {
  const WardrobeSession({
    required this.itemsByNode,
    required this.auditStatuses,
  });

  factory WardrobeSession.empty() {
    return const WardrobeSession(itemsByNode: {}, auditStatuses: {});
  }

  factory WardrobeSession.fromJson(Map<String, Object?> json) {
    final rawItems = json['itemsByNode'] as Map<String, Object?>? ?? const {};
    final rawStatuses =
        json['auditStatuses'] as Map<String, Object?>? ?? const {};

    return WardrobeSession(
      itemsByNode: rawItems.map((nodeId, value) {
        final items = value is List<Object?>
            ? value
                  .whereType<Map<Object?, Object?>>()
                  .map(
                    (item) => StoredWardrobeItem.fromJson(
                      Map<String, Object?>.from(item),
                    ),
                  )
                  .toList(growable: false)
            : const <StoredWardrobeItem>[];
        return MapEntry(nodeId, items);
      }),
      auditStatuses: rawStatuses.map(
        (nodeId, value) => MapEntry(nodeId, value as String? ?? 'unknown'),
      ),
    );
  }

  final Map<String, List<StoredWardrobeItem>> itemsByNode;
  final Map<String, String> auditStatuses;

  WardrobeSession addItem(StoredWardrobeItem item) {
    final nextItems = _cloneItemsByNode();
    nextItems[item.nodeId] = [...nextItems[item.nodeId] ?? const [], item];
    return WardrobeSession(
      itemsByNode: nextItems,
      auditStatuses: Map.of(auditStatuses),
    );
  }

  WardrobeSession setAuditStatus(String nodeId, String status) {
    return WardrobeSession(
      itemsByNode: _cloneItemsByNode(),
      auditStatuses: {...auditStatuses, nodeId: status},
    );
  }

  Map<String, Object?> toJson() {
    return {
      'itemsByNode': itemsByNode.map(
        (nodeId, items) => MapEntry(
          nodeId,
          items.map((item) => item.toJson()).toList(growable: false),
        ),
      ),
      'auditStatuses': auditStatuses,
    };
  }

  Map<String, List<StoredWardrobeItem>> _cloneItemsByNode() {
    return itemsByNode.map(
      (nodeId, items) => MapEntry(nodeId, List<StoredWardrobeItem>.of(items)),
    );
  }
}
