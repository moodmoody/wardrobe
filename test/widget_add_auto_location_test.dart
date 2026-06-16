import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';
import 'package:wardrobe_twin/main.dart';

void main() {
  testWidgets('add flow previews and saves the next physical slot', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = _FakeWardrobeSessionStore(
      WardrobeSession.empty().addItem(
        const StoredWardrobeItem(
          itemId: 'item-first-coat',
          name: 'first coat',
          nodeId: 'W01-R-H01',
          nodeName: 'right hanging rod',
          locationIndex: 1,
        ),
      ),
    );

    await tester.pumpWidget(WardrobeTwinApp(sessionStore: store));
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey('spatial-W01-R-H01')),
    );

    await tester.tap(find.byKey(const ValueKey('spatial-W01-R-H01')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('show-node-detail-button')),
    );
    await tester.tap(find.byKey(const ValueKey('show-node-detail-button')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const ValueKey('add-item-button')));
    await tester.tap(find.byKey(const ValueKey('add-item-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('item-location-preview')), findsOneWidget);
    expect(find.textContaining('R-H01-2'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('item-name-input')),
      'second coat',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save-item-button')));
    await tester.tap(find.byKey(const ValueKey('save-item-button')));
    await tester.pumpAndSettle();

    final savedItems = store.session.itemsByNode['W01-R-H01']!;
    expect(savedItems.length, 2);
    expect(savedItems.last.name, 'second coat');
    expect(savedItems.last.locationIndex, 2);
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
  for (var attempt = 0; attempt < 20; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Expected widget did not appear: $finder');
}
