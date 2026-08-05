import '../../../../core/data/local_json_datasource.dart';
import '../../../../core/managers/assets_manager.dart';
import '../models/about_model.dart';

/// [RULE] A datasource file declares its abstract class and its `Impl`
/// together (ARCHITECTURE_GUIDE §2.8, Rule 45).
abstract class AboutLocalDatasource {
  Future<AboutModel> getAbout();
}

class AboutLocalDatasourceImpl implements AboutLocalDatasource {
  final LocalJsonDataSource _jsonDataSource;

  AboutLocalDatasourceImpl(this._jsonDataSource);

  @override
  Future<AboutModel> getAbout() async {
    // [RULE] Only the datasource knows the file layout and the envelope shape.
    // Repositories, use cases, and cubits never index into raw JSON (§2.8).
    final Map<String, dynamic> json = await _jsonDataSource.readJson(
      AssetsManager.aboutData,
    );
    return AboutModel.fromJson(json);
  }
}
