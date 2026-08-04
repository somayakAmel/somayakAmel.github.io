import 'dart:convert';
import 'dart:io';

import 'validation_result.dart';

/// Validates the JSON content in `assets/data/` and the translation files.
///
/// Pure logic against a filesystem root, so it is unit-testable against a
/// temporary directory rather than only the real project.
///
/// Checks implemented:
///  1.  JSON schema correctness (parses, root is an object)
///  2.  Required fields exist
///  3.  Unique project slugs
///  4.  Duplicate ids (skills, experience, certificates, social links)
///  5.  Asset paths exist (covers, logos)
///  6.  Screenshot paths exist
///  7.  Certificate assets exist
///  8.  Resume path exists
///  9.  GitHub URL format
///  10. Demo URL format
///  11. Localization key completeness (en/ar parity + StringsManager coverage)
///  12. Broken asset references (any *_path field pointing at a missing file)
class DataValidator {
  /// Project root — the directory containing `assets/` and `lang/`.
  final Directory root;

  DataValidator(this.root);

  final ValidationResult _result = ValidationResult();

  static const String _dataDir = 'assets/data';
  static const String _projectsDir = 'assets/data/projects';

  /// Fields whose value is an asset path. Used by check 12.
  static const List<String> _assetPathFields = <String>[
    'cover_path',
    'logo_path',
    'image_path',
    'issuer_logo_path',
    'avatar_path',
    'resume_path',
  ];

  ValidationResult run() {
    _validateAbout();
    _validateSkills();
    _validateExperience();
    _validateCertificates();
    _validateSocialLinks();
    _validateProjects();
    _validateLocalization();
    return _result;
  }

  // ---------------------------------------------------------------------------
  // Files
  // ---------------------------------------------------------------------------

  void _validateAbout() {
    const String file = '$_dataDir/about.json';
    final Map<String, dynamic>? json = _readObject(file);
    if (json == null) return;

    _requireFields(file, json, const <String>[
      'name',
      'role_title',
      'tagline',
      'bio',
      'email',
    ]);

    _checkLocalized(file, json, const <String>[
      'name',
      'role_title',
      'tagline',
      'bio',
      'location',
    ]);

    final String? email = _str(json['email']);
    if (email != null && !_isValidEmail(email)) {
      _result.add(
        ValidationIssue.error(
          check: 'email-format',
          file: file,
          message: '"$email" is not a valid email address.',
        ),
      );
    }

    // Check 8: resume path exists.
    //
    // Only the ABSENT case is handled here; the exists-on-disk check comes from
    // the _checkAssetFields sweep below, which already covers resume_path.
    // Doing both would report a missing resume twice.
    if (_str(json['resume_path']) == null) {
      _result.add(
        const ValidationIssue.warning(
          check: 'resume-path',
          file: file,
          message: 'No resume_path set — the resume CTA will be hidden.',
        ),
      );
    }

    _checkAssetFields(file, json);

    for (final Map<String, dynamic> highlight in _objList(json['highlights'])) {
      _requireFields(file, highlight, const <String>['value', 'label']);
      _checkLocalized(file, highlight, const <String>['label']);
    }
  }

  void _validateSkills() {
    const String file = '$_dataDir/skills.json';
    final Map<String, dynamic>? json = _readObject(file);
    if (json == null) return;

    final List<Map<String, dynamic>> skills = _objList(json['skills']);
    if (skills.isEmpty) {
      _result.add(
        const ValidationIssue.warning(
          check: 'required-fields',
          file: file,
          message: 'No skills defined — both Home skill sections render empty.',
        ),
      );
    }

    _checkUniqueIds(file, skills, 'id');

    for (final Map<String, dynamic> skill in skills) {
      _requireFields(file, skill, const <String>['id', 'name', 'kind']);
      _checkEnum(file, skill, 'kind', const <String>['competency', 'technology']);
      _checkEnum(file, skill, 'category', const <String>[
        'mobile',
        'architecture',
        'stateManagement',
        'backend',
        'tools',
        'practices',
      ]);
      if (skill['level'] != null) {
        _checkEnum(file, skill, 'level', const <String>[
          'familiar',
          'proficient',
          'expert',
        ]);
      }
      _checkAssetFields(file, skill);
    }
  }

