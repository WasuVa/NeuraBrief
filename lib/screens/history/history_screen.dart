import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:provider/provider.dart";

import "../../core/constants/app_constants.dart";
import "../../models/summary_model.dart";
import "../../providers/history_provider.dart";
import "../../widgets/glass_card.dart";
import "../../widgets/particle_background.dart";
import "../../widgets/summary_detail_dialog.dart";

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().history;

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
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: onBack,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: history.isEmpty
                        ? _EmptyState()
                        : ListView.separated(
                            itemCount: history.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = history[index];
                              return Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  color: Colors.redAccent.withValues(alpha: 0.2),
                                  child: const Icon(Icons.delete, color: Colors.red),
                                ),
                                onDismissed: (_) {
                                  context.read<HistoryProvider>().deleteSummary(item.id);
                                },
                                child: Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => SummaryDetailDialog(summary: item),
                                        );
                                      },
                                      child: _HistoryCard(item: item),
                                    ),
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: IconButton(
                                        icon: Icon(
                                          item.isFavorite 
                                              ? Icons.bookmark_rounded 
                                              : Icons.bookmark_outline_rounded,
                                          color: item.isFavorite ? AppConstants.secondary : Colors.white70,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          context.read<HistoryProvider>().toggleFavorite(item.id);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final SummaryModel item;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<HistoryProvider>();
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  "${item.date.toLocal()}".split(" ").first,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  item.summary.length > 80
                      ? "${item.summary.substring(0, 80)}..."
                      : item.summary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                _CategoryBadge(label: item.category),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => provider.toggleFavorite(item.id),
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.pinkAccent,
                ),
              ),
              IconButton(
                onPressed: () => provider.deleteSummary(item.id),
                icon: const Icon(Icons.delete_outline, color: Colors.white70),
              ),
            ],
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppConstants.primary.withValues(alpha: 0.2),
        border: Border.all(
          color: AppConstants.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppConstants.primary,
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded, size: 64, color: Colors.white54)
              .animate()
              .scale(duration: 1200.ms, curve: Curves.easeInOut)
              .then()
              .scale(
                begin: const Offset(1.0, 1.0),
                end: const Offset(0.9, 0.9),
              ),
          const SizedBox(height: 16),
          Text(
            "No history yet",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            "Generate a summary to see it here.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
