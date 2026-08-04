import 'package:flutter/widgets.dart';
// flutter_screenutil exports its own DeviceType (mobile/tablet/web) which
// collides with ours. Ours is the app's vocabulary and carries the breakpoint
// ladder, so theirs is hidden here and everywhere ScreenUtil is imported.
import 'package:flutter_screenutil/flutter_screenutil.dart' hide DeviceType;

import '../managers/breakpoints_manager.dart';

/// Responsive sizing — the foundation every other layout extension builds on
/// (ARCHITECTURE_GUIDE §15.1).
///
/// ## The clamp, and why it exists
///
/// The guide applies `flutter_screenutil` unclamped against a 440x956 design
/// size. That is correct for a phone-only app and WRONG for Web: scaling
/// linearly from a phone-sized design puts 40pt body text and absurd spacing on
/// a 2560px monitor.
///
/// This implementation keeps the guide's exact call sites — `AppSize.s16.spaceH`
/// is unchanged — and clamps the scale factor to 1.0 at and above the tablet
/// breakpoint. Below tablet, scaling behaves exactly as the guide specifies.
///
/// This is PROJECT_SPEC §12's hybrid, and addressing risk R-8 in the extension
/// from day one rather than retrofitting after desktop looks wrong.
extension Responsive on num {
  /// Responsive height.
  double get rh => _clamped(toDouble().h);

  /// Responsive width.
  double get rw => _clamped(toDouble().w);

  /// Responsive radius.
  double get rb => _clamped(toDouble().r);

  /// Responsive size — for square-ish values: font sizes, icon sizes, avatars.
  ///
  /// The guide averages `.h` and `.w`. That is safe on a phone, where both
  /// factors are close, and badly wrong on any wide viewport: at 1440x900 the
  /// width factor is 3.27 while the height factor is 0.94, so the average is
  /// 2.11 and a 34pt heading asks for 71pt. The clamp then caps it, which hid
  /// the problem rather than fixing it.
  ///
  /// Taking the MINIMUM of the two factors keeps the averaging intent — react
  /// to whichever axis is more constrained — without letting a wide-but-short
  /// viewport inflate type. Text and square glyphs are bounded by horizontal
  /// space, so the width factor is the meaningful ceiling.
  double get rs {
    final double byHeight = toDouble().h;
    final double byWidth = toDouble().w;
    return _clamped(byHeight < byWidth ? byHeight : byWidth);
  }

  /// Clamps the scaled result so it never exceeds the raw design value on
  /// viewports at or above the tablet breakpoint.
  ///
  /// Below tablet the scaled value passes through untouched (phones scale up
  /// and down as the guide intends). At tablet and above, `scaled` is capped at
  /// the raw value — the design ladder becomes fixed, and layout adapts through
  /// column counts and MaxWidthWrapper instead of type inflation.
  double _clamped(double scaled) {
    final double raw = toDouble();
    if (!_isWideViewport) return scaled;
    return scaled > raw ? raw : scaled;
  }

  /// Reads ScreenUtil's cached screen width rather than a BuildContext, so the
  /// extension stays callable from const-ish contexts and from any widget
  /// without threading context through. ScreenUtil is initialised in app.dart
  /// before the first frame.
  ///
  /// The threshold is the DESIGN WIDTH, not a named breakpoint. Scaling only
  /// ever inflates above the design width, so that is exactly where clamping
  /// must begin. An earlier version keyed this to `Breakpoints.tablet` (900),
  /// which left the whole 600–899 band inflating — a 16pt body rendered at
  /// ~22pt on a tablet. Caught by screenshotting the real breakpoints.
  bool get _isWideViewport {
    final double width = ScreenUtil().screenWidth;
    // Guard: before ScreenUtil.init completes, screenWidth is 0. Treat that as
    // "not wide" so early calls behave as on mobile rather than clamping.
    if (width <= 0) return false;
    return width >= _designWidth;
  }

  /// Mirrors `PortfolioApp.designSize.width`. Duplicated rather than imported
  /// to keep core/ free of any dependency on src/.
  static const double _designWidth = 440;
}

/// Device-type and layout helpers on BuildContext.
extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  DeviceType get deviceType => Breakpoints.fromWidth(screenWidth);

  bool get isMobile => deviceType.isMobile;

  bool get isWide => deviceType.isWide;

  bool get isDesktopClass => deviceType.isDesktopClass;

  /// True when the OS "reduce motion" accessibility setting is on.
  ///
  /// [RULE] Every animated widget consults this (SPEC §13, §14).
  bool get reduceMotion => MediaQuery.of(this).disableAnimations;

  /// Text direction — read by anything that encodes handedness (timelines,
  /// carousels, directional arrows). Directionality alone does not fix those
  /// (SPEC risk R-6).
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Picks a value per device type, falling back down the ladder when a wider
  /// band is not specified.
  ///
  /// ```dart
  /// final columns = context.responsive(mobile: 1, tablet: 2, desktop: 3);
  /// ```
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? largeDesktop,
  }) => switch (deviceType) {
    DeviceType.mobile => mobile,
    DeviceType.tablet => tablet ?? mobile,
    DeviceType.desktop => desktop ?? tablet ?? mobile,
    DeviceType.largeDesktop => largeDesktop ?? desktop ?? tablet ?? mobile,
  };
}
