import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/constants/app_constants.dart";
import "../../services/auth_service.dart";
import "../../services/database_service.dart";
import "../../providers/history_provider.dart";
import "../../models/user_model.dart";
import "../../widgets/glass_card.dart";
import "../../widgets/particle_background.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserModel?>? _userFuture;

  @override
  void initState() {
    super.initState();
    // Fetch user data once and store the future
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      _userFuture = DatabaseService().getUserData(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final history = Provider.of<HistoryProvider>(context);
    final user = authService.currentUser;

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
                      onPressed: widget.onBack,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: FutureBuilder<UserModel?>(
                            future: user != null ? DatabaseService().getUserData(user.uid) : null,
                            builder: (context, snapshot) {
                              final userData = snapshot.data;
                              final name = userData?.name ?? user?.displayName ?? "User";
                              final email = userData?.email ?? user?.email ?? "user@neurabrief.ai";

                              if (snapshot.connectionState == ConnectionState.waiting && userData == null) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return Column(
                                children: [
                                  CircleAvatar(
                                    radius: 36,
                                    backgroundColor: Colors.white12,
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : "NB",
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    email,
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton.icon(
                                    onPressed: () => authService.signOut(),
                                    icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                                    label: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                label: "Total Summaries", 
                                value: history.totalSummaries.toString(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: "Words Processed", 
                                value: "${(history.totalWordsProcessed / 1000).toStringAsFixed(1)}k",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                label: "Fav Category", 
                                value: history.favoriteCategory,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Achievements",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Wrap(
                          spacing: 8,
                          children: [
                            _Badge(label: "🥉 Beginner"),
                            _Badge(label: "🥈 Learner"),
                            _Badge(label: "🥇 AI Master"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "AI Dashboard",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Weekly Usage (Summaries/Day)",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 160,
                                child: BarChart(
                                  BarChartData(
                                    borderData: FlBorderData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    barGroups: List.generate(
                                      7,
                                      (index) => BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY: history.weeklyUsage[index],
                                            gradient: AppConstants.primaryGradient,
                                            width: 12,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Note Complexity Trend",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 160,
                                child: LineChart(
                                  LineChartData(
                                    borderData: FlBorderData(show: false),
                                    titlesData: const FlTitlesData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: history.monthlyTrend.isEmpty 
                                          ? [const FlSpot(0, 0)]
                                          : List.generate(
                                              history.monthlyTrend.length,
                                              (i) => FlSpot(i.toDouble(), history.monthlyTrend[i]['value']),
                                            ),
                                        isCurved: true,
                                        gradient: AppConstants.primaryGradient,
                                        barWidth: 3,
                                        dotData: const FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              child: _StatTile(label: "AI Accuracy", value: "96%"),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                label: "Time Saved", 
                                value: "${history.timeSavedHours.toStringAsFixed(1)}h",
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      borderRadius: 20,
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
