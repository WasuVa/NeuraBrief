import "dart:math";

import "package:flutter/material.dart";

import "../../core/constants/app_constants.dart";
import "../../core/utils/app_utils.dart";
import "../../widgets/particle_background.dart";
import "../onboarding/onboarding_screen.dart";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        AppUtils.fadeSlideRoute(const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.backgroundStart,
                AppConstants.backgroundMid,
                AppConstants.backgroundEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return Transform.rotate(
                      angle: _controller.value * 2 * pi * 0.15,
                      child: Transform.scale(
                        scale: _scale.value.clamp(0.0, 1.0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppConstants.primary.withValues(alpha: 0.5),
                                    blurRadius: 40,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              "🧠",
                              style: TextStyle(fontSize: 72),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                AppUtils.gradientText(
                  "Summarize Smarter With AI",
                  Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
