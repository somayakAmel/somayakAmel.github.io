/// UI chrome translation keys (ARCHITECTURE_GUIDE §12.1).
///
/// [RULE] The constant name and its string value are identical (camelCase),
/// so the JSON key is predictable from the Dart identifier and vice versa.
///
/// [RULE] No hardcoded user-facing strings, ever. Always
/// `StringsManager.someKey.tr(context)`.
///
/// SCOPE: this class holds UI *chrome* only — button labels, section headers,
/// error messages. Portfolio *content* (project titles, bios, achievements)
/// lives in assets/data/*.json as `LocalizedText` and is resolved with
/// `.resolve(locale)`. Two mechanisms, deliberately: different owners,
/// different edit cadence (PROJECT_SPEC §8.2). Do not unify them.
class StringsManager {
  const StringsManager._();

  static const String appName = 'appName';

  // Standards ******************************************************
  static const String tryAgain = 'tryAgain';
  static const String somethingWentWrong = 'somethingWentWrong';
  static const String undefinedRoute = 'undefinedRoute';
  static const String pageNotFound = 'pageNotFound';
  static const String backToHome = 'backToHome';
  static const String close = 'close';
  static const String viewAll = 'viewAll';
  static const String present = 'present';
  static const String copiedToClipboard = 'copiedToClipboard';
  static const String couldNotOpenLink = 'couldNotOpenLink';
  static const String nothingHereYet = 'nothingHereYet';
  // ****************************************************************

  // Navigation
  static const String navHome = 'navHome';
  static const String navAbout = 'navAbout';
  static const String navWork = 'navWork';
  static const String navSkills = 'navSkills';
  static const String navExperience = 'navExperience';
  static const String navContact = 'navContact';
  static const String menu = 'menu';
  static const String switchLanguage = 'switchLanguage';

  // Hero
  static const String heroGreeting = 'heroGreeting';
  static const String viewMyWork = 'viewMyWork';
  static const String downloadResume = 'downloadResume';
  static const String scrollToExplore = 'scrollToExplore';

  // About
  static const String aboutTitle = 'aboutTitle';
  static const String aboutEyebrow = 'aboutEyebrow';

  // Projects
  static const String projectsTitle = 'projectsTitle';
  static const String projectsEyebrow = 'projectsEyebrow';
  static const String featuredProjects = 'featuredProjects';
  static const String allProjects = 'allProjects';
  static const String viewDetails = 'viewDetails';
  static const String viewCaseStudy = 'viewCaseStudy';
  static const String architecture = 'architecture';
  static const String noProjects = 'noProjects';
  static const String overview = 'overview';
  static const String myRole = 'myRole';
  static const String duration = 'duration';
  static const String platforms = 'platforms';
  static const String status = 'status';
  static const String responsibilities = 'responsibilities';
  static const String challenges = 'challenges';
  static const String solutions = 'solutions';
  static const String techStack = 'techStack';
  static const String gallery = 'gallery';
  static const String viewOnGithub = 'viewOnGithub';
  static const String liveDemo = 'liveDemo';
  static const String appStore = 'appStore';
  static const String playStore = 'playStore';
  static const String nextProject = 'nextProject';
  static const String filterAll = 'filterAll';

  // Skills
  static const String skillsTitle = 'skillsTitle';
  static const String skillsEyebrow = 'skillsEyebrow';
  static const String skillsCompetencies = 'skillsCompetencies';
  static const String techStackTitle = 'techStackTitle';
  static const String levelFamiliar = 'levelFamiliar';
  static const String levelProficient = 'levelProficient';
  static const String levelExpert = 'levelExpert';
  static const String noSkills = 'noSkills';

  // Skill categories
  static const String categoryMobile = 'categoryMobile';
  static const String categoryArchitecture = 'categoryArchitecture';
  static const String categoryStateManagement = 'categoryStateManagement';
  static const String categoryBackend = 'categoryBackend';
  static const String categoryTools = 'categoryTools';
  static const String categoryPractices = 'categoryPractices';

  // Experience
  static const String experienceTitle = 'experienceTitle';
  static const String experienceEyebrow = 'experienceEyebrow';
  static const String noExperience = 'noExperience';
  static const String durationYears = 'durationYears';
  static const String durationMonths = 'durationMonths';
  static const String employmentFullTime = 'employmentFullTime';
  static const String employmentPartTime = 'employmentPartTime';
  static const String employmentFreelance = 'employmentFreelance';
  static const String employmentContract = 'employmentContract';
  static const String employmentInternship = 'employmentInternship';

  // Certificates
  static const String certificatesTitle = 'certificatesTitle';
  static const String certificatesEyebrow = 'certificatesEyebrow';
  static const String allCertificates = 'allCertificates';
  static const String verifyCredential = 'verifyCredential';
  static const String credentialId = 'credentialId';
  static const String noCertificates = 'noCertificates';
  static const String issued = 'issued';
  static const String expires = 'expires';
  static const String expired = 'expired';

  // Contact
  static const String contactTitle = 'contactTitle';
  static const String contactEyebrow = 'contactEyebrow';
  static const String contactAvailability = 'contactAvailability';
  static const String getInTouch = 'getInTouch';
  static const String emailMe = 'emailMe';
  static const String noContactLinks = 'noContactLinks';

  // Navigation / viewer
  static const String openMenu = 'openMenu';
  static const String closeMenu = 'closeMenu';
  static const String imageViewer = 'imageViewer';
  static const String previousImage = 'previousImage';
  static const String nextImage = 'nextImage';
  static const String imageOf = 'imageOf';

  // Project status
  static const String statusLive = 'statusLive';
  static const String statusInDevelopment = 'statusInDevelopment';
  static const String statusArchived = 'statusArchived';

  // Footer
  static const String builtWithFlutter = 'builtWithFlutter';
  static const String sourceOnGithub = 'sourceOnGithub';
  static const String allRightsReserved = 'allRightsReserved';
}
