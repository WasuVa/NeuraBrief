import "package:animated_text_kit/animated_text_kit.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/constants/app_constants.dart";
import "../../providers/history_provider.dart";
import "../../providers/summary_provider.dart";
import "../../widgets/glass_card.dart";
import "../../widgets/particle_background.dart";

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summaryProvider = context.watch<SummaryProvider>();
    final summary = summaryProvider.currentSummary;

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
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Summary Result",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                _CategoryBadge(
                                  label: summary?.category ?? "Programming",
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Quick Overview",
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const TabBar(
                    indicatorColor: AppConstants.primary,
                    tabs: [
                      Tab(text: "Summary"),
                      Tab(text: "Keywords"),
                      Tab(text: "Action Items"),
                      Tab(text: "Mind Map"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _SummaryTab(summaryText: summary?.summary ?? ""),
                        _KeywordsTab(keywords: summary?.keywords ?? const []),
                        _ActionItemsTab(items: summary?.keyPoints ?? const []),
                        const _MindMapTab(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "AI Features",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: SummaryLength.values.map((value) {
                              return _ChoiceChip(
                                label: value.name.capitalize(),
                                selected: summaryProvider.length == value,
                                onTap: () => summaryProvider.setLength(value),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: SummaryStyle.values.map((value) {
                              return _ChoiceChip(
                                label: value.name.capitalize(),
                                selected: summaryProvider.style == value,
                                onTap: () => summaryProvider.setStyle(value),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _ActionButton(
                          icon: Icons.copy_rounded,
                          label: "Copy",
                          onTap: () {},
                        ),
                        _ActionButton(
                          icon: Icons.bookmark_rounded,
                          label: "Save",
                          onTap: () {
                            final history = context.read<HistoryProvider>();
                            if (summary != null) {
                              history.addSummary(summary);
                            }
                          },
                        ),
                        _ActionButton(
                          icon: Icons.refresh_rounded,
                          label: "Regenerate",
                          onTap: () {
                            summaryProvider.generateSummary();
                          },
                        ),
                        _ActionButton(
                          icon: Icons.share_rounded,
                          label: "Share",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.summaryText});

  final String summaryText;

  @override
  Widget build(BuildContext context) {
    if (summaryText.isEmpty) {
      return const Center(child: Text("No summary yet."));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyLarge!,
          child: AnimatedTextKit(
            isRepeatingAnimation: false,
            animatedTexts: [
              TyperAnimatedText(
                summaryText,
                speed: const Duration(milliseconds: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeywordsTab extends StatelessWidget {
  const _KeywordsTab({required this.keywords});

  final List<String> keywords;

  @override
  Widget build(BuildContext context) {
    if (keywords.isEmpty) {
      return const Center(child: Text("No keywords."));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: keywords
            .map(
              (keyword) => Chip(
                backgroundColor: Colors.white12,
                label: Text(keyword),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ActionItemsTab extends StatelessWidget {
  const _ActionItemsTab({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text("No action items."));
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Top 5 Key Points",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.greenAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MindMapTab extends StatelessWidget {
  const _MindMapTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Mind Map",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Icon(Icons.account_tree_rounded, size: 48, color: Colors.white70),
            const SizedBox(height: 8),
            Text(
              "Visual map coming soon",
              style: Theme.of(context).textTheme.labelMedium,
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
    final color = label.toLowerCase().contains("program")
        ? Colors.blueAccent
        : Colors.purpleAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        "🔧 $label",
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: selected ? AppConstants.primaryGradient : null,
          color:
              selected ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: 16,
          child: Column(
            children: [
              Icon(widget.icon, color: Colors.white70, size: 20),
              const SizedBox(height: 4),
              Text(widget.label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      ),
    );
  }
}

extension _Capitalize on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
