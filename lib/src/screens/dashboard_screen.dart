import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../app_shell.dart';
import '../models.dart';
import '../ui/ui_kit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final summary = controller.cumulativeSummary;
    final user = controller.currentUser;
    final flaggedProducts = controller.highRiskProducts.take(3).toList();

    return RefreshIndicator(
      onRefresh: () async {
        await controller.refreshProducts(silent: true);
        await controller.refreshCumulativeSummary();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          HighlightBanner(
            title:
                'Bonjour ${user?.firstName.trim().isNotEmpty == true ? user!.firstName : 'vous'}',
            subtitle: summary == null
                ? 'Le scan reste votre entree principale, mais la vraie valeur long terme apparait ici des que vous ajoutez quelques produits.'
                : summary.overallAssessment,
            icon: Icons.insights_outlined,
            action: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonal(
                  onPressed: () => context.switchHomeTab(1),
                  child: const Text('Lancer un scan'),
                ),
                FilledButton.tonal(
                  onPressed: () => context.switchHomeTab(2),
                  child: const Text('Mes produits'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Produits',
                  value: (controller.productCounts['total'] ?? controller.products.length)
                      .toString(),
                  icon: Icons.inventory_2_outlined,
                  tint: AppColors.softBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'A reduire',
                  value: summary?.productsToReduce.toString() ?? '0',
                  icon: Icons.trending_down_rounded,
                  tint: const Color(0xFFFFE7D6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'A eviter',
                  value: summary?.productsToAvoid.toString() ?? '0',
                  icon: Icons.report_gmailerrorred_rounded,
                  tint: const Color(0xFFFFD8E0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (summary == null)
            EmptyStateCard(
              title: 'Pas encore de vue cumulative',
              message:
                  'Ajoutez au moins 2 produits pertinents a Mes produits pour voir les tendances cumulees, les alertes et les conseils actionnables.',
              icon: Icons.auto_graph_outlined,
              action: FilledButton.tonal(
                onPressed: () => context.switchHomeTab(1),
                child: const Text('Scanner maintenant'),
              ),
            ),
          if (summary != null)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Insights cumules',
                    subtitle: 'Resume rapide avant les details plus scientifiques.',
                  ),
                  const SizedBox(height: 16),
                  Text('Produits analyses: ${summary.productCount}'),
                  const SizedBox(height: 8),
                  Text('Produits a risque eleve: ${summary.flaggedProducts}'),
                  const SizedBox(height: 14),
                  ...summary.keyWarnings.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(
                              Icons.brightness_1,
                              size: 8,
                              color: AppColors.softPeach,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  title: 'Decisions utilisateur',
                  subtitle: 'Memoire active de vos choix recents.',
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ChipStat(
                      label: 'Approved',
                      value: controller.productCounts['approved'] ?? 0,
                    ),
                    _ChipStat(
                      label: 'Saved',
                      value: controller.productCounts['saved'] ?? 0,
                    ),
                    _ChipStat(
                      label: 'Pending',
                      value: controller.productCounts['pending'] ?? 0,
                    ),
                    _ChipStat(
                      label: 'Rejected',
                      value: controller.productCounts['rejected'] ?? 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (flaggedProducts.isEmpty)
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Produits a surveiller',
                    subtitle: 'Les produits les plus sensibles apparaissent ici.',
                  ),
                  const SizedBox(height: 12),
                  Text(
                    controller.products.isEmpty
                        ? 'Aucun produit memorise pour le moment.'
                        : 'Aucun produit a risque eleve n a ete detecte dans votre memoire actuelle.',
                  ),
                ],
              ),
            )
          else
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle(
                    title: 'Produits a surveiller',
                    subtitle: 'A traiter rapidement depuis Mes produits.',
                  ),
                  const SizedBox(height: 14),
                  ...flaggedProducts.map(
                    (product) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            RiskChip(level: product.riskLevel),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.displayTitle,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product.decisionLabel} • ${product.category.label}',
                                    style: const TextStyle(color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context.switchHomeTab(2),
                    child: const Text('Ouvrir Mes produits'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  const _ChipStat({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text('$label: $value'));
  }
}
