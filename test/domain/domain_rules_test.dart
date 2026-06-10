import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/domain/location_address.dart';
import 'package:wardrobe_twin/domain/storage_stack.dart';
import 'package:wardrobe_twin/domain/twin_status.dart';

void main() {
  group('Twin status', () {
    test(
      'marks an item as mapped when it has photos and recent confirmation',
      () {
        final result = calculateTwinState(
          evidence: const [
            'main_photo',
            'detail_photo',
            'detail_photo',
            'manual_confirm',
          ],
          daysSinceVerified: 12,
          hasSimilarItems: false,
        );

        expect(result.status, TwinStatus.mapped);
        expect(result.confidence, 70);
      },
    );

    test(
      'marks missing location evidence as missing even when identity is strong',
      () {
        final result = calculateTwinState(
          evidence: const ['main_photo', 'manual_confirm', 'qr_scan'],
          daysSinceVerified: 10,
          hasSimilarItems: false,
          locationState: LocationState.missing,
        );

        expect(result.status, TwinStatus.missing);
        expect(result.confidence, 40);
      },
    );
  });

  group('Location addresses', () {
    test('formats a stacked shelf location label', () {
      final label = formatLocationLabel(
        wardrobeName: '主衣橱',
        zoneName: '左侧第二层',
        compartmentName: '右侧叠放组',
        groupName: '第 2 叠',
        orderDirection: OrderDirection.topToBottom,
        orderIndex: 3,
      );

      expect(label, '主衣橱 / 左侧第二层 / 右侧叠放组 / 第 2 叠 / 从上往下第 3 件');
    });

    test('formats a hanging rod location label', () {
      final label = formatLocationLabel(
        wardrobeName: '主衣橱',
        zoneName: '右侧挂衣区',
        compartmentName: '挂衣杆',
        groupName: '外套段',
        orderDirection: OrderDirection.leftToRight,
        orderIndex: 6,
      );

      expect(label, '主衣橱 / 右侧挂衣区 / 挂衣杆 / 外套段 / 从左到右第 6 件');
    });
  });

  group('Storage stacks', () {
    test('moves a worn item back to the top of a stack', () {
      final result = moveItemToTop(const [
        'grey-hoodie',
        'beige-knit',
        'white-shirt',
        'blue-shirt',
      ], 'white-shirt');

      expect(result, const [
        'white-shirt',
        'grey-hoodie',
        'beige-knit',
        'blue-shirt',
      ]);
    });
  });
}
