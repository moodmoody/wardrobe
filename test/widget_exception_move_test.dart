import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';
import 'package:wardrobe_twin/main.dart';

void main() {
  testWidgets('exception detail can move missing clothing to a new node', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = _FakeWardrobeSessionStore(
      WardrobeSession.empty().addItem(
        const StoredWardrobeItem(
          itemId: 'item-black-coat',
          name: 'black coat',
          nodeId: 'W01-R-H01',
          nodeName: 'right hanging rod',
          presenceStatus: 'missing',
          locationIndex: 2,
        ),
      ),
    );

    await tester.pumpWidget(WardrobeTwinApp(sessionStore: store));
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey('wardrobe-spatial-map')),
    );
    await _pumpUntilFound(tester, find.textContaining('异常衣服（1）'));

    await tester.tap(find.byKey(const ValueKey('exception-clothes-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('black coat'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey('move-from-detail-W01-R-H01-0')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('move-target-sheet')), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('move-target-node-W01-R-D01')),
    );
    await tester.tap(find.byKey(const ValueKey('move-target-node-W01-R-D01')));
    await tester.pumpAndSettle();

    expect(store.session.itemsByNode['W01-R-H01'], isEmpty);
    final movedItem = store.session.itemsByNode['W01-R-D01']!.single;
    expect(movedItem.itemId, 'item-black-coat');
    expect(movedItem.nodeId, 'W01-R-D01');
    expect(movedItem.presenceStatus, 'unknown');
    expect(movedItem.locationIndex, 1);
    expect(find.textContaining('异常衣服（0）'), findsOneWidget);
  });
}

class _FakeWardrobeSessionStore implements WardrobeSessionStore {
  _FakeWardrobeSessionStore(this.session);

  WardrobeSession session;

  @override
  Future<WardrobeSession> load() async => session;

  @override
  Future<void> save(WardrobeSession session) async {
    this.session = session;
  }
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 50; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Expected widget did not appear: $finder');
}
