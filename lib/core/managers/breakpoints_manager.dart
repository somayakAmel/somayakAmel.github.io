/// Responsive breakpoints (PROJECT_SPEC §12).
///
/// Four bands. [DeviceType] is resolved from `MediaQuery.sizeOf(context).width`
/// by `ResponsiveBuilder` and by the `.deviceType` context extension.
class Breakpoints {
  const Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1240;

  static DeviceType fromWidth(double width) {
    if (width < mobile) return DeviceType.mobile;
    if (width < tablet) return DeviceType.tablet;
    if (width < desktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
  largeDesktop;

  bool get isMobile => this == DeviceType.mobile;
  bool get isTablet => this == DeviceType.tablet;
  bool get isDesktop => this == DeviceType.desktop;
  bool get isLargeDesktop => this == DeviceType.largeDesktop;

  /// True for phone-sized viewports only.
  bool get isHandset => this == DeviceType.mobile;

  /// True at tablet and above — where ScreenUtil scaling gets clamped
  /// and multi-column layouts kick in.
  bool get isWide => index >= DeviceType.tablet.index;

  /// True at desktop and above — where hover affordances and the inline
  /// anchor nav are used.
  bool get isDesktopClass => index >= DeviceType.desktop.index;
}
