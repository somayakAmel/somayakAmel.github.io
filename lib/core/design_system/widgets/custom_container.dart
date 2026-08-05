import 'package:flutter/material.dart';

import '../../extensions/common_extensions.dart';
import '../../extensions/responsive_extension.dart';
import '../../extensions/spacing_extension.dart';
import '../../managers/fonts_manager.dart';
import '../../managers/values_manager.dart';
import '../theme/app_color_scheme.dart';
import 'custom_loading.dart';
import 'custom_text.dart';

/// Container, button, and card in one (ARCHITECTURE_GUIDE §11.1).
///
/// The single most-used widget. It is a container, a button, a card, and a
/// loading button depending on its parameters.
///
/// Behaviour preserved from the guide:
///  - built on [AnimatedContainer], so every style change animates for free;
///  - `isLoading: true` morphs it into a pill showing [CustomLoading];
///  - `onTap == null || isLoading` renders a plain child, otherwise it wraps in
///    Material + InkWell;
///  - every optional style parameter defaults to a token constant, so it looks
///    right with zero configuration.
///
/// Extended beyond the guide for Web (PROJECT_SPEC §10.1):
///  - `hoverLift` raises the surface and deepens the shadow on pointer hover;
///  - focus is visible via [FocusableActionDetector], because Flutter Web's
///    default focus ring is inadequate (SPEC §14).
class CustomContainer extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget? child;
  final String? text;
  final bool isFilled;
  final bool transparentButton;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? textFont;
  final FontWeight? textWeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final BoxShape? shape;
  final double? height;
  final double? width;
  final Duration? duration;
  final bool isLoading;
  final List<BoxShadow>? boxShadow;
  final bool hoverLift;

  /// Soft accent glow behind the surface, strengthening on hover.
  ///
  /// [RULE] Reserved for primary CTAs. A glow on every button is decoration;
  /// a glow on the one action that matters is hierarchy (design system §Glow).
  final bool glow;

  final AlignmentGeometry? alignment;

  /// Announced to screen readers when this acts as a button and its content is
  /// not self-describing (an icon-only button, for instance).
  final String? semanticLabel;

  const CustomContainer({
    super.key,
    this.onTap,
    this.child,
    this.text,
    this.isFilled = true,
    this.transparentButton = false,
    this.color,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.textFont,
    this.textWeight,
    this.padding,
    this.margin,
    this.borderRadius,
    this.shape,
    this.height,
    this.width,
    this.duration,
    this.isLoading = false,
    this.boxShadow,
    this.hoverLift = false,
    this.glow = false,
    this.alignment,
    this.semanticLabel,
  });

  @override
  State<CustomContainer> createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer> {
  bool _isHovered = false;
  bool _isFocused = false;

  bool get _isInteractive => widget.onTap != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    final Color baseColor =
        widget.color ??
        (widget.transparentButton ? Colors.transparent : colors.accent);

    // Filled uses the colour as background; outlined uses it as the border and
    // keeps the surface transparent.
    final Color background = widget.isFilled && !widget.transparentButton
        ? (_isHovered && _isInteractive ? _hovered(baseColor, colors) : baseColor)
        : Colors.transparent;

    final Color effectiveTextColor =
        widget.textColor ??
        (widget.isFilled && !widget.transparentButton
            ? colors.onAccent
            : baseColor);

    final BorderRadiusGeometry radius = widget.shape == BoxShape.circle
        ? BorderRadius.zero
        : (widget.borderRadius ?? BorderValues.b12.borderAll);

    final Widget? content = _buildContent(effectiveTextColor);

    final Widget container = AnimatedContainer(
      duration: _duration(context),
      curve: AppCurves.state,
      height: widget.height?.rh,
      width: widget.isLoading ? null : widget.width?.rw,
      alignment: widget.alignment,
      padding: widget.padding ?? PaddingValues.p16.pSymmetricVH,
      decoration: BoxDecoration(
        color: background,
        shape: widget.shape ?? BoxShape.rectangle,
        borderRadius: widget.shape == BoxShape.circle ? null : radius,
        border: _buildBorder(baseColor, colors),
        boxShadow: _buildShadow(),
      ),
      child: content,
    );

    if (!_isInteractive) {
      return _withMargin(container);
    }

    final Widget interactive = FocusableActionDetector(
      onShowHoverHighlight: (bool hovering) {
        // Gated on pointer type by Flutter itself: this fires only for a real
        // mouse, so a touchscreen laptop does not get sticky hover (R-11).
        if (mounted) setState(() => _isHovered = hovering);
      },
      onShowFocusHighlight: (bool focused) {
        if (mounted) setState(() => _isFocused = focused);
      },
      mouseCursor: SystemMouseCursors.click,
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap!.call();
            return null;
          },
        ),
      },
      child: AnimatedSlide(
        duration: _duration(context),
        curve: AppCurves.state,
        offset: widget.hoverLift && _isHovered
            ? const Offset(0, -0.02)
            : Offset.zero,
        child: Material(
          color: Colors.transparent,
          borderRadius: widget.shape == BoxShape.circle ? null : radius,
          clipBehavior: Clip.antiAlias,
          shape: widget.shape == BoxShape.circle ? const CircleBorder() : null,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : radius.resolve(Directionality.of(context)),
            splashColor: colors.accent.getWithOpacity(0.12),
            highlightColor: colors.accent.getWithOpacity(0.06),
            child: container,
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      child: _withMargin(interactive),
    );
  }

  Widget _withMargin(Widget child) => widget.margin == null
      ? child
      : Padding(padding: widget.margin!, child: child);

  Widget? _buildContent(Color textColor) {
    if (widget.isLoading) {
      return CustomLoading(size: AppSize.s20, color: textColor);
    }
    // Child wins over text (guide §11.1).
    if (widget.child != null) return widget.child;
    if (widget.text != null) {
      return CustomText(
        widget.text!,
        color: textColor,
        fontSize: widget.textFont ?? FontSize.bodyDesktop,
        fontWeight: widget.textWeight ?? FontWeightManager.semiBold,
        textAlign: TextAlign.center,
        height: LineHeights.tight,
      );
    }
    return null;
  }

  BoxBorder? _buildBorder(Color baseColor, AppColorScheme colors) {
    final bool hasExplicitBorder = widget.borderColor != null;
    final bool outlined = !widget.isFilled && !widget.transparentButton;

    // A focus ring must be visible on every focusable element (SPEC §14).
    if (_isFocused) {
      return Border.all(color: colors.accent, width: AppSize.s2);
    }
    if (hasExplicitBorder) {
      return Border.all(
        color: widget.borderColor!,
        width: widget.borderWidth ?? AppSize.s1,
      );
    }
    if (outlined) {
      return Border.all(
        color: baseColor,
        width: widget.borderWidth ?? AppSize.s1,
      );
    }
    return null;
  }

  List<BoxShadow>? _buildShadow() {
    if (widget.boxShadow != null) return widget.boxShadow;

    if (widget.glow) {
      // Wide, very soft, no offset — this reads as light coming off the
      // surface rather than as a drop shadow, which is invisible on a
      // near-black page anyway.
      final AppColorScheme colors = context.colors;
      return <BoxShadow>[
        BoxShadow(
          color: colors.accent.withValues(alpha: _isHovered ? 0.34 : 0.20),
          blurRadius: _isHovered ? 32 : 22,
          spreadRadius: _isHovered ? 1 : 0,
        ),
      ];
    }

    if (widget.hoverLift && _isHovered) return AppShadow.hovered;
    return null;
  }

  Duration _duration(BuildContext context) {
    if (context.reduceMotion) return Duration.zero;
    return widget.duration ?? DurationValues.dm250.milliseconds;
  }

  Color _hovered(Color base, AppColorScheme colors) =>
      base == colors.accent ? colors.accentHover : base;
}
