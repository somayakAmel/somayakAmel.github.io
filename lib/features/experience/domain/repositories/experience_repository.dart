import '../entities/experience.dart';

abstract class ExperienceRepository {
  /// Work history, newest first.
  Future<List<Experience>> getExperience();
}
