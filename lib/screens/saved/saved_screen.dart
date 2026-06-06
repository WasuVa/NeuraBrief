import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/constants/app_constants.dart";
import "../../models/summary_model.dart";
import "../../providers/history_provider.dart";
import "../../widgets/glass_card.dart";
import "../../widgets/particle_background.dart";

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String _query = "";
  String _category = "All";

  final List<String> _categories = const [
    "All",
    "Programming",
    "Business",
    "Study",
  ];

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>().history;
    final saved = history.where((item) => item.isFavorite).toList();
    final filtered = saved.where((item) {
      final matchesCategory = _category == "All" || item.category == _category;
      final matchesQuery =
          _query.isEmpty || item.title.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();

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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      onChanged: (value) => setState(() => _query = value),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search saved summaries",
                        icon: Icon(Icons.search, color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final selected = _category == category;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _category = category),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    selected ? AppConstants.primaryGradient : null,
                                color: selected
                                    ? null
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(
                                      color: Colors.white.withValues(alpha: 0.15),
                                    ),
                              ),
                              child: Text(
                                category,
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Text(
                              "No saved summaries",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _SavedCard(item: filtered[index]);
                            },
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

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.item});

  final SummaryModel item;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
        color: AppConstants.secondary.withValues(alpha: 0.2),
        border: Border.all(
          color: AppConstants.secondary.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppConstants.secondary,
            ),
      ),
    );
  }
}
