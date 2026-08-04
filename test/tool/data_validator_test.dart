import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/src/data_validator.dart';
import '../../tool/src/validation_result.dart';

/// Builds a throwaway content tree so the validator can be exercised against
/// deliberately broken data without touching the real assets.
class _Fixture {
  final Directory root;

  _Fixture() : root = Directory.systemTemp.createTempSync('validator_test');

  void write(String relativePath, Object json) {
    final File file = File('${root.path}/$relativePath')
      ..createSync(recursive: true);
    file.writeAsStringSync(jsonEncode(json));
  }

  void writeRaw(String relativePath, String contents) {
    File('${root.path}/$relativePath')
      ..createSync(recursive: true)
      ..writeAsStringSync(contents);
  }

  void touch(String relativePath) {
    File('${root.path}/$relativePath').createSync(recursive: true);
  }

  /// A minimal tree that passes every check, so each test can break exactly one
  /// thing and attribute the failure.
  void seedValid() {
    write('assets/data/about.json', <String, dynamic>{
      'name': <String, String>{'en': 'N', 'ar': 'ن'},
      'role_title': <String, String>{'en': 'R', 'ar': 'ر'},
      'tagline': <String, String>{'en': 'T', 'ar': 'ت'},
      'bio': <String, String>{'en': 'B', 'ar': 'ب'},
      'email': 'a@b.com',
      'resume_path': 'assets/documents/resume.pdf',
    });
    touch('assets/documents/resume.pdf');

    write('assets/data/skills.json', <String, dynamic>{
      'skills': <dynamic>[
        <String, dynamic>{
          'id': 's1',
          'name': 'Flutter',
          'kind': 'technology',
          'category': 'mobile',
        },
      ],
    });

    write('assets/data/experience.json', <String, dynamic>{
      'experience': <dynamic>[
        <String, dynamic>{
          'id': 'e1',
          'company': <String, String>{'en': 'C', 'ar': 'س'},
          'role': <String, String>{'en': 'R', 'ar': 'ر'},
          'start_date': '2024-01-01',
          'end_date': null,
        },
      ],
    });

    write('assets/data/certificates.json', <String, dynamic>{
      'certificates': <dynamic>[
        <String, dynamic>{
          'id': 'c1',
          'title': <String, String>{'en': 'T', 'ar': 'ت'},
          'issuer': <String, String>{'en': 'I', 'ar': 'م'},
          'issue_date': '2024-01-01',
        },
      ],
    });

    write('assets/data/social_links.json', <String, dynamic>{
      'social_links': <dynamic>[
        <String, dynamic>{
          'id': 'gh',
          'platform': 'github',
          'url': 'https://github.com/someone',
        },
      ],
    });

    write('assets/data/projects/index.json', <String, dynamic>{
      'projects': <dynamic>[
        <String, dynamic>{
          'slug': 'alpha',
          'title': <String, String>{'en': 'Alpha', 'ar': 'ألفا'},
          'type': 'client',
          'detail_file': 'assets/data/projects/alpha.json',
        },
      ],
    });

    write('assets/data/projects/alpha.json', <String, dynamic>{
      'slug': 'alpha',
      'overview': <String, String>{'en': 'O', 'ar': 'ن'},
      'role': <String, String>{'en': 'R', 'ar': 'ر'},
      'duration': <String, String>{'en': 'D', 'ar': 'م'},
      'links': <String, dynamic>{},
    });

    write('lang/en.json', <String, String>{'key': 'value'});
    write('lang/ar.json', <String, String>{'key': 'قيمة'});
  }

  void dispose() => root.deleteSync(recursive: true);
}

ValidationResult _run(_Fixture fixture) => DataValidator(fixture.root).run();

List<String> _checksOf(ValidationResult r) =>
    r.errors.map((ValidationIssue i) => i.check).toList();

