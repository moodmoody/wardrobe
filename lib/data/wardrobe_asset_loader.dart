import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:wardrobe_twin/domain/storage_node.dart';

const w01SampleAssetPath = 'examples/W01-real-wardrobe-storage-nodes.json';

Future<WardrobeStorageModel> loadWardrobeStorageModel(
  AssetBundle bundle, {
  String assetPath = w01SampleAssetPath,
}) async {
  final text = await bundle.loadString(assetPath);
  return WardrobeStorageModel.fromJson(jsonDecode(text) as Map<String, Object?>);
}