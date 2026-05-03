import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_controller.dart';
import 'screens/compare_lists_screen.dart';
import 'screens/compare_products_screen.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/login_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

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
      const LoginScreen(),
      const HomeScreen(),
      const ScanScreen(),
      const ProductsScreen(),
      const CompareListsScreen(),
      const CompareProductsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriScan'),
        backgroundColor: const Color(0xFFF0F7FA),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00D2FF), Color(0xAD00D3FF)],
                ),
              ),
              child: const Text(
                'Menu Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _buildDrawerItem(0, Icons.login, 'Connexion'),
            _buildDrawerItem(1, Icons.dashboard, 'Accueil'),
            _buildDrawerItem(2, Icons.camera_alt, 'Scan'),
            _buildDrawerItem(4, Icons.lightbulb, 'Suggestions'),
            _buildDrawerItem(3, Icons.inventory_2, 'Mes produits'),
            _buildDrawerItem(5, Icons.analytics, 'Comparer Produits'),
            _buildDrawerItem(6, Icons.person, 'Profil'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () {
                context.read<AppController>().logout();
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF0F7FA), Color(0xFFF0F9FF), Color(0xFFE1F5FE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(index: _index, children: pages),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: switch (_index) {
          0 => 0,
          1 => 1,
          2 => 2,
          4 => 3,
          3 => 4,
          6 => 5,
          _ => 0,
        },
        onDestinationSelected: (value) {
          final targetIndex = switch (value) {
            0 => 0,
            1 => 1,
            2 => 2,
            3 => 4,
            4 => 3,
            5 => 6,
            _ => 1,
          };
          setState(() => _index = targetIndex);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.login_outlined),
            selectedIcon: Icon(Icons.login),
            label: 'Login',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.camera_alt_outlined),
            selectedIcon: Icon(Icons.camera_alt),
            label: 'Scan',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Suggestions',
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
    );
  }

  Widget _buildDrawerItem(int index, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: _index == index ? const Color(0xFF00D2FF) : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: _index == index ? FontWeight.bold : FontWeight.normal,
          color: _index == index ? const Color(0xFF00D2FF) : null,
        ),
      ),
      selected: _index == index,
      onTap: () {
        setState(() => _index = index);
        Navigator.pop(context);
      },
    );
  }
}
