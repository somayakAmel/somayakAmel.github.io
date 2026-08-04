import '../../domain/entities/social_link.dart';
import '../../domain/repositories/contact_repository.dart';
import '../datasources/contact_local_datasource.dart';
import '../models/social_link_model.dart';

class ContactRepositoryImpl implements ContactRepository {
  final ContactLocalDatasource _localDatasource;

  ContactRepositoryImpl(this._localDatasource);

  @override
  Future<List<SocialLink>> getSocialLinks() async {
    final List<SocialLinkModel> models = await _localDatasource
        .getSocialLinks();

    final List<SocialLink> entities = models
        .map((SocialLinkModel e) => e.toEntity())
        .toList();

    entities.sort((SocialLink a, SocialLink b) => a.order.compareTo(b.order));
    return entities;
  }

  @override
  Future<List<SocialLink>> getFooterLinks() async {
    final List<SocialLink> all = await getSocialLinks();
    return all
        .where((SocialLink l) => l.showInFooter)
        .toList(growable: false);
  }
}
