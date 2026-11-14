import 'package:flutter/material.dart';

class AppMotion {
  const new _();

  static const Duration stampDuration = Duration(milliseconds: 260);
  static const Duration riskMeterDuration = Duration(milliseconds: 450);
  static const Duration bannerFadeDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 350);
  static const Duration cardHoverDuration = Duration(milliseconds: 200);
  static const Duration pulseDuration = Duration(milliseconds: 1400);
  static const Duration staggerDelay = Duration(milliseconds: 60);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve springCurve = Curves.easeOutBack;
  static const Curve luxuryCurve = Curves.fastOutSlowIn;

  static Duration getDuration(BuildContext context, Duration original) {
    if (MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }
    return original;
  }
}
