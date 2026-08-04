/// Barrel for the design system (ARCHITECTURE_GUIDE §11).
///
/// [RULE] Never use a raw Flutter `Text`, `Container`, `Image`, or `AppBar` in
/// feature code. Always the `Custom*` equivalent (Rule 26).
library;

export 'theme/app_color_scheme.dart';
export 'theme/theme_manager.dart';
export 'widgets/custom_app_bar.dart';
export 'widgets/custom_container.dart';
export 'widgets/custom_error_widget.dart';
export 'widgets/custom_image.dart';
export 'widgets/custom_loading.dart';
export 'widgets/custom_svg.dart';
export 'widgets/custom_text.dart';
