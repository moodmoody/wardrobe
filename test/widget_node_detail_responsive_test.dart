import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';
import 'package:wardrobe_twin/main.dart';

void main() {
  testWidgets('node detail and add item sheets keep phone-width layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = _FakeWardrobeSessionStore(WardrobeSession.empty());

    await tester.pumpWidget(WardrobeTwinApp(sessionStore: store));
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey('show-node-detail-button')),
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('show-node-detail-button')),
    );
    await tester.tap(find.byKey(const ValueKey('show-node-detail-button')));
    await tester.pumpAndSettle();

    final detailRect = tester.getRect(
      find.byKey(const ValueKey('inventory-summary-W01-L-S02')),
    );
    expect(detailRect.width, lessThanOrEqualTo(430));

    await tester.ensureVisible(find.byKey(const ValueKey('add-item-button')));
    await tester.tap(find.byKey(const ValueKey('add-item-button')));
    await tester.pumpAndSettle();

    final addItemInputRect = tester.getRect(
      find.byKey(const ValueKey('item-name-input')),
    );
    expect(addItemInputRect.width, lessThanOrEqualTo(430));
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
  for (var attempt = 0; attempt < 80; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Expected widget did not appear: $finder');
}
