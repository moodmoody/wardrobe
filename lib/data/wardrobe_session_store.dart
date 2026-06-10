import 'package:wardrobe_twin/domain/wardrobe_session.dart';

abstract interface class WardrobeSessionStore {
  Future<WardrobeSession> load();

  Future<void> save(WardrobeSession session);
}
