/// Asset path registry (ARCHITECTURE_GUIDE §13.2).
///
/// [RULE] No asset path string appears anywhere except this class — EXCEPT
/// paths that arrive from JSON content (`cover_path`, `logo_path`,
/// `image_path`). Those are data, not code (PROJECT_SPEC §11).
///
/// This class therefore holds only *structural* assets: data files the app
/// must know by name, placeholders, and the app logo.
library;

const String _dataPath = 'assets/data';
const String _imagesPath = 'assets/images';
const String _iconsPath = 'assets/icons';
const String _animationsPath = 'assets/animations';

class AssetsManager {
  const AssetsManager._();

  // Data — the JSON content files (PROJECT_SPEC §9)
  static const String aboutData = '$_dataPath/about.json';
  static const String skillsData = '$_dataPath/skills.json';
  static const String experienceData = '$_dataPath/experience.json';
  static const String certificatesData = '$_dataPath/certificates.json';
  static const String socialLinksData = '$_dataPath/social_links.json';
  static const String projectsIndexData = '$_dataPath/projects/index.json';

  // Images
  static const String placeholder = '$_imagesPath/placeholder.webp';
  static const String avatarFallback = placeholder;

  /// The SK wordmark — monogram, name and role in one lockup.
  ///
  /// Cropped to the mark and keyed to transparency from the original in
  /// `assets/_src/logo/`, which is deliberately outside the bundle: it is
  /// 1408x768 of mostly empty backing, and `assets/images/` ships every file
  /// in the folder whether the app references it or not.
  ///
  /// The lockup already reads "Somaya Kamel", so anywhere this appears the
  /// app must not also print the name beside it.
  static const String logo = '$_imagesPath/sk_logo.png';

  // Icons
  static const String iconsDir = _iconsPath;

  // Animations — reserved for the 404 screen and empty states only (SPEC §13)
  static const String animationsDir = _animationsPath;
}
