import 'package:flutter/widgets.dart';

import 'responsive_extension.dart';

/// Gaps between widgets (ARCHITECTURE_GUIDE §15.2).
///
/// [RULE] Gaps are written `AppSize.s16.spaceH`, never `SizedBox(height: 16)`.
extension MSpacer on num {
  /// Responsive vertical gap.
  SizedBox get spaceH => SizedBox(height: rh);

  /// Raw vertical gap — no responsive scaling.
  SizedBox get spaceHNoRes => SizedBox(height: toDouble());

  /// Responsive horizontal gap.
  SizedBox get spaceW => SizedBox(width: rw);

  /// Raw horizontal gap — no responsive scaling.
  SizedBox get spaceWNoRes => SizedBox(width: toDouble());
}

/// Padding builders (ARCHITECTURE_GUIDE §15.3).
///
/// [RULE] All padding is directional (`start`/`end`, never `left`/`right`), so
/// RTL is correct by construction (§12.4).
extension PaddingManager on num {
  EdgeInsetsDirectional get pAll => EdgeInsetsDirectional.all(rs);

  EdgeInsetsDirectional get pSymmetricV =>
      EdgeInsetsDirectional.symmetric(vertical: rh);

  EdgeInsetsDirectional get pSymmetricH =>
      EdgeInsetsDirectional.symmetric(horizontal: rw);

  EdgeInsetsDirectional get pSymmetricVH =>
      EdgeInsetsDirectional.symmetric(horizontal: rw, vertical: rh);

  EdgeInsetsDirectional get pOnlyStart => EdgeInsetsDirectional.only(start: rw);

  EdgeInsetsDirectional get pOnlyEnd => EdgeInsetsDirectional.only(end: rw);

  EdgeInsetsDirectional get pOnlyTop => EdgeInsetsDirectional.only(top: rh);

  EdgeInsetsDirectional get pOnlyBottom =>
      EdgeInsetsDirectional.only(bottom: rh);
}

/// Record-based padding, for asymmetric values: `(18, 16).pSymmetricVH`
/// is 18 vertical, 16 horizontal.
extension PaddingsManager on (num, num) {
  EdgeInsetsDirectional get pSymmetricVH =>
      EdgeInsetsDirectional.symmetric(vertical: $1.rh, horizontal: $2.rw);
}

/// Four-value padding: `(start, top, end, bottom)`.
extension Paddings4Manager on (num, num, num, num) {
  EdgeInsetsDirectional get pOnlyStartTopEndBottom => EdgeInsetsDirectional.only(
    start: $1.rw,
    top: $2.rh,
    end: $3.rw,
    bottom: $4.rh,
  );
}

/// [RULE] Apply padding with the trailing `.withPadding(...)` on the widget,
/// not by nesting a `Padding` widget (§15.3).
extension WidgetPadding on Widget {
  Widget withPadding(EdgeInsetsGeometry padding) =>
      Padding(padding: padding, child: this);
}

/// Border radius builders (ARCHITECTURE_GUIDE §15.4).
extension BorderManager on num {
  BorderRadiusDirectional get borderAll => BorderRadiusDirectional.circular(rb);

  BorderRadiusDirectional get borderTop => BorderRadiusDirectional.only(
    topStart: Radius.circular(rb),
    topEnd: Radius.circular(rb),
  );

  BorderRadiusDirectional get borderBottom => BorderRadiusDirectional.only(
    bottomStart: Radius.circular(rb),
    bottomEnd: Radius.circular(rb),
  );

  BorderRadiusDirectional get borderStart => BorderRadiusDirectional.only(
    topStart: Radius.circular(rb),
    bottomStart: Radius.circular(rb),
  );

  BorderRadiusDirectional get borderEnd => BorderRadiusDirectional.only(
    topEnd: Radius.circular(rb),
    bottomEnd: Radius.circular(rb),
  );
}

/// Some Flutter APIs (`ClipRRect`, `BoxDecoration.borderRadius` in a few
/// positions) want a non-directional `BorderRadius`.
extension BorderDirectionalToBorder on BorderRadiusDirectional {
  BorderRadius get asBorderRadius => BorderRadius.only(
    topLeft: topStart,
    topRight: topEnd,
    bottomLeft: bottomStart,
    bottomRight: bottomEnd,
  );
}
