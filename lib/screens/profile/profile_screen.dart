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
import "../../widgets/glow_button.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _showEditProfileDialog(UserModel? userData, String? userEmail) async {
    final nameController = TextEditingController(text: userData?.name);
    final emailController = TextEditingController(text: userEmail);
    final passwordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Edit Profile", style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Full Name",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "New Password (Optional)",
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("CANCEL", style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                        Expanded(
                          child: GlowButton(
                            label: "SAVE",
                            onPressed: () async {
                              final auth = Provider.of<AuthService>(context, listen: false);
                              final db = DatabaseService();
                              final user = auth.currentUser;

                              if (user == null) return;

                              setDialogState(() => isLoading = true);
                              try {
                                // 1. Update Name in Firestore
                                if (nameController.text.trim() != userData?.name) {
                                  await db.updateUserName(user.uid, nameController.text.trim());
                                }

                                // 2. Update Email in Firebase Auth
                                if (emailController.text.trim() != userEmail) {
                                  await auth.updateEmail(emailController.text.trim());
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("A verification email has been sent to your new address.")),
                                  );
                                }

                                // 3. Update Password in Firebase Auth
                                if (passwordController.text.isNotEmpty) {
                                  await auth.updatePassword(passwordController.text);
                                }

                                final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
                                await historyProvider.refreshUserData();

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Profile updated successfully!")),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error: ${e.toString()}")),
                                );
                              } finally {
                                setDialogState(() => isLoading = false);
                              }
                            },
                          ),
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

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final history = Provider.of<HistoryProvider>(context);
    final user = authService.currentUser;
    final userData = history.userData;

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
                          child: Column(
                            children: [
                              Stack(
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
                                  if (userData?.isPremium == true)
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Icon(Icons.verified, color: AppConstants.secondary, size: 24),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                userData?.name ?? "User",
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: userData?.isPremium == true ? AppConstants.secondary.withValues(alpha: 0.2) : Colors.white10,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: userData?.isPremium == true ? AppConstants.secondary : Colors.white24),
                                ),
                                child: Text(
                                  userData?.isPremium == true ? "PRO ACCOUNT" : "FREE PLAN",
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: userData?.isPremium == true ? AppConstants.secondary : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showEditProfileDialog(userData, user?.email),
                                    icon: const Icon(Icons.edit_rounded, color: AppConstants.primary, size: 18),
                                    label: const Text("Edit Profile", style: TextStyle(color: AppConstants.primary)),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => authService.signOut(),
                                    icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                                    label: const Text("Logout", style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Usage Card
                        if (userData?.isPremium == false)
                          GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("AI Generation Usage", style: Theme.of(context).textTheme.titleSmall),
                                    Text("${userData?.usageCount ?? 0}/2 used", style: Theme.of(context).textTheme.labelMedium),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: (userData?.usageCount ?? 0) / 2,
                                  backgroundColor: Colors.white12,
                                  color: AppConstants.primary,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppConstants.secondary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppConstants.secondary.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.auto_awesome, color: AppConstants.secondary),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          "Get unlimited AI summaries and advanced mind mapping with Pro.",
                                          style: TextStyle(fontSize: 12, color: Colors.white70),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text("Premium payment coming soon!"))
                                          );
                                        },
                                        child: const Text("UPGRADE", style: TextStyle(color: AppConstants.secondary, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 24),
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
