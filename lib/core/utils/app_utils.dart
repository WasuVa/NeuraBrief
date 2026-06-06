import "package:flutter/material.dart";

import "../constants/app_constants.dart";

class AppUtils {
  static String getGreeting(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return "Good Morning";
    }
    if (hour < 18) {
      return "Good Afternoon";
    }
    return "Good Evening";
  }

  static Widget gradientText(String text, TextStyle? style) {
    return ShaderMask(
      shaderCallback: (bounds) => AppConstants.primaryGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style?.copyWith(color: Colors.white),
      ),
    );
  }

  static PageRouteBuilder<T> fadeSlideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetTween = Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(offsetTween),
            child: child,
          ),
        );
      },
    );
  }
}
