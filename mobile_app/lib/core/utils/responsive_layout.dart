import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveLayout {
  const ResponsiveLayout._();

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).shortestSide < 380;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 340) return 14;
    if (width < 390) return 18;
    return 24;
  }

  static double clampDouble(double value, double min, double max) {
    return math.min(math.max(value, min), max);
  }

  static EdgeInsets pagePadding(BuildContext context, {double bottom = 24}) {
    final horizontal = horizontalPadding(context);
    return EdgeInsets.fromLTRB(horizontal, 20, horizontal, bottom);
  }
}
