import 'package:deck_note/providers/auth_provider.dart';
import 'package:deck_note/screens/home_screen.dart';
import 'package:deck_note/screens/login_screen.dart';
import 'package:deck_note/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    // Wait for auth state to be determined
    // This ensures we check if there's a persisted login
    await authProvider.checkInitialAuthState();

    if (!mounted) return;

    // Navigate based on authentication status
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => authProvider.isAuthenticated
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.noteSticky,
                      size: 80,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOut)
                  .then()
                  .shimmer(duration: 1000.ms),

              const SizedBox(height: 30),

              Text(
                    'DecXNote',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 10),

              Text(
                'Your Tasks, Simplified',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms),

              const SizedBox(height: 50),

              const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.secondaryColor,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
