import "package:fl_chart/fl_chart.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../../core/constants/app_constants.dart";
import "../../services/auth_service.dart";
import "../../services/database_service.dart";
import "../../models/user_model.dart";
import "../../widgets/glass_card.dart";
import "../../widgets/particle_background.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = DatabaseService();
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: FutureBuilder<UserModel?>(
                      future: user != null ? dbService.getUserData(user.uid) : null,
                      builder: (context, snapshot) {
                        final userData = snapshot.data;
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.white12,
                              child: Text(
                                userData?.name.isNotEmpty == true 
                                    ? userData!.name[0].toUpperCase() 
                                    : "NB",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userData?.name ?? "NeuraBrief User",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              userData?.email ?? user?.email ?? "user@neurabrief.ai",
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
                  const Row(
                    children: [
                      Expanded(
                        child: _StatCard(label: "Total Summaries", value: "126"),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(label: "Words Processed", value: "24k"),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(label: "Fav Category", value: "AI"),
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
                          "Weekly Usage",
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
                                      toY: (index + 2).toDouble(),
                                      gradient: AppConstants.primaryGradient,
                                      width: 10,
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
                          "Notes Summarized",
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
                                  spots: const [
                                    FlSpot(0, 1),
                                    FlSpot(1, 2.5),
                                    FlSpot(2, 2),
                                    FlSpot(3, 4),
                                    FlSpot(4, 3.5),
                                    FlSpot(5, 4.2),
                                    FlSpot(6, 5),
                                  ],
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
                  const Row(
                    children: [
                      Expanded(
                        child: _StatTile(label: "AI Accuracy", value: "92%"),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatTile(label: "Time Saved", value: "4.6h"),
                      ),
                    ],
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
