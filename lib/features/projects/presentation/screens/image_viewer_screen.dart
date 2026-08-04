import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/core.dart';
import '../../domain/entities/project_detail.dart';

/// Arguments for [ImageViewerScreen].
class ImageViewerArguments {
  final List<GalleryImage> images;
  final int initialIndex;

  const ImageViewerArguments({
    required this.images,
    this.initialIndex = 0,
  });
}

/// Full-screen zoomable gallery (PROJECT_SPEC §6, S6).
///
/// Accessibility requirements this implements (SPEC §14):
///  - Esc closes the viewer;
///  - arrow keys move between images;
///  - focus is trapped inside while open (the route is a fullscreenDialog) and
///    returns to the originating thumbnail on close, which Navigator handles.
class ImageViewerScreen extends StatefulWidget {
  final ImageViewerArguments args;

  const ImageViewerScreen({super.key, required this.args});

  static const String route = '/image_viewer';

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pageController;
  late final FocusNode _focusNode;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.args.initialIndex.clamp(0, _lastIndex);
    // [RULE] Controllers are created here and disposed below (guide §22.18).
    _pageController = PageController(initialPage: _index);
    _focusNode = FocusNode();
    // Keyboard navigation only works if something holds focus.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _lastIndex =>
      widget.args.images.isEmpty ? 0 : widget.args.images.length - 1;

  void _go(int delta) {
    final int next = (_index + delta).clamp(0, _lastIndex);
    if (next == _index) return;
    _pageController.animateToPage(
      next,
      duration: context.reduceMotion
          ? Duration.zero
          : DurationValues.dm250.milliseconds,
      curve: AppCurves.state,
    );
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    // Arrow semantics follow reading direction: in RTL, "next" is left.
    final bool rtl = context.isRtl;
    return switch (event.logicalKey) {
      LogicalKeyboardKey.escape => _close(),
      LogicalKeyboardKey.arrowRight => _handled(() => _go(rtl ? -1 : 1)),
      LogicalKeyboardKey.arrowLeft => _handled(() => _go(rtl ? 1 : -1)),
      _ => KeyEventResult.ignored,
    };
  }

  KeyEventResult _close() {
    Navigator.of(context).maybePop();
    return KeyEventResult.handled;
  }

  KeyEventResult _handled(VoidCallback action) {
    action();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;
    final List<GalleryImage> images = widget.args.images;

    if (images.isEmpty) return const SizedBox.shrink();

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _onKey,
      child: Scaffold(
        backgroundColor: colors.surface0,
        body: Stack(
          children: <Widget>[
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (int i) => setState(() => _index = i),
              itemBuilder: (BuildContext context, int i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: Center(
                  child: CustomImage(
                    path: images[i].path,
                    fit: BoxFit.contain,
                    semanticLabel: images[i].caption?.of(context),
                  ),
                ),
              ),
            ),
            _TopBar(
              index: _index,
              total: images.length,
              caption: images[_index].caption?.of(context),
              onClose: () => Navigator.of(context).maybePop(),
            ),
            if (images.length > 1) ...<Widget>[
              _ArrowButton(
                alignment: AlignmentDirectional.centerStart,
                icon: IconsManager.back,
                semanticLabel: StringsManager.previousImage.tr(context),
                onTap: () => _go(-1),
                enabled: _index > 0,
              ),
              _ArrowButton(
                alignment: AlignmentDirectional.centerEnd,
                icon: IconsManager.forward,
                semanticLabel: StringsManager.nextImage.tr(context),
                onTap: () => _go(1),
                enabled: _index < _lastIndex,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int index;
  final int total;
  final String? caption;
  final VoidCallback onClose;

  const _TopBar({
    required this.index,
    required this.total,
    required this.onClose,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return SafeArea(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CustomText(
                  StringsManager.imageOf
                      .tr(context)
                      .replaceAll('{current}', '${index + 1}')
                      .replaceAll('{total}', '$total'),
                  fontSize: FontSize.labelDesktop,
                  color: colors.textTertiary,
                  textAlign: TextAlign.start,
                ),
                if (caption != null) ...<Widget>[
                  AppSize.s4.spaceH,
                  CustomText(
                    caption!,
                    fontSize: FontSize.captionDesktop,
                    color: colors.textSecondary,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          CustomContainer(
            onTap: onClose,
            shape: BoxShape.circle,
            color: colors.surface2,
            padding: PaddingValues.p10.pAll,
            semanticLabel: StringsManager.close.tr(context),
            child: Icon(
              IconsManager.close,
              size: AppSize.s20,
              color: colors.textPrimary,
            ),
          ),
        ],
      ).withPadding(PaddingValues.p16.pAll),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final AlignmentDirectional alignment;
  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;
  final bool enabled;

  const _ArrowButton({
    required this.alignment,
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final AppColorScheme colors = context.colors;

    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        opacity: enabled ? 1 : 0.25,
        duration: DurationValues.dm150.milliseconds,
        child: CustomContainer(
          onTap: enabled ? onTap : null,
          shape: BoxShape.circle,
          color: colors.surface2,
          padding: PaddingValues.p12.pAll,
          margin: PaddingValues.p16.pSymmetricH,
          semanticLabel: semanticLabel,
          child: Icon(icon, size: AppSize.s20, color: colors.textPrimary),
        ),
      ),
    );
  }
}