  void _validateExperience() {
    const String file = '$_dataDir/experience.json';
    final Map<String, dynamic>? json = _readObject(file);
    if (json == null) return;

    final List<Map<String, dynamic>> items = _objList(json['experience']);
    _checkUniqueIds(file, items, 'id');

    for (final Map<String, dynamic> item in items) {
      _requireFields(file, item, const <String>[
        'id',
        'company',
        'role',
        'start_date',
      ]);
      _checkLocalized(file, item, const <String>['company', 'role', 'location']);
      _checkEnum(file, item, 'employment_type', const <String>[
        'fullTime',
        'partTime',
        'freelance',
        'contract',
        'internship',
      ]);

      final DateTime? start = _checkDate(file, item, 'start_date');
      // end_date null is meaningful ("present"), so only a PRESENT-but-invalid
      // value is an error.
      final DateTime? end = item['end_date'] == null
          ? null
          : _checkDate(file, item, 'end_date');

      if (start != null && end != null && end.isBefore(start)) {
        _result.add(
          ValidationIssue.error(
            check: 'date-range',
            file: file,
            message:
                '"${item['id']}" ends (${item['end_date']}) before it starts '
                '(${item['start_date']}).',
          ),
        );
      }

      _checkAssetFields(file, item);
    }
  }

  void _validateCertificates() {
    const String file = '$_dataDir/certificates.json';
    final Map<String, dynamic>? json = _readObject(file);
    if (json == null) return;

    final List<Map<String, dynamic>> items = _objList(json['certificates']);
    _checkUniqueIds(file, items, 'id');

    for (final Map<String, dynamic> item in items) {
      _requireFields(file, item, const <String>[
        'id',
        'title',
        'issuer',
        'issue_date',
      ]);
      _checkLocalized(file, item, const <String>['title', 'issuer']);
      _checkDate(file, item, 'issue_date');
      if (item['expiry_date'] != null) {
        _checkDate(file, item, 'expiry_date');
      }

      final String? url = _str(item['credential_url']);
      if (url != null && !_isValidHttpUrl(url)) {
        _result.add(
          ValidationIssue.error(
            check: 'url-format',
            file: file,
            message: 'credential_url "$url" is not a valid http(s) URL.',
          ),
        );
      }

      // Check 7: certificate assets exist.
      _checkAssetFields(file, item);
    }
  }

  void _validateSocialLinks() {
    const String file = '$_dataDir/social_links.json';
    final Map<String, dynamic>? json = _readObject(file);
    if (json == null) return;

    final List<Map<String, dynamic>> links = _objList(json['social_links']);
    _checkUniqueIds(file, links, 'id');

    for (final Map<String, dynamic> link in links) {
      _requireFields(file, link, const <String>['id', 'platform', 'url']);
      _checkEnum(file, link, 'platform', const <String>[
        'github',
        'linkedin',
        'email',
        'whatsapp',
        'phone',
        'twitter',
        'medium',
        'other',
      ]);

      final String? url = _str(link['url']);
      if (url == null) continue;

      final String platform = _str(link['platform']) ?? 'other';

      // The url must carry a scheme the OS can act on — a bare "github.com/x"
      // silently fails to launch at runtime.
      if (platform == 'email') {
        if (!url.startsWith('mailto:')) {
          _result.add(
            ValidationIssue.error(
              check: 'url-format',
              file: file,
              message: 'Email link "$url" must start with "mailto:".',
            ),
          );
        }
      } else if (platform == 'phone') {
        if (!url.startsWith('tel:')) {
          _result.add(
            ValidationIssue.error(
              check: 'url-format',
              file: file,
              message: 'Phone link "$url" must start with "tel:".',
            ),
          );
        }
      } else if (!_isValidHttpUrl(url)) {
        _result.add(
          ValidationIssue.error(
            check: 'url-format',
            file: file,
            message: '"$url" is not a valid http(s) URL.',
          ),
        );
      }

      // Check 9: GitHub URL format.
      if (platform == 'github' && !_isValidGithubUrl(url)) {
        _result.add(
          ValidationIssue.error(
            check: 'github-url',
            file: file,
            message:
                '"$url" does not look like a github.com URL.',
          ),
        );
      }
    }
  }

