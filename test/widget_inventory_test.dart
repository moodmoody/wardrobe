import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';
import 'package:wardrobe_twin/main.dart';

void main() {
  testWidgets('mobile inventory confirms an item is still in its mapped node', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = _FakeWardrobeSessionStore(
      WardrobeSession.empty()
          .addItem(
            const StoredWardrobeItem(
              name: 'black coat',
              nodeId: 'W01-R-H01',
              nodeName: 'right hanging rod',
            ),
          )
          .addItem(
            const StoredWardrobeItem(
              name: 'white shirt',
              nodeId: 'W01-R-H01',
              nodeName: 'right hanging rod',
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

    expect(
      find.byKey(const ValueKey('inventory-summary-W01-R-H01')),
      findsOneWidget,
    );
    expect(find.textContaining('应有 2 件'), findsOneWidget);
    expect(find.textContaining('已确认 0 件'), findsOneWidget);
    expect(find.textContaining('未确认 2 件'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('presence-present-W01-R-H01-0')),
    );
    await tester.tap(
      find.byKey(const ValueKey('presence-present-W01-R-H01-0')),
    );
    await tester.pumpAndSettle();

    expect(
      store.session.itemsByNode['W01-R-H01']![0].presenceStatus,
      'present',
    );
    expect(find.textContaining('已确认 1 件'), findsOneWidget);
    expect(find.textContaining('未确认 1 件'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('presence-missing-W01-R-H01-1')),
    );
    await tester.tap(
      find.byKey(const ValueKey('presence-missing-W01-R-H01-1')),
    );
    await tester.pumpAndSettle();

    expect(
      store.session.itemsByNode['W01-R-H01']![1].presenceStatus,
      'missing',
    );
    expect(store.session.auditStatuses['W01-R-H01'], 'verified');
    expect(find.textContaining('已确认 2 件'), findsOneWidget);
    expect(find.textContaining('缺失 1 件'), findsOneWidget);
    expect(find.textContaining('未确认 0 件'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
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
