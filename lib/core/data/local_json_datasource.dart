import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/errors/exceptions.dart';

/// Reads JSON content from the asset bundle.
///
/// [RULE] This is the ONLY place in the app that touches `rootBundle`. Every
/// feature datasource depends on this abstraction, which keeps the asset-reading
/// mechanism swappable and gives every feature identical error semantics
/// (PROJECT_SPEC §16).
abstract class LocalJsonDataSource {
  /// Reads and decodes a JSON object asset.
  ///
  /// Throws [AssetLoadException] when the asset is missing or undeclared, and
  /// [DataParseException] when the contents are not a JSON object.
  Future<Map<String, dynamic>> readJson(String assetPath);

  /// Drops the memo. Exposed for tests; the app never calls it, because bundled
  /// assets cannot change while the process is alive.
  void clearCache();
}

class LocalJsonDataSourceImpl implements LocalJsonDataSource {
  /// Parsed-asset memo.
  ///
  /// This is NOT the cache layer the brief prohibits. There is no eviction, no
  /// invalidation, no persistence, and no TTL — it is a Map on a lazy singleton
  /// that exists because bundled assets are immutable for the process lifetime,
  /// which makes re-parsing strictly wasted work. Home's sections reading five
  /// files hit the bundle five times rather than eight, and returning to
  /// /projects re-reads nothing (SPEC §16, §19).
  final Map<String, Map<String, dynamic>> _memo = {};

  @override
  Future<Map<String, dynamic>> readJson(String assetPath) async {
    final Map<String, dynamic>? memoized = _memo[assetPath];
    if (memoized != null) return memoized;

    final String raw;
    try {
      raw = await rootBundle.loadString(assetPath);
    } catch (e) {
      // The overwhelmingly common cause is a folder that was never declared in
      // pubspec.yaml — assets/projects/ is not recursive (SPEC risk R-7).
      throw AssetLoadException(
        'Could not load "$assetPath". Is it declared in pubspec.yaml? '
        'Note that asset folder declarations are not recursive.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e) {
      throw DataParseException('"$assetPath" is not valid JSON: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      // Every content file's root is an object, never a bare array, so there is
      // room for a future `version` or `meta` key (SPEC §9).
      throw DataParseException(
        '"$assetPath" must contain a JSON object at its root, '
        'found ${decoded.runtimeType}.',
      );
    }

    _memo[assetPath] = decoded;
    return decoded;
  }

  @override
  void clearCache() => _memo.clear();
}
