import '../entities/social_link.dart';

abstract class ContactRepository {
  /// All links, in editorial order.
  Future<List<SocialLink>> getSocialLinks();

  /// Links flagged for the footer, in editorial order.
  Future<List<SocialLink>> getFooterLinks();
}
