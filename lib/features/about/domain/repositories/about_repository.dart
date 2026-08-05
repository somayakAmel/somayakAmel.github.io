import '../entities/about.dart';

/// [RULE] The contract lives in domain and returns ENTITIES, never models —
/// so the domain layer has no dependency on the data layer
/// (guide §22.11(a), PROJECT_SPEC §8.1).
///
/// [RULE] Repository methods return raw values or throw. They never return
/// `Either` — converting exceptions into failures is the use case's job,
/// via `tryCatch` (§2.5, Rule 5).
///
/// Naming standardised on `<Feature>Repository` + folder `repositories/`,
/// resolving the guide's own inconsistency (§22.8).
abstract class AboutRepository {
  Future<About> getAbout();
}
