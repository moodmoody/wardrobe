import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/domain/storage_node.dart';

void main() {
  test('decodes the W01 wardrobe sample node tree', () {
    final file = File('examples/W01-real-wardrobe-storage-nodes.json');
    final model = WardrobeStorageModel.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, Object?>,
    );

    expect(model.wardrobeId, 'W01');
    expect(model.nodes, hasLength(23));
    expect(model.root.name, '主衣橱');
    expect(model.nodeById('W01-R-H01').name, '右侧挂衣杆');
    expect(model.childrenOf('W01-L-S02'), hasLength(3));
  });
}
