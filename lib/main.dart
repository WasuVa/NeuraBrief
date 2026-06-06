import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "core/theme/app_theme.dart";
import "providers/history_provider.dart";
import "providers/summary_provider.dart";
import "providers/theme_provider.dart";
import "screens/history/history_screen.dart";
import "screens/home/home_screen.dart";
import "screens/onboarding/onboarding_screen.dart";
import "screens/profile/profile_screen.dart";
import "screens/saved/saved_screen.dart";
import "screens/splash/splash_screen.dart";
import "widgets/glass_card.dart";

void main() {
  runApp(const NeuraBriefApp());
}

class NeuraBriefApp extends StatelessWidget {
  const NeuraBriefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Global state providers for theme, summary generation, and history.
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SummaryProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()..loadHistory()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const SplashScreen(),
            routes: {
              OnboardingScreen.routeName: (_) => const OnboardingScreen(),
              MainShell.routeName: (_) => const MainShell(),
            },
          );
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  static const routeName = "/main";

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Primary screens for the glass bottom navigation.
  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    SavedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          borderRadius: 24,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            selectedItemColor: AppTheme.primary,
            unselectedItemColor: Colors.white70,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded),
                label: "History",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_rounded),
                label: "Saved",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
