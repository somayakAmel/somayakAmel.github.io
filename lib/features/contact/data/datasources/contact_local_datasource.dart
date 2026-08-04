import '../../../../core/data/json_reader.dart';
import '../../../../core/data/local_json_datasource.dart';
import '../../../../core/managers/assets_manager.dart';
import '../models/social_link_model.dart';

abstract class ContactLocalDatasource {
  Future<List<SocialLinkModel>> getSocialLinks();
}

class ContactLocalDatasourceImpl implements ContactLocalDatasource {
  final LocalJsonDataSource _jsonDataSource;

  ContactLocalDatasourceImpl(this._jsonDataSource);

  @override
  Future<List<SocialLinkModel>> getSocialLinks() async {
    final Map<String, dynamic> json = await _jsonDataSource.readJson(
      AssetsManager.socialLinksData,
    );
    return json
        .objList('social_links')
        .map(SocialLinkModel.fromJson)
        // A link with no url is not a link — dropping it beats rendering a
        // tile that does nothing when tapped.
        .where((SocialLinkModel l) => l.url.trim().isNotEmpty)
        .toList(growable: false);
  }
}
