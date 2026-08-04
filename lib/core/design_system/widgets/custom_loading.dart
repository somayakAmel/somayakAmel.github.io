import 'package:flutter/material.dart';

import '../../extensions/responsive_extension.dart';
import '../../managers/values_manager.dart';
import '../theme/app_color_scheme.dart';

/// Adaptive circular progress indicator (ARCHITECTURE_GUIDE §11.4).
class CustomLoading extends StatelessWidget {
  final double? size;
  final Color? color;
  final double? strokeWidth;

  const CustomLoading({super.key, this.size, this.color, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    final double resolved = (size ?? AppSize.s24).rs;
    return SizedBox(
      height: resolved,
      width: resolved,
      child: CircularProgressIndicator.adaptive(
        strokeWidth: strokeWidth ?? AppSize.s2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? context.colors.accent,
        ),
      ),
    );
  }
}
