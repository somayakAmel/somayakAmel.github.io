import '../../domain/entities/experience.dart';
import '../../domain/repositories/experience_repository.dart';
import '../datasources/experience_local_datasource.dart';
import '../models/experience_model.dart';

class ExperienceRepositoryImpl implements ExperienceRepository {
  final ExperienceLocalDatasource _localDatasource;

  ExperienceRepositoryImpl(this._localDatasource);

  @override
  Future<List<Experience>> getExperience() async {
    final List<ExperienceModel> models = await _localDatasource.getExperience();

    final List<Experience> entities = models
        .map((ExperienceModel e) => e.toEntity())
        .toList();

    // Newest first. Sorting here rather than relying on JSON order means a
    // hand-edited file cannot render the timeline out of sequence.
    entities.sort(
      (Experience a, Experience b) => b.startDate.compareTo(a.startDate),
    );

    return entities;
  }
}
