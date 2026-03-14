import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimationConstants {
  // Durations
  static const Duration durationInstant = Duration();
  static const Duration durationFastest = Duration(milliseconds: 150);
  static const Duration durationFast = Duration(milliseconds: 300);
  static const Duration durationNormal = Duration(milliseconds: 500);
  static const Duration durationSlow = Duration(milliseconds: 800);
  static const Duration durationSlowest = Duration(milliseconds: 1200);
  static const Duration durationPageTransition = Duration(milliseconds: 300);
  static const Duration durationDialog = Duration(milliseconds: 200);
  static const Duration durationSnackbar = Duration(milliseconds: 400);
  static const Duration durationTooltip = Duration(milliseconds: 500);
  static const Duration durationHover = Duration(milliseconds: 100);

  // Curves
  static const Curve curveDefault = Curves.easeInOut;
  static const Curve curveBounce = Curves.bounceOut;
  static const Curve curveElastic = Curves.elasticOut;
  static const Curve curveFastOutSlowIn = Curves.fastOutSlowIn;
  static const Curve curveDecelerate = Curves.decelerate;
  static const Curve curveAccelerate = Curves.accelerate;
  static const Curve curveLinear = Curves.linear;
  static const Curve curveEase = Curves.ease;
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;

  // Page Transitions
  static const PageTransitionsTheme pageTransitions = PageTransitionsTheme(
    builders: <, >{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );

  // Hero Animations
  static const double heroMinScale = 0.6;
  static const double heroMaxScale = 1;
  static const double heroMinBlur = 0;
  static const double heroMaxBlur = 10;

  // Fade Animations
  static const double fadeMinOpacity = 0;
  static const double fadeMaxOpacity = 1;

  // Slide Animations
  static const Offset slideStartOffset = Offset(0, 0.1);
  static const Offset slideEndOffset = Offset.zero;
  static const Offset slideFromLeft = Offset(-0.5, 0);
  static const Offset slideFromRight = Offset(0.5, 0);
  static const Offset slideFromTop = Offset(0, -0.5);
  static const Offset slideFromBottom = Offset(0, 0.5);

  // Scale Animations
  static const double scaleMin = 0.8;
  static const double scaleNormal = 1;
  static const double scaleMax = 1.2;

  // Rotation Animations
  static const double rotationMin = 0;
  static const double rotationQuarter = 90;
  static const double rotationHalf = 180;
  static const double rotationFull = 360;

  // Shimmer Animations
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Gradient shimmerGradient = LinearGradient(
    colors: <>[
      Color(0xFFEBEBEB),
      Color(0xFFF5F5F5),
      Color(0xFFEBEBEB),
    ],
    stops: <double>[0.1, 0.3, 0.5],
    begin: Alignment(-1, -0.3),
    end: Alignment(1, 0.3),
  );

  // Pulse Animations
  static const Duration pulseDuration = Duration(milliseconds: 800);
  static const double pulseMinScale = 1;
  static const double pulseMaxScale = 1.1;

  // Loading Animations
  static const Duration loadingSpinDuration = Duration(milliseconds: 800);
  static const double loadingMinOpacity = 0.3;
  static const double loadingMaxOpacity = 1;

  // Gift Animations
  static const Duration giftFlyDuration = Duration(milliseconds: 800);
  static const double giftStartScale = 0.5;
  static const double giftEndScale = 1.2;

  // Like Animations
  static const Duration likeDuration = Duration(milliseconds: 500);
  static const double likeStartScale = 0.8;
  static const double likePeakScale = 1.4;
  static const double likeEndScale = 1;

  // Confetti Animations
  static const Duration confettiDuration = Duration(seconds: 3);
  static const int confettiCount = 100;
  static const double confettiMinSize = 5;
  static const double confettiMaxSize = 15;

  // Transition Curves
  static const Curve transitionCurve = Curves.easeInOutCubic;

  // Spring Physics
  static const double springMass = 1;
  static const double springStiffness = 200;
  static const double springDamping = 20;

  // Staggered Animations
  static const double staggeredDelay = 0.03;
  static const double staggeredInterval = 0.05;

  // Get animation by name
  static Duration getDuration(String name) {
    switch (name) {
      case 'instant':
        return durationInstant;
      case 'fastest':
        return durationFastest;
      case 'fast':
        return durationFast;
      case 'normal':
        return durationNormal;
      case 'slow':
        return durationSlow;
      case 'slowest':
        return durationSlowest;
      default:
        return durationNormal;
    }
  }

  // Get curve by name
  static Curve getCurve(String name) {
    switch (name) {
      case 'bounce':
        return curveBounce;
      case 'elastic':
        return curveElastic;
      case 'fastOutSlowIn':
        return curveFastOutSlowIn;
      case 'decelerate':
        return curveDecelerate;
      case 'accelerate':
        return curveAccelerate;
      case 'linear':
        return curveLinear;
      case 'ease':
        return curveEase;
      case 'easeIn':
        return curveEaseIn;
      case 'easeOut':
        return curveEaseOut;
      case 'easeInOut':
        return curveEaseInOut;
      default:
        return curveDefault;
    }
  }
}