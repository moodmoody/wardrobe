import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';
import 'package:wardrobe_twin/main.dart';

void main() {
  testWidgets('mobile search locates a saved clothing item', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = _FakeWardrobeSessionStore(
      WardrobeSession.empty().addItem(
        const StoredWardrobeItem(
          name: 'black coat',
          nodeId: 'W01-R-H01',
          nodeName: 'right hanging rod',
          presenceStatus: 'missing',
        ),
      ),
    );

    await tester.pumpWidget(WardrobeTwinApp(sessionStore: store));
    await _pumpUntilFound(
      tester,
      find.byKey(const ValueKey('wardrobe-spatial-map')),
    );

    await tester.tap(find.byKey(const ValueKey('find-clothes-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('clothing-search-input')),
      'coat',
    );
    await tester.pumpAndSettle();

    expect(find.text('black coat'), findsOneWidget);

    await tester.tap(find.text('black coat'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('spatial-W01-R-H01')), findsOneWidget);
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
