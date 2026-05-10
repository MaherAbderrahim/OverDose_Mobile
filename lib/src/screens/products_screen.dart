import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../models.dart';
import '../ui/ui_kit.dart';
import 'recommendations_list_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _decisionFilter = 'all';
  String _riskFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final filtered = controller.products.where((product) {
      final decisionMatches = switch (_decisionFilter) {
        'all' => true,
        'active' => product.userDecision == 'approved' || product.userDecision == 'saved',
        _ => product.userDecision == _decisionFilter,
      };
      final riskMatches = switch (_riskFilter) {
        'all' => true,
        'high' => product.riskLevel == 'HIGH' || product.riskLevel == 'CRITICAL',
        'moderate' => product.riskLevel == 'MODERATE',
        'low' => product.riskLevel == 'LOW',
        _ => true,
      };
      return decisionMatches && riskMatches;
    }).toList();

    return RefreshIndicator(
      onRefresh: controller.refreshProducts,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          HighlightBanner(
            title: 'Mes produits',
            subtitle:
                'Votre memoire active: decisions, niveau de risque derive et acces rapide aux alternatives.',
            icon: Icons.inventory_2_outlined,
            colors: const [AppColors.softBlue, AppColors.softPeach],
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  title: '${controller.products.length} produit(s)',
                  subtitle: 'Filtres de decision et de risque cote application.',
                  trailing: IconButton(
                    onPressed: controller.isBusy ? null : controller.refreshProducts,
                    icon: const Icon(Icons.refresh),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Decision'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Tous',
                      active: _decisionFilter == 'all',
                      onTap: () => setState(() => _decisionFilter = 'all'),
                    ),
                    _FilterPill(
                      label: 'Actifs',
                      active: _decisionFilter == 'active',
                      onTap: () => setState(() => _decisionFilter = 'active'),
                    ),
                    _FilterPill(
                      label: 'Approved',
                      active: _decisionFilter == 'approved',
                      onTap: () => setState(() => _decisionFilter = 'approved'),
                    ),
                    _FilterPill(
                      label: 'Saved',
                      active: _decisionFilter == 'saved',
                      onTap: () => setState(() => _decisionFilter = 'saved'),
                    ),
                    _FilterPill(
                      label: 'Pending',
                      active: _decisionFilter == 'pending',
                      onTap: () => setState(() => _decisionFilter = 'pending'),
                    ),
                    _FilterPill(
                      label: 'Rejected',
                      active: _decisionFilter == 'rejected',
                      onTap: () => setState(() => _decisionFilter = 'rejected'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Risque'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterPill(
                      label: 'Tous',
                      active: _riskFilter == 'all',
                      onTap: () => setState(() => _riskFilter = 'all'),
                    ),
                    _FilterPill(
                      label: 'Eleve',
                      active: _riskFilter == 'high',
                      onTap: () => setState(() => _riskFilter = 'high'),
                    ),
                    _FilterPill(
                      label: 'Modere',
                      active: _riskFilter == 'moderate',
                      onTap: () => setState(() => _riskFilter = 'moderate'),
                    ),
                    _FilterPill(
                      label: 'Faible',
                      active: _riskFilter == 'low',
                      onTap: () => setState(() => _riskFilter = 'low'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const EmptyStateCard(
              title: 'Aucun produit ne correspond',
              message:
                  'Essayez un autre filtre ou ajoutez de nouveaux produits depuis le scan.',
              icon: Icons.filter_alt_off_outlined,
            )
          else
            ...filtered.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductCard(product: product),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductItem product;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: product.category == ProductCategory.food
                      ? const Color(0xFFFFE7D6)
                      : AppColors.softBlue,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  product.category == ProductCategory.food
                      ? Icons.restaurant_outlined
                      : Icons.spa_outlined,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.displayTitle,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.category.label} • ${product.extractionLabel}',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              RiskChip(level: product.riskLevel),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              DecisionChip(label: product.decisionLabel, active: true),
              if (product.updatedAt != null)
                Chip(
                  label: Text(
                    'Maj ${product.updatedAt!.day}/${product.updatedAt!.month}',
                  ),
                ),
            ],
          ),
          if (product.ingredients.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.ingredients
                  .take(5)
                  .map((ingredient) => Chip(label: Text(ingredient)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () => _openDecisionSheet(context),
                  child: const Text('Decision'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: product.isHighRisk
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecommendationsListScreen(product: product),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Alternatives'),
                ),
              ),
            ],
          ),
          if (product.userDecisionNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              product.userDecisionNotes,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openDecisionSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: GlassCard(
            radius: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text('Choisissez la decision utilisateur a memoriser.'),
                const SizedBox(height: 16),
                ...[
                  ('approved', 'Adopter'),
                  ('saved', 'Sauvegarder'),
                  ('rejected', 'Rejeter'),
                ].map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: FilledButton.tonal(
                      onPressed: () async {
                        await context.read<AppController>().setProductDecision(
                          productId: product.id,
                          decision: item.$1,
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(item.$2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecisionChip(label: label, active: active),
    );
  }
}
