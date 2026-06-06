import "package:animated_text_kit/animated_text_kit.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/constants/app_constants.dart";
import "../../core/utils/app_utils.dart";
import "../../models/summary_model.dart";
import "../../providers/history_provider.dart";
import "../../providers/summary_provider.dart";
import "../../widgets/animated_orb.dart";
import "../../widgets/particle_background.dart";
import "../summary/summary_screen.dart";

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    final provider = context.read<SummaryProvider>();
    final history = context.read<HistoryProvider>();
    
    // Run the AI and keep the orb on screen for at least 3 seconds.
    final results = await Future.wait([
      provider.generateSummary(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    final summary = results[0] as SummaryModel?;

    if (!mounted) {
      return;
    }

    if (summary != null) {
      // Automatically save to history/DB
      await history.addSummary(summary);
      
      // Clear the input field for the next note
      provider.clearInput();
      
      Navigator.of(context).pushReplacement(
        AppUtils.fadeSlideRoute(const SummaryScreen()),
      );
    } else {
      // Show error and go back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'An error occurred'),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.of(context).pop();
    }
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
                const AnimatedOrb(size: 220),
                const SizedBox(height: 24),
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                      ),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      TypewriterAnimatedText("Analyzing content...",
                          speed: const Duration(milliseconds: 80)),
                      TypewriterAnimatedText("Extracting key concepts...",
                          speed: const Duration(milliseconds: 80)),
                      TypewriterAnimatedText("Generating summary...",
                          speed: const Duration(milliseconds: 80)),
                      TypewriterAnimatedText("Finalizing results...",
                          speed: const Duration(milliseconds: 80)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 220,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white12,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: AppConstants.primaryGradient,
                      ),
                    ),
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
