import 'package:flutter/material.dart';

class AppMotion {
  const new _();

  static const Duration stampDuration = Duration(milliseconds: 220);
  static const Duration riskMeterDuration = Duration(milliseconds: 400);
  static const Duration bannerFadeDuration = Duration(milliseconds: 300);

  static const Curve defaultCurve = Curves.easeOutCubic;

  static Duration getDuration(BuildContext context, Duration original) {
    if (MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }
    return original;
  }
}
