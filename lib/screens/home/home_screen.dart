import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";

import "../../core/constants/app_constants.dart";
import "../../core/utils/app_utils.dart";
import "../../models/user_model.dart";
import "../../providers/history_provider.dart";
import "../../providers/summary_provider.dart";
import "../../services/auth_service.dart";
import "../../services/database_service.dart";
import "../../widgets/animated_orb.dart";
import "../../widgets/glass_card.dart";
import "../../widgets/glow_button.dart";
import "../../widgets/particle_background.dart";
import "../loading/loading_screen.dart";
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Coming Soon")),
    );
  }

  Future<void> _handlePaste() async {
    final provider = context.read<SummaryProvider>();
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      provider.updateInput(data.text!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Text pasted from clipboard")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Clipboard is empty")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = AppUtils.getGreeting(DateTime.now());
    final provider = context.watch<SummaryProvider>();
    final history = context.watch<HistoryProvider>();
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    if (_controller.text != provider.inputText) {
      _controller.text = provider.inputText;
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    }

    return Scaffold(
      body: ParticleBackground(
        child: Stack(
          children: [
            Container(
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
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$greeting 👋",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        FutureBuilder<UserModel?>(
                          future: user != null ? DatabaseService().getUserData(user.uid) : null,
                          builder: (context, snapshot) {
                            final name = snapshot.data?.name ?? "NB";
                            return CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white12,
                              child: Text(
                                name.isNotEmpty ? name[0].toUpperCase() : "NB",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                            label: "Saved Notes", 
                            value: history.totalSaved.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: provider.clearInput,
                              icon: const Icon(Icons.close_rounded),
                              color: Colors.white70,
                            ),
                          ),
                          TextField(
                            controller: _controller,
                            minLines: 5,
                            maxLines: 12,
                            onChanged: provider.updateInput,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: const InputDecoration(
                              hintText: "Paste your notes here...",
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Chars: ${provider.charCount}",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                              Text(
                                "Words: ${provider.wordCount}",
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InputOption(
                          icon: Icons.article_outlined,
                          label: "Paste Text",
                          onTap: _handlePaste,
                        ),
                        _InputOption(
                          icon: Icons.camera_alt_outlined,
                          label: "Scan Image",
                          onTap: _showComingSoon,
                        ),
                        _InputOption(
                          icon: Icons.mic_none,
                          label: "Voice Note",
                          onTap: _showComingSoon,
                        ),
                        _InputOption(
                          icon: Icons.upload_file_outlined,
                          label: "Upload File",
                          onTap: _showComingSoon,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Summary Length",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: SummaryLength.values.map((value) {
                        return _ChoiceChip(
                          label: value.name.capitalize(),
                          selected: provider.length == value,
                          onTap: () => provider.setLength(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Style",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: SummaryStyle.values.map((value) {
                        return _ChoiceChip(
                          label: value.name.capitalize(),
                          selected: provider.style == value,
                          onTap: () => provider.setStyle(value),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    GlowButton(
                      label: history.canGenerateSummary ? "Generate Summary" : "Upgrade to Premium",
                      fullWidth: true,
                      onPressed: () {
                        if (history.canGenerateSummary) {
                          Navigator.of(context).push(
                            AppUtils.fadeSlideRoute(const LoadingScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("AI Limit Reached. Please upgrade to Pro in Profile."),
                              backgroundColor: Colors.orangeAccent,
                            ),
                          );
                          // Optionally switch to profile tab
                        }
                      },
                    ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

class _InputOption extends StatelessWidget {
  const _InputOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 20,
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppConstants.primaryGradient : null,
          color:
              selected ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
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

extension _Capitalize on String {
  String capitalize() {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
