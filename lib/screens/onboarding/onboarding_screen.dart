import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";

import "../../core/constants/app_constants.dart";
import "../../core/utils/app_utils.dart";
import "../../widgets/glass_card.dart";
import "../../widgets/glow_button.dart";
import "../../widgets/particle_background.dart";
import "../../main.dart";

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const routeName = "/onboarding";

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      icon: "📚",
      title: "Upload any note instantly",
      subtitle:
          "Drop text, scan images, or record voice — NeuraBrief handles it all",
    ),
    _OnboardingData(
      icon: "🤖",
      title: "AI extracts key information",
      subtitle: "Our neural engine finds what matters most in seconds",
    ),
    _OnboardingData(
      icon: "⚡",
      title: "Get concise summaries in seconds",
      subtitle: "Clean, structured, ready to use",
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _skip() {
    Navigator.of(context).pushReplacement(
      AppUtils.fadeSlideRoute(const MainShell()),
    );
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
          child: SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _skip,
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemBuilder: (context, index) {
                      final data = _pages[index];
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                data.icon,
                                style: const TextStyle(fontSize: 64),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                data.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                data.subtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              if (index == _pages.length - 1) ...[
                                const SizedBox(height: 24),
                                GlowButton(
                                  label: "Get Started",
                                  fullWidth: true,
                                  onPressed: _skip,
                                ),
                              ],
                            ],
                          ).animate().fadeIn(duration: 500.ms).slideY(
                                begin: 0.2,
                                end: 0,
                                duration: 500.ms,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildIndicator(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentIndex == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: _currentIndex == index
                ? AppConstants.primaryGradient
                : null,
            color: _currentIndex == index
                ? null
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;
}
