// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:wardrobe_twin/data/wardrobe_session_store.dart';
import 'package:wardrobe_twin/domain/wardrobe_session.dart';

WardrobeSessionStore createPlatformWardrobeSessionStore({required String key}) {
  return _WebWardrobeSessionStore(key);
}

class _WebWardrobeSessionStore implements WardrobeSessionStore {
  const _WebWardrobeSessionStore(this._key);

  final String _key;

  @override
  Future<WardrobeSession> load() async {
    final raw = html.window.localStorage[_key];
    if (raw == null || raw.isEmpty) {
      return WardrobeSession.empty();
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return WardrobeSession.empty();
    }

    return WardrobeSession.fromJson(decoded);
  }

  @override
  Future<void> save(WardrobeSession session) async {
    html.window.localStorage[_key] = jsonEncode(session.toJson());
  }
}