  void _validateProjects() {
    const String indexFile = '$_projectsDir/index.json';
    final Map<String, dynamic>? index = _readObject(indexFile);
    if (index == null) return;

    final List<Map<String, dynamic>> projects = _objList(index['projects']);
    if (projects.isEmpty) {
      _result.add(
        const ValidationIssue.warning(
          check: 'required-fields',
          file: indexFile,
          message: 'No projects defined — the portfolio has nothing to show.',
        ),
      );
    }

    // Check 3: unique slugs.
    final Set<String> seenSlugs = <String>{};
    for (final Map<String, dynamic> project in projects) {
      _requireFields(indexFile, project, const <String>[
        'slug',
        'title',
        'type',
      ]);
      _checkLocalized(indexFile, project, const <String>[
        'title',
        'tagline',
        'domain',
      ]);
      _checkEnum(indexFile, project, 'type', const <String>[
        'product',
        'client',
        'openSource',
        'personal',
      ]);

      final String? slug = _str(project['slug']);
      if (slug == null) continue;

      if (!seenSlugs.add(slug)) {
        _result.add(
          ValidationIssue.error(
            check: 'unique-slugs',
            file: indexFile,
            message: 'Duplicate project slug "$slug".',
          ),
        );
      }

      _checkAssetFields(indexFile, project);

      final String detailFile =
          _str(project['detail_file']) ?? '$_projectsDir/$slug.json';
      _validateProjectDetail(detailFile, slug, indexFile);
    }
  }

  void _validateProjectDetail(
    String file,
    String indexSlug,
    String indexFile,
  ) {
    if (!_fileExists(file)) {
      _result.add(
        ValidationIssue.error(
          check: 'detail-file',
          file: indexFile,
          message:
              'Project "$indexSlug" points at "$file", which does not exist.',
        ),
      );
      return;
    }

    final Map<String, dynamic>? json = _readObject(file);
    if (json == null) return;

    // The slug is duplicated across index and detail so a mis-wired
    // detail_file is caught here rather than rendering the wrong project.
    final String? detailSlug = _str(json['slug']);
    if (detailSlug != null && detailSlug != indexSlug) {
      _result.add(
        ValidationIssue.error(
          check: 'slug-mismatch',
          file: file,
          message:
              'Declares slug "$detailSlug" but the index lists it as '
              '"$indexSlug".',
        ),
      );
    }

    _checkLocalized(file, json, const <String>['overview', 'role', 'duration']);

    for (final Map<String, dynamic> cs in _objList(json['challenges'])) {
      // A challenge with no matching solution is the most common way this
      // section reads badly, so it is an error rather than a warning.
      if (cs['challenge'] == null || cs['solution'] == null) {
        _result.add(
          ValidationIssue.error(
            check: 'challenge-pairs',
            file: file,
            message: 'Every challenge must have a matching solution.',
          ),
        );
      }
    }

    // Check 6: screenshot paths exist.
    for (final Map<String, dynamic> image in _objList(json['gallery'])) {
      final String? path = _str(image['path']);
      if (path == null) {
        _result.add(
          ValidationIssue.error(
            check: 'screenshot-paths',
            file: file,
            message: 'A gallery entry has no "path".',
          ),
        );
        continue;
      }
      _checkAssetExists(file, 'gallery.path', path);
    }

    // Checks 9 and 10: GitHub and demo URL format.
    final Map<String, dynamic> links = _obj(json['links']);
    final String? github = _str(links['github']);
    if (github != null && !_isValidGithubUrl(github)) {
      _result.add(
        ValidationIssue.error(
          check: 'github-url',
          file: file,
          message: 'links.github "$github" does not look like a github.com URL.',
        ),
      );
    }

    for (final String key in const <String>[
      'live_demo',
      'app_store',
      'play_store',
    ]) {
      final String? url = _str(links[key]);
      if (url != null && !_isValidHttpUrl(url)) {
        _result.add(
          ValidationIssue.error(
            check: 'demo-url',
            file: file,
            message: 'links.$key "$url" is not a valid http(s) URL.',
          ),
        );
      }
    }
  }

