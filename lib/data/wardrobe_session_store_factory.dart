import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/data/wardrobe_session_store_stub.dart'
    if (dart.library.html) 'package:wardrobe_twin/data/wardrobe_session_store_web.dart';

WardrobeSessionStore createWardrobeSessionStore({String key = 'wardrobe_twin_session_v1'}) {
  return createPlatformWardrobeSessionStore(key: key);
}
