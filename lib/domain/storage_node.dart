class WardrobeStorageModel {
  const WardrobeStorageModel({
    required this.wardrobeId,
    required this.name,
    required this.templateType,
    required this.nodes,
  });

  factory WardrobeStorageModel.fromJson(Map<String, Object?> json) {
    final rawNodes = json['nodes'];
    if (rawNodes is! List) {
      throw const FormatException('Wardrobe storage model requires a nodes list.');
    }

    return WardrobeStorageModel(
      wardrobeId: json['wardrobe_id'] as String,
      name: json['name'] as String,
      templateType: json['template_type'] as String,
      nodes: rawNodes
          .cast<Map<String, Object?>>()
          .map(StorageNode.fromJson)
          .toList(growable: false),
    );
  }

  final String wardrobeId;
  final String name;
  final String templateType;
  final List<StorageNode> nodes;

  StorageNode get root => nodeById(wardrobeId);

  StorageNode nodeById(String id) {
    return nodes.firstWhere((node) => node.id == id);
  }

  List<StorageNode> childrenOf(String parentId) {
    return nodes.where((node) => node.parentId == parentId).toList(growable: false);
  }
}

class StorageNode {
  const StorageNode({
    required this.id,
    required this.parentId,
    required this.nodeType,
    required this.name,
    required this.orderAxis,
    required this.accessPattern,
    required this.visibility,
    required this.mobility,
    required this.grid,
    required this.needsSorting,
  });

  factory StorageNode.fromJson(Map<String, Object?> json) {
    final rawGrid = json['grid'];

    return StorageNode(
      id: json['id'] as String,
      parentId: json['parent_id'] as String?,
      nodeType: json['node_type'] as String,
      name: json['name'] as String,
      orderAxis: json['order_axis'] as String?,
      accessPattern: json['access_pattern'] as String,
      visibility: json['visibility'] as String,
      mobility: json['mobility'] as String,
      grid: rawGrid is Map<String, Object?> ? StorageGrid.fromJson(rawGrid) : null,
      needsSorting: json['needs_sorting'] == true,
    );
  }

  final String id;
  final String? parentId;
  final String nodeType;
  final String name;
  final String? orderAxis;
  final String accessPattern;
  final String visibility;
  final String mobility;
  final StorageGrid? grid;
  final bool needsSorting;
}

class StorageGrid {
  const StorageGrid({required this.x, required this.y, required this.w, required this.h});

  factory StorageGrid.fromJson(Map<String, Object?> json) {
    return StorageGrid(
      x: json['x'] as int,
      y: json['y'] as int,
      w: json['w'] as int,
      h: json['h'] as int,
    );
  }

  final int x;
  final int y;
  final int w;
  final int h;
}