  /// Check 11: localization completeness.
  ///
  /// Three ways this can be wrong, all of which shipped in the source project
  /// the architecture guide describes (its §22.16):
  ///  - en and ar disagree on which keys exist;
  ///  - StringsManager declares a key with no translation;
  ///  - a constant's name and its value differ, breaking the guide's convention.
  void _validateLocalization() {
    const String enFile = 'lang/en.json';
    const String arFile = 'lang/ar.json';

    final Map<String, dynamic>? en = _readObject(enFile);
    final Map<String, dynamic>? ar = _readObject(arFile);
    if (en == null || ar == null) return;

    final Set<String> enKeys = en.keys.toSet();
    final Set<String> arKeys = ar.keys.toSet();

    for (final String missing in enKeys.difference(arKeys)) {
      _result.add(
        ValidationIssue.error(
          check: 'localization',
          file: arFile,
          message: 'Missing key "$missing" (present in en.json).',
        ),
      );
    }
    for (final String missing in arKeys.difference(enKeys)) {
      _result.add(
        ValidationIssue.error(
          check: 'localization',
          file: enFile,
          message: 'Missing key "$missing" (present in ar.json).',
        ),
      );
    }

    for (final MapEntry<String, dynamic> entry in ar.entries) {
      if (_str(entry.value) == null) {
        _result.add(
          ValidationIssue.warning(
            check: 'localization',
            file: arFile,
            message: 'Key "${entry.key}" has an empty Arabic value.',
          ),
        );
      }
    }

    _validateStringsManager(enKeys);
  }

