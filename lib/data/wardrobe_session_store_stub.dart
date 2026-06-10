import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';

WardrobeSessionStore createPlatformWardrobeSessionStore({required String key}) {
  return _MemoryWardrobeSessionStore();
}

class _MemoryWardrobeSessionStore implements WardrobeSessionStore {
  WardrobeSession _session = WardrobeSession.empty();

  @override
  Future<WardrobeSession> load() async => _session;

  @override
  Future<void> save(WardrobeSession session) async {
    _session = session;
  }
}
