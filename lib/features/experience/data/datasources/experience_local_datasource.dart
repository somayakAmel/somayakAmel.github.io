import '../../../../core/data/json_reader.dart';
import '../../../../core/data/local_json_datasource.dart';
import '../../../../core/managers/assets_manager.dart';
import '../models/experience_model.dart';

abstract class ExperienceLocalDatasource {
  Future<List<ExperienceModel>> getExperience();
}

class ExperienceLocalDatasourceImpl implements ExperienceLocalDatasource {
  final LocalJsonDataSource _jsonDataSource;

  ExperienceLocalDatasourceImpl(this._jsonDataSource);

  @override
  Future<List<ExperienceModel>> getExperience() async {
    final Map<String, dynamic> json = await _jsonDataSource.readJson(
      AssetsManager.experienceData,
    );
    return json
        .objList('experience')
        .map(ExperienceModel.fromJson)
        .toList(growable: false);
  }
}
