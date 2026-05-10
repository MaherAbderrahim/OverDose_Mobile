import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_controller.dart';
import 'app_shell.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';
import 'ui/ui_kit.dart';

class OverDoseApp extends StatelessWidget {
  const OverDoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppController()..bootstrap(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OverDose',
        themeMode: ThemeMode.light,
        theme: buildAppTheme(Brightness.light),
        home: const AppGate(),
      ),
    );
  }
}

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    if (controller.isBootstrapping) {
      return const _BootScreen();
    }

    if (controller.isAuthenticated) {
      if (controller.needsOnboarding) {
        return const OnboardingScreen();
      }
      return const AppShell();
    }

    return _WelcomeAuthFlow();
  }
}

class _WelcomeAuthFlow extends StatefulWidget {
  @override
  State<_WelcomeAuthFlow> createState() => _WelcomeAuthFlowState();
}

class _WelcomeAuthFlowState extends State<_WelcomeAuthFlow> {
  bool _showAuth = false;
  bool _showRegister = false;

  @override
  Widget build(BuildContext context) {
    if (_showAuth) {
      return LoginScreen(
        initialRegister: _showRegister,
        onBack: () => setState(() => _showAuth = false),
      );
    }
    return WelcomeScreen(
      onSignIn: () => setState(() {
        _showRegister = false;
        _showAuth = true;
      }),
      onSignUp: () => setState(() {
        _showRegister = true;
        _showAuth = true;
      }),
    );
  }
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: buildPageBackground(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'OverDose',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Connexion au backend Django local...'),
              const SizedBox(height: 24),
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