void main() {
  late _Fixture fixture;

  setUp(() {
    fixture = _Fixture()..seedValid();
  });

  tearDown(() => fixture.dispose());

  test('a well-formed content tree produces no errors', () {
    final ValidationResult result = _run(fixture);
    expect(result.errors, isEmpty, reason: result.errors.join('\n'));
    expect(result.exitCode, 0);
  });

  test('malformed JSON is reported rather than thrown', () {
    fixture.writeRaw('assets/data/skills.json', '{not json');
    expect(_checksOf(_run(fixture)), contains('json-schema'));
  });

  test('a root array is rejected — every file must be an object', () {
    fixture.write('assets/data/skills.json', <dynamic>[]);
    expect(_checksOf(_run(fixture)), contains('json-schema'));
  });

  test('a missing required field is an error', () {
    fixture.write('assets/data/about.json', <String, dynamic>{'email': 'a@b.com'});
    expect(_checksOf(_run(fixture)), contains('required-fields'));
  });

  test('duplicate project slugs are rejected', () {
    fixture.write('assets/data/projects/index.json', <String, dynamic>{
      'projects': <dynamic>[
        <String, dynamic>{
          'slug': 'dup',
          'title': <String, String>{'en': 'A', 'ar': 'أ'},
          'type': 'client',
          'detail_file': 'assets/data/projects/alpha.json',
        },
        <String, dynamic>{
          'slug': 'dup',
          'title': <String, String>{'en': 'B', 'ar': 'ب'},
          'type': 'client',
          'detail_file': 'assets/data/projects/alpha.json',
        },
      ],
    });
    expect(_checksOf(_run(fixture)), contains('unique-slugs'));
  });

  test('duplicate ids within a collection are rejected', () {
    fixture.write('assets/data/skills.json', <String, dynamic>{
      'skills': <dynamic>[
        <String, dynamic>{'id': 'x', 'name': 'A', 'kind': 'technology'},
        <String, dynamic>{'id': 'x', 'name': 'B', 'kind': 'technology'},
      ],
    });
    expect(_checksOf(_run(fixture)), contains('duplicate-ids'));
  });

  test('a missing asset path is an error', () {
    fixture.write('assets/data/skills.json', <String, dynamic>{
      'skills': <dynamic>[
        <String, dynamic>{
          'id': 'x',
          'name': 'A',
          'kind': 'technology',
          'logo_path': 'assets/logos/ghost.svg',
        },
      ],
    });
    expect(_checksOf(_run(fixture)), contains('asset-paths'));
  });

  test('a missing screenshot path is an error', () {
    fixture.write('assets/data/projects/alpha.json', <String, dynamic>{
      'slug': 'alpha',
      'gallery': <dynamic>[
        <String, dynamic>{'path': 'assets/projects/alpha/ghost.webp'},
      ],
    });
    expect(_checksOf(_run(fixture)), contains('asset-paths'));
  });

  test('a missing resume file is an error, and an absent one is a warning', () {
    fixture.write('assets/data/about.json', <String, dynamic>{
      'name': <String, String>{'en': 'N', 'ar': 'ن'},
      'role_title': <String, String>{'en': 'R', 'ar': 'ر'},
      'tagline': <String, String>{'en': 'T', 'ar': 'ت'},
      'bio': <String, String>{'en': 'B', 'ar': 'ب'},
      'email': 'a@b.com',
      'resume_path': 'assets/documents/ghost.pdf',
    });

    final ValidationResult result = _run(fixture);
    // Reported exactly once — the explicit check and the generic sweep must
    // not both fire.
    expect(
      result.errors.where((ValidationIssue i) => i.check == 'asset-paths').length,
      1,
    );
  });

  test('a non-github url in links.github is rejected', () {
    fixture.write('assets/data/projects/alpha.json', <String, dynamic>{
      'slug': 'alpha',
      'links': <String, dynamic>{'github': 'https://gitlab.com/x'},
    });
    expect(_checksOf(_run(fixture)), contains('github-url'));
  });

  test('a malformed demo url is rejected', () {
    fixture.write('assets/data/projects/alpha.json', <String, dynamic>{
      'slug': 'alpha',
      'links': <String, dynamic>{'live_demo': 'not-a-url'},
    });
    expect(_checksOf(_run(fixture)), contains('demo-url'));
  });

  test('an email link without the mailto scheme is rejected', () {
    // A bare address silently fails to launch at runtime.
    fixture.write('assets/data/social_links.json', <String, dynamic>{
      'social_links': <dynamic>[
        <String, dynamic>{
          'id': 'e',
          'platform': 'email',
          'url': 'someone@example.com',
        },
      ],
    });
    expect(_checksOf(_run(fixture)), contains('url-format'));
  });

  test('en/ar key divergence is reported for both directions', () {
    fixture.write('lang/en.json', <String, String>{'key': 'v', 'onlyEn': 'v'});
    fixture.write('lang/ar.json', <String, String>{'key': 'ق', 'onlyAr': 'ق'});

    final List<String> messages = _run(
      fixture,
    ).errors.map((ValidationIssue i) => i.message).toList();

    expect(messages.any((String m) => m.contains('onlyEn')), isTrue);
    expect(messages.any((String m) => m.contains('onlyAr')), isTrue);
  });

  test('a detail file that does not exist is reported', () {
    fixture.write('assets/data/projects/index.json', <String, dynamic>{
      'projects': <dynamic>[
        <String, dynamic>{
          'slug': 'ghost',
          'title': <String, String>{'en': 'G', 'ar': 'غ'},
          'type': 'client',
          'detail_file': 'assets/data/projects/nope.json',
        },
      ],
    });
    expect(_checksOf(_run(fixture)), contains('detail-file'));
  });

  test('a slug mismatch between index and detail is reported', () {
    fixture.write('assets/data/projects/alpha.json', <String, dynamic>{
      'slug': 'something-else',
    });
    expect(_checksOf(_run(fixture)), contains('slug-mismatch'));
  });

  test('a challenge with no solution is rejected', () {
    fixture.write('assets/data/projects/alpha.json', <String, dynamic>{
      'slug': 'alpha',
      'challenges': <dynamic>[
        <String, dynamic>{
          'challenge': <String, String>{'en': 'C', 'ar': 'ت'},
        },
      ],
    });
    expect(_checksOf(_run(fixture)), contains('challenge-pairs'));
  });

  test('an end date before the start date is rejected', () {
    fixture.write('assets/data/experience.json', <String, dynamic>{
      'experience': <dynamic>[
        <String, dynamic>{
          'id': 'e1',
          'company': <String, String>{'en': 'C', 'ar': 'س'},
          'role': <String, String>{'en': 'R', 'ar': 'ر'},
          'start_date': '2024-01-01',
          'end_date': '2020-01-01',
        },
      ],
    });
    expect(_checksOf(_run(fixture)), contains('date-range'));
  });

  test('an unknown enum value is rejected', () {
    fixture.write('assets/data/skills.json', <String, dynamic>{
      'skills': <dynamic>[
        <String, dynamic>{'id': 'x', 'name': 'A', 'kind': 'nonsense'},
      ],
    });
    expect(_checksOf(_run(fixture)), contains('enum-values'));
  });

  test('a TODO placeholder is a warning, not an error', () {
    // The scaffolding has to stay usable while content is being written.
    fixture.write('assets/data/about.json', <String, dynamic>{
      'name': <String, String>{'en': 'TODO', 'ar': 'TODO'},
      'role_title': <String, String>{'en': 'R', 'ar': 'ر'},
      'tagline': <String, String>{'en': 'T', 'ar': 'ت'},
      'bio': <String, String>{'en': 'B', 'ar': 'ب'},
      'email': 'a@b.com',
    });

    final ValidationResult result = _run(fixture);
    expect(
      result.warnings.map((ValidationIssue i) => i.check),
      contains('placeholder-content'),
    );
    expect(_checksOf(result), isNot(contains('placeholder-content')));
  });

  test('exitCode is non-zero when any error is present', () {
    fixture.writeRaw('assets/data/skills.json', 'broken');
    expect(_run(fixture).exitCode, 1);
  });
}
