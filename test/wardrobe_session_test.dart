import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';

void main() {
  test('restores stored clothes to their original wardrobe node', () {
    final session = WardrobeSession.empty()
        .addItem(
          const StoredWardrobeItem(
            itemId: 'item-black-coat',
            primaryPhotoRef: 'mock://photo/item-black-coat/front',
            name: '黑色外套',
            nodeId: 'W01-R-H01',
            nodeName: '右侧挂衣杆',
            visualSignature: '正面黑色拉链外套照片',
          ),
        )
        .setAuditStatus('W01-R-H01', 'verified');

    final restored = WardrobeSession.fromJson(session.toJson());

    expect(restored.itemsByNode['W01-R-H01'], hasLength(1));
    expect(restored.itemsByNode['W01-R-H01']!.single.itemId, 'item-black-coat');
    expect(
      restored.itemsByNode['W01-R-H01']!.single.primaryPhotoRef,
      'mock://photo/item-black-coat/front',
    );
    expect(restored.itemsByNode['W01-R-H01']!.single.name, '黑色外套');
    expect(restored.itemsByNode['W01-R-H01']!.single.nodeName, '右侧挂衣杆');
    expect(
      restored.itemsByNode['W01-R-H01']!.single.visualSignature,
      '正面黑色拉链外套照片',
    );
    expect(restored.auditStatuses['W01-R-H01'], 'verified');
  });

  test('restores per-item inventory confirmation status', () {
    final session = WardrobeSession.empty().addItem(
      const StoredWardrobeItem(
        name: '黑色外套',
        nodeId: 'W01-R-H01',
        nodeName: '右侧挂衣杆',
        presenceStatus: 'present',
      ),
    );

    final restored = WardrobeSession.fromJson(session.toJson());

    expect(restored.itemsByNode['W01-R-H01']!.single.presenceStatus, 'present');
  });

  test('restores clothing digital twin detail fields', () {
    final session = WardrobeSession.empty().addItem(
      const StoredWardrobeItem(
        itemId: 'item-denim-jacket',
        name: 'denim jacket',
        nodeId: 'W01-R-H01',
        nodeName: 'right hanging rod',
        category: 'jacket',
        color: 'blue',
        material: 'denim',
        brand: 'sample brand',
        size: 'M',
        locationIndex: 3,
        twinStatus: 'mapped',
        lastConfirmedAt: '2026-06-10T09:30:00.000',
      ),
    );

    final restored = WardrobeSession.fromJson(session.toJson());
    final item = restored.itemsByNode['W01-R-H01']!.single;

    expect(item.category, 'jacket');
    expect(item.color, 'blue');
    expect(item.material, 'denim');
    expect(item.brand, 'sample brand');
    expect(item.size, 'M');
    expect(item.locationIndex, 3);
    expect(item.twinStatus, 'mapped');
    expect(item.lastConfirmedAt, '2026-06-10T09:30:00.000');
  });
}
