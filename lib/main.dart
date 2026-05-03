import 'package:flutter/material.dart';
import 'src/screens/compare_lists_screen.dart'; // adjust if needed

void main() {
  runApp(const NutriScanApp());
}

class NutriScanApp extends StatelessWidget {
  const NutriScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CompareListsScreen(),
    );
  }
}