import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/data/local_json_datasource.dart';
import '../core/utils/link_launcher.dart';
import '../features/about/data/datasources/about_local_datasource.dart';
import '../features/about/data/repositories/about_repository_impl.dart';
import '../features/about/domain/repositories/about_repository.dart';
import '../features/about/domain/usecases/get_about_usecase.dart';
import '../features/about/presentation/cubit/about_cubit.dart';
import '../features/projects/data/datasources/projects_local_datasource.dart';
import '../features/projects/data/repositories/projects_repository_impl.dart';
import '../features/projects/domain/repositories/projects_repository.dart';
import '../features/projects/domain/usecases/get_project_detail_usecase.dart';
import '../features/projects/domain/usecases/get_projects_usecase.dart';
import '../features/projects/presentation/cubit/project_details_cubit.dart';
import '../features/projects/presentation/cubit/projects_cubit.dart';

/// [RULE] Exactly one GetIt instance, exposed as a top-level `sl`
/// (ARCHITECTURE_GUIDE §4).
final GetIt sl = GetIt.instance;

/// The single composition root: one public initialiser plus private per-feature
/// module functions (§4.1).
///
/// [RULE] Initialisation order matters — core primitives first, then features
/// that depend on them.
Future<void> initAppModule() async {
  await _initCore();
  _initAboutModule();
  _initProjectsModule();
}

Future<void> _initCore() async {
  // SharedPreferences persists ONE key: the saved locale. It is not used as a
  // database (PROJECT_SPEC §19).
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // The only rootBundle reader in the app. Registered as a lazy singleton so
  // its parse memo is shared by every feature (SPEC §16).
  sl.registerLazySingleton<LocalJsonDataSource>(
    () => LocalJsonDataSourceImpl(),
  );

  sl.registerLazySingleton<LinkLauncher>(() => const LinkLauncher());
}

/// [RULE] Every feature gets a private `_init<Feature>Module()`, with
/// registrations ordered bottom-up and comment-separated (§4.4, Rule 11).
///
/// Order within a module: DataSources → Repository → UseCases → Cubit.
void _initAboutModule() {
  // datasource
  sl.registerLazySingleton<AboutLocalDatasource>(
    () => AboutLocalDatasourceImpl(sl()),
  );

  // repository — [RULE] always register against the abstract type (Rule 13)
  sl.registerLazySingleton<AboutRepository>(() => AboutRepositoryImpl(sl()));

  // usecase — registered against the concrete type, having no interface
  sl.registerLazySingleton<GetAboutUsecase>(() => GetAboutUsecase(sl()));

  // cubit — [RULE] factory, so each screen gets a fresh instance and
  // BlocProvider disposes it on unmount. A singleton cubit would leak state
  // between screens (§4.3, Rule 12).
  sl.registerFactory<AboutCubit>(() => AboutCubit(sl()));
}

void _initProjectsModule() {
  // datasource
  sl.registerLazySingleton<ProjectsLocalDatasource>(
    () => ProjectsLocalDatasourceImpl(sl()),
  );

  // repository
  sl.registerLazySingleton<ProjectsRepository>(
    () => ProjectsRepositoryImpl(sl()),
  );

  // usecases
  sl.registerLazySingleton<GetProjectsUsecase>(() => GetProjectsUsecase(sl()));
  sl.registerLazySingleton<GetProjectDetailUsecase>(
    () => GetProjectDetailUsecase(sl()),
  );

  // cubits
  sl.registerFactory<ProjectsCubit>(() => ProjectsCubit(sl()));
  sl.registerFactory<ProjectDetailsCubit>(() => ProjectDetailsCubit(sl()));
}
