import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';

class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({super.key, required this.results});

  final List<Map<String, dynamic>> results;

  @override
  Widget build(BuildContext context) {
    final uniqueIngredients = <String>{};
    for (final result in results) {
      final ingredients = (result['ingredients'] as List<dynamic>? ?? const [])
          .map((item) => item.toString());
      uniqueIngredients.addAll(ingredients);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ingrédients détectés')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résultat test',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${uniqueIngredients.length} ingrédient(s) unique(s) détecté(s) au total.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: uniqueIngredients.isEmpty
                ? [
                    const Chip(
                      label: Text('Aucun ingrédient remonté par le backend'),
                    ),
                  ]
                : uniqueIngredients
                      .map(
                        (ingredient) => Chip(
                          label: Text(ingredient),
                          backgroundColor: const Color(0xFFEAF3ED),
                        ),
                      )
                      .toList(),
          ),
          const SizedBox(height: 20),
          ...results.map((result) {
            final ingredients =
                (result['ingredients'] as List<dynamic>? ?? const [])
                    .map((item) => item.toString())
                    .toList();
            final title = [result['brand'], result['name']]
                .where(
                  (value) =>
                      value != null && value.toString().trim().isNotEmpty,
                )
                .map((value) => value.toString())
                .join(' • ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isEmpty ? 'Produit analysé' : title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ingredients.isEmpty
                            ? [const Chip(label: Text('Aucun ingrédient'))]
                            : ingredients
                                  .map(
                                    (ingredient) =>
                                        Chip(label: Text(ingredient)),
                                  )
                                  .toList(),
                      ),
                      const SizedBox(height: 14),
                      if (ingredients.isNotEmpty)
                        Builder(
                          builder: (context) {
                            final controller = context.watch<AppController>();
                            return FilledButton.icon(
                              onPressed: controller.isBusy
                                  ? null
                                  : () => _saveResult(context, result),
                              icon: controller.isBusy
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.bookmark_add_outlined),
                              label: const Text(
                                'Enregistrer dans Mes produits',
                              ),
                            );
                          },
                        )
                      else
                        const Text(
                          'Sauvegarde impossible tant que des ingrédients n\'ont pas été extraits.',
                          style: TextStyle(color: Color(0xFF7A4B00)),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _saveResult(
    BuildContext context,
    Map<String, dynamic> result,
  ) async {
    final controller = context.read<AppController>();
    try {
      await controller.saveAnalyzedProduct(result);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Produit enregistré dans Mes produits.'),
          backgroundColor: Color(0xFF12372A),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'enregistrer le produit : $error'),
          backgroundColor: const Color(0xFFB53F2F),
        ),
      );
    }
  }
}
