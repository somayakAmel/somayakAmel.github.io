import '../../domain/entities/about.dart';
import '../../domain/repositories/about_repository.dart';
import '../datasources/about_local_datasource.dart';

/// [RULE] Implementations live in `data/repositories/`, named
/// `<Feature>RepositoryImpl`, with dependencies as private final fields
/// injected positionally (guide §7.2).
///
/// The repository is where the model → entity boundary is crossed: everything
/// above this line speaks entities only.
///
/// Note what is absent versus the guide's version: no `NetworkInfo` check, no
/// write-through cache, no offline branch. The app is 100% local, so the
/// online/offline decision this class exists to make in the original has no
/// counterpart here (PROJECT_SPEC §19).
class AboutRepositoryImpl implements AboutRepository {
  final AboutLocalDatasource _localDatasource;

  AboutRepositoryImpl(this._localDatasource);

  @override
  Future<About> getAbout() async {
    final about = await _localDatasource.getAbout();
    return about.toEntity();
  }
}