  void _validateStringsManager(Set<String> translatedKeys) {
    const String source = 'lib/core/managers/strings_manager.dart';
    final File file = File('${root.path}/$source');
    if (!file.existsSync()) return;

    final RegExp pattern = RegExp(
      r"static\s+const\s+String\s+(\w+)\s*=\s*'([^']*)'",
    );

    for (final RegExpMatch match in pattern.allMatches(file.readAsStringSync())) {
      final String name = match.group(1)!;
      final String value = match.group(2)!;

      // [RULE] The constant name and its value are identical, so the JSON key
      // is predictable from the Dart identifier (guide §12.1).
      if (name != value) {
        _result.add(
          ValidationIssue.error(
            check: 'localization',
            file: source,
            message:
                'StringsManager.$name has value "$value" — name and value must '
                'match.',
          ),
        );
      }

      if (!translatedKeys.contains(value)) {
        _result.add(
          ValidationIssue.error(
            check: 'localization',
            file: source,
            message: 'StringsManager.$name has no translation in lang/en.json.',
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Primitives
  // ---------------------------------------------------------------------------

  /// Check 1: the file parses and its root is an object.
  Map<String, dynamic>? _readObject(String relativePath) {
    final File file = File('${root.path}/$relativePath');

    if (!file.existsSync()) {
      _result.add(
        ValidationIssue.error(
          check: 'file-exists',
          file: relativePath,
          message: 'File not found.',
        ),
      );
      return null;
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(file.readAsStringSync());
    } catch (e) {
      _result.add(
        ValidationIssue.error(
          check: 'json-schema',
          file: relativePath,
          message: 'Invalid JSON: $e',
        ),
      );
      return null;
    }

    if (decoded is! Map<String, dynamic>) {
      _result.add(
        ValidationIssue.error(
          check: 'json-schema',
          file: relativePath,
          message:
              'Root must be a JSON object, found ${decoded.runtimeType}.',
        ),
      );
      return null;
    }

    return decoded;
  }

  /// Check 2: required fields exist and are non-empty.
  void _requireFields(
    String file,
    Map<String, dynamic> json,
    List<String> fields,
  ) {
    for (final String field in fields) {
      final Object? value = json[field];
      if (value == null || (value is String && value.trim().isEmpty)) {
        _result.add(
          ValidationIssue.error(
            check: 'required-fields',
            file: file,
            message: 'Missing required field "$field".',
          ),
        );
      }
    }
  }

  /// Check 4: no duplicate ids within a collection.
  void _checkUniqueIds(
    String file,
    List<Map<String, dynamic>> items,
    String idField,
  ) {
    final Set<String> seen = <String>{};
    for (final Map<String, dynamic> item in items) {
      final String? id = _str(item[idField]);
      if (id == null) continue;
      if (!seen.add(id)) {
        _result.add(
          ValidationIssue.error(
            check: 'duplicate-ids',
            file: file,
            message: 'Duplicate $idField "$id".',
          ),
        );
      }
    }
  }

  /// Checks 5, 7, 12: every *_path field resolves to a real file.
  void _checkAssetFields(String file, Map<String, dynamic> json) {
    for (final String field in _assetPathFields) {
      final String? path = _str(json[field]);
      if (path == null) continue;
      _checkAssetExists(file, field, path);
    }
  }

  void _checkAssetExists(String file, String field, String path) {
    if (_fileExists(path)) return;
    _result.add(
      ValidationIssue.error(
        check: 'asset-paths',
        file: file,
        message:
            '$field points at "$path", which does not exist. '
            'If the file is present, check that its FOLDER is declared in '
            'pubspec.yaml — asset declarations are not recursive.',
      ),
    );
  }

  /// A bilingual field must be an object carrying both languages. A missing
  /// Arabic value is a warning, since LocalizedText falls back to English.
  void _checkLocalized(
    String file,
    Map<String, dynamic> json,
    List<String> fields,
  ) {
    for (final String field in fields) {
      final Object? value = json[field];
      if (value == null) continue;

      if (value is! Map) {
        _result.add(
          ValidationIssue.error(
            check: 'localized-fields',
            file: file,
            message:
                '"$field" must be an object with "en" and "ar" keys, '
                'found ${value.runtimeType}.',
          ),
        );
        continue;
      }

      final Map<String, dynamic> map = Map<String, dynamic>.from(value);
      if (_str(map['en']) == null) {
        _result.add(
          ValidationIssue.error(
            check: 'localized-fields',
            file: file,
            message: '"$field" has no English value.',
          ),
        );
      }
      if (_str(map['ar']) == null) {
        _result.add(
          ValidationIssue.warning(
            check: 'localized-fields',
            file: file,
            message: '"$field" has no Arabic value; English will be shown.',
          ),
        );
      }

      // Surface remaining scaffolding so it cannot silently ship (per brief).
      for (final String lang in const <String>['en', 'ar']) {
        final String? text = _str(map[lang]);
        if (text != null && text.toUpperCase().contains('TODO')) {
          _result.add(
            ValidationIssue.warning(
              check: 'placeholder-content',
              file: file,
              message: '"$field.$lang" still contains a TODO placeholder.',
            ),
          );
        }
      }
    }
  }

  void _checkEnum(
    String file,
    Map<String, dynamic> json,
    String field,
    List<String> allowed,
  ) {
    final String? value = _str(json[field]);
    if (value == null) return;
    if (allowed.contains(value)) return;
    _result.add(
      ValidationIssue.error(
        check: 'enum-values',
        file: file,
        message:
            '"$field" is "$value"; expected one of ${allowed.join(', ')}.',
      ),
    );
  }

  DateTime? _checkDate(String file, Map<String, dynamic> json, String field) {
    final String? raw = _str(json[field]);
    if (raw == null) return null;
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      _result.add(
        ValidationIssue.error(
          check: 'date-format',
          file: file,
          message: '"$field" is "$raw"; expected ISO-8601 (YYYY-MM-DD).',
        ),
      );
    }
    return parsed;
  }

  bool _fileExists(String relativePath) =>
      File('${root.path}/$relativePath').existsSync();

  // ---------------------------------------------------------------------------
  // Value helpers
  // ---------------------------------------------------------------------------

  /// Non-blank string, or null. The literal "null" counts as absent, since
  /// hand-edited JSON produces it.
  static String? _str(Object? value) {
    if (value == null) return null;
    final String s = value.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  static Map<String, dynamic> _obj(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _objList(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map(Map<String, dynamic>.from)
        .toList(growable: false);
  }

  static bool _isValidEmail(String email) =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(email);

  static bool _isValidHttpUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  static bool _isValidGithubUrl(String url) {
    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !_isValidHttpUrl(url)) return false;
    return uri.host == 'github.com' || uri.host == 'www.github.com';
  }
}
