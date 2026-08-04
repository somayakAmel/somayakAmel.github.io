import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portfolio/core/domain/entities/localized_text.dart';
import 'package:portfolio/features/contact/data/datasources/contact_local_datasource.dart';
import 'package:portfolio/features/contact/data/models/social_link_model.dart';
import 'package:portfolio/features/contact/data/repositories/contact_repository_impl.dart';
import 'package:portfolio/features/contact/domain/entities/social_link.dart';

class _MockDatasource extends Mock implements ContactLocalDatasource {}

void main() {
  group('SocialLinkModel.fromJson', () {
    test('parses a full entry', () {
      final SocialLinkModel model = SocialLinkModel.fromJson(
        <String, dynamic>{
          'id': 'github',
          'platform': 'github',
          'label': <String, dynamic>{'en': 'GitHub', 'ar': 'جيت هب'},
          'url': 'https://github.com/x',
          'icon_key': 'code',
          'show_in_footer': false,
          'order': 3,
        },
      );

      expect(model.platform, SocialPlatform.github);
      expect(model.iconKey, 'code');
      expect(model.showInFooter, isFalse);
      expect(model.order, 3);
    });

    test('icon_key defaults to the platform name when omitted', () {
      final SocialLinkModel model = SocialLinkModel.fromJson(
        <String, dynamic>{'id': 'l', 'platform': 'linkedin', 'url': 'x'},
      );
      expect(model.iconKey, 'linkedin');
    });

    test('show_in_footer defaults to true', () {
      final SocialLinkModel model = SocialLinkModel.fromJson(
        <String, dynamic>{'id': 'l', 'platform': 'linkedin', 'url': 'x'},
      );
      expect(model.showInFooter, isTrue);
    });

    test('an unknown platform falls back to other', () {
      final SocialLinkModel model = SocialLinkModel.fromJson(
        <String, dynamic>{'id': 'x', 'platform': 'myspace', 'url': 'x'},
      );
      expect(model.platform, SocialPlatform.other);
    });
  });

  group('SocialLink.copyValue', () {
    SocialLink link(String url) => SocialLink(
      id: 'x',
      platform: SocialPlatform.email,
      label: const LocalizedText.empty(),
      url: url,
      iconKey: 'mail',
    );

    test('strips the scheme so the copied value is usable', () {
      // What lands on the clipboard should be the address, not
      // "mailto:someone@example.com" (SPEC §7.8).
      expect(link('mailto:a@b.com').copyValue, 'a@b.com');
      expect(link('tel:+201234').copyValue, '+201234');
    });

    test('leaves an http url intact', () {
      expect(
        link('https://github.com/x').copyValue,
        'https://github.com/x',
      );
    });
  });

  group('ContactRepositoryImpl', () {
    late _MockDatasource datasource;
    late ContactRepositoryImpl repository;

    SocialLinkModel model(String id, {bool footer = true, int order = 0}) =>
        SocialLinkModel(
          id: id,
          platform: SocialPlatform.other,
          label: LocalizedText.same(id),
          url: 'https://example.com/$id',
          iconKey: 'link',
          showInFooter: footer,
          order: order,
        );

    setUp(() {
      datasource = _MockDatasource();
      repository = ContactRepositoryImpl(datasource);
    });

    test('sorts by the editorial order field', () async {
      when(() => datasource.getSocialLinks()).thenAnswer(
        (_) async => <SocialLinkModel>[
          model('third', order: 3),
          model('first', order: 1),
          model('second', order: 2),
        ],
      );

      final List<SocialLink> result = await repository.getSocialLinks();
      expect(
        result.map((SocialLink l) => l.id),
        <String>['first', 'second', 'third'],
      );
    });

    test('getFooterLinks filters to footer-flagged links', () async {
      when(() => datasource.getSocialLinks()).thenAnswer(
        (_) async => <SocialLinkModel>[
          model('shown', order: 1),
          model('hidden', footer: false, order: 2),
        ],
      );

      final List<SocialLink> result = await repository.getFooterLinks();
      expect(result.map((SocialLink l) => l.id), <String>['shown']);
    });
  });
}
