import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:provider/provider.dart";

import "core/theme/app_theme.dart";
import "providers/history_provider.dart";
import "providers/summary_provider.dart";
import "providers/theme_provider.dart";
import "screens/auth/login_screen.dart";
import "screens/history/history_screen.dart";
import "screens/home/home_screen.dart";
import "screens/onboarding/onboarding_screen.dart";
import "screens/profile/profile_screen.dart";
import "screens/saved/saved_screen.dart";
import "screens/splash/splash_screen.dart";
import "services/auth_service.dart";
import "widgets/glass_card.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Note: You must run 'flutterfire configure' and have firebase_options.dart
  // to initialize Firebase with DefaultFirebaseOptions.currentPlatform
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Firebase initialization failed: $e. Make sure you've added google-services.json/GoogleService-Info.plist or run flutterfire configure.");
  }
  runApp(const NeuraBriefApp());
}

class NeuraBriefApp extends StatelessWidget {
  const NeuraBriefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SummaryProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()..loadHistory()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const AuthWrapper(),
            routes: {
              OnboardingScreen.routeName: (_) => const OnboardingScreen(),
              MainShell.routeName: (_) => const MainShell(),
              "/login": (_) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return const MainShell();
        }
        return const LoginScreen();
      },
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
  List<Widget> get _screens => [
    const HomeScreen(),
    HistoryScreen(onBack: () => setState(() => _currentIndex = 0)),
    SavedScreen(onBack: () => setState(() => _currentIndex = 0)),
    ProfileScreen(onBack: () => setState(() => _currentIndex = 0)),
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
