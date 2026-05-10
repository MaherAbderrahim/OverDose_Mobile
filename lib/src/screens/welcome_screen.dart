import 'package:flutter/material.dart';

import '../ui/ui_kit.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: buildPageBackground(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Container(
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: const LinearGradient(
                      colors: [AppColors.softBlue, AppColors.softPink, AppColors.softPeach],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 26,
                        right: 26,
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, size: 34),
                        ),
                      ),
                      Positioned(
                        left: 22,
                        right: 22,
                        bottom: 22,
                        child: GlassCard(
                          radius: 30,
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'OverDose',
                                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Scannez un produit, comprenez le verdict et suivez vos decisions dans le temps sans complexite inutile.',
                                style: TextStyle(height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniPoint(
                          icon: Icons.dashboard_customize_outlined,
                          title: 'Dashboard',
                          subtitle: 'Vue cumulative simple',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _MiniPoint(
                          icon: Icons.center_focus_strong_outlined,
                          title: 'Scan',
                          subtitle: 'Analyse rapide ou segmentee',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onSignUp,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: AppColors.ink,
                  ),
                  child: const Text('Vous etes nouveau ?'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onSignIn,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text('Vous avez deja un compte ?'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniPoint extends StatelessWidget {
  const _MiniPoint({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.softBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.ink),
        ),
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.muted)),
      ],
    );
  }
}
