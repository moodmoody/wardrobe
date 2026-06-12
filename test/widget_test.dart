import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/main.dart';

void main() {
  testWidgets(
    'mobile add flow records photo evidence without exposing raw refs',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const WardrobeTwinApp());
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('wardrobe-spatial-map')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('spatial-W01-R-H01')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const ValueKey('show-node-detail-button')),
      );
      await tester.tap(find.byKey(const ValueKey('show-node-detail-button')));
      await tester.pumpAndSettle();

      expect(find.text('W01-R-H01'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(const ValueKey('status-verified-W01-R-H01')),
      );
      await tester.tap(find.byKey(const ValueKey('status-verified-W01-R-H01')));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const ValueKey('add-item-button')));
      await tester.tap(find.byKey(const ValueKey('add-item-button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('item-name-input')),
        'black coat',
      );
      await tester.enterText(
        find.byKey(const ValueKey('item-category-input')),
        'jacket',
      );
      await tester.enterText(
        find.byKey(const ValueKey('item-color-input')),
        'black',
      );
      await tester.enterText(
        find.byKey(const ValueKey('item-material-input')),
        'wool',
      );
      await tester.enterText(
        find.byKey(const ValueKey('item-brand-input')),
        'sample brand',
      );
      await tester.enterText(
        find.byKey(const ValueKey('item-size-input')),
        'M',
      );
      await tester.enterText(
        find.byKey(const ValueKey('item-location-index-input')),
        '3',
      );
      await tester.enterText(
        find.byKey(const ValueKey('item-visual-input')),
        'front photo of black zipper coat',
      );

      expect(find.byKey(const ValueKey('item-photo-ref-input')), findsNothing);
      expect(
        find.byKey(const ValueKey('photo-evidence-empty')),
        findsOneWidget,
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('mock-capture-photo-button')),
      );
      await tester.tap(find.byKey(const ValueKey('mock-capture-photo-button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('photo-evidence-captured')),
        findsOneWidget,
      );
      expect(find.textContaining('mock://photo/W01-R-H01/'), findsNothing);

      await tester.ensureVisible(
        find.byKey(const ValueKey('save-item-button')),
      );
      await tester.tap(find.byKey(const ValueKey('save-item-button')));
      await tester.pumpAndSettle();

      expect(find.text('black coat'), findsOneWidget);
      expect(find.textContaining('jacket / black / wool'), findsOneWidget);
      expect(find.textContaining('sample brand / M'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('stored-item-detail-summary-W01-R-H01-0')),
        findsOneWidget,
      );
      expect(
        find.textContaining('front photo of black zipper coat'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('stored-item-photo-evidence-W01-R-H01-0')),
        findsOneWidget,
      );
      expect(find.textContaining('mock://photo/W01-R-H01/'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('stored-item-card-W01-R-H01-0')),
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('clothing-detail-sheet-W01-R-H01-0')),
        findsOneWidget,
      );
      expect(find.textContaining('R-H01-3'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('clothing-detail-location-guidance-W01-R-H01-0'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('mapped'), findsNothing);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
