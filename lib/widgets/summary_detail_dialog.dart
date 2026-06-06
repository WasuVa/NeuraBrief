import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/summary_model.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';

class SummaryDetailDialog extends StatelessWidget {
  const SummaryDetailDialog({super.key, required this.summary});

  final SummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${summary.date.toLocal()}".split(" ").first,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CategoryBadge(label: summary.category),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Summary",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppConstants.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary.summary,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Keywords",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppConstants.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: summary.keywords
                          .map((kw) => Chip(
                                label: Text(kw),
                                backgroundColor: Colors.white12,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Key Points",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppConstants.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    ...summary.keyPoints.map((point) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Colors.greenAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(point)),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GlowButton(
                    label: "CLOSE",
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    final text = "--- ${summary.title} ---\n\n"
                        "Summary:\n${summary.summary}\n\n"
                        "Key Points:\n${summary.keyPoints.map((p) => "• $p").join("\n")}\n\n"
                        "Generated by NeuraBrief AI";
                    Share.share(text);
                  },
                  icon: const GlassCard(
                    padding: EdgeInsets.all(12),
                    borderRadius: 12,
                    child: Icon(Icons.share_rounded, color: AppConstants.secondary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppConstants.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstants.primary.withValues(alpha: 0.6)),
      ),
      child: Text(
        "🏷️ $label",
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppConstants.primary,
            ),
      ),
    );
  }
}
