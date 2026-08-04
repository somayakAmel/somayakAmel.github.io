import '../../../../core/data/json_reader.dart';
import '../../../../core/data/local_json_datasource.dart';
import '../../../../core/managers/assets_manager.dart';
import '../models/skill_model.dart';

abstract class SkillsLocalDatasource {
  Future<List<SkillModel>> getSkills();
}

class SkillsLocalDatasourceImpl implements SkillsLocalDatasource {
  final LocalJsonDataSource _jsonDataSource;

  SkillsLocalDatasourceImpl(this._jsonDataSource);

  @override
  Future<List<SkillModel>> getSkills() async {
    final Map<String, dynamic> json = await _jsonDataSource.readJson(
      AssetsManager.skillsData,
    );
    return json
        .objList('skills')
        .map(SkillModel.fromJson)
        // An entry with no name cannot render as anything but a blank chip.
        .where((SkillModel s) => s.name.trim().isNotEmpty)
        .toList(growable: false);
  }
}
