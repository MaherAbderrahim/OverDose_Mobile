import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/products_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'ui/ui_kit.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _titles = ['Dashboard', 'Scan', 'Mes produits', 'Profil'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppController>().refreshSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DashboardScreen(),
      const ScanScreen(),
      const ProductsScreen(),
      const ProfileScreen(),
    ];

    return _AppShellScope(
      goToTab: (value) => setState(() => _index = value),
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(_titles[_index]),
          actions: [
            IconButton(
              onPressed: () => context.read<AppController>().logout(),
              icon: const Icon(Icons.logout),
              tooltip: 'Deconnexion',
            ),
          ],
        ),
        body: Container(
          decoration: buildPageBackground(),
          child: SafeArea(
            child: IndexedStack(index: _index, children: pages),
          ),
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.05),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                  ),
                  child: NavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    height: 72,
                    selectedIndex: _index,
                    onDestinationSelected: (value) => setState(() => _index = value),
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: 'Dashboard',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.camera_alt_outlined),
                        selectedIcon: Icon(Icons.camera_alt),
                        label: 'Scan',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.inventory_2_outlined),
                        selectedIcon: Icon(Icons.inventory_2),
                        label: 'Produits',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person),
                        label: 'Profil',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppShellScope extends InheritedWidget {
  const _AppShellScope({
    required this.goToTab,
    required super.child,
  });

  final ValueChanged<int> goToTab;

  static _AppShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AppShellScope>();
    assert(scope != null, 'No AppShell scope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(_AppShellScope oldWidget) => false;
}

extension AppShellNavigationX on BuildContext {
  void switchHomeTab(int index) {
    _AppShellScope.of(this).goToTab(index);
  }
}
