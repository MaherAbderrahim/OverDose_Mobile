import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../models.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final grouped = controller.groupedProducts();

    return RefreshIndicator(
      onRefresh: controller.refreshProducts,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Mes produits',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: controller.isBusy
                        ? null
                        : controller.refreshProducts,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              child: _SummaryCard(total: controller.products.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ..._categorySection(
            context,
            ProductCategory.food,
            grouped[ProductCategory.food] ?? const [],
          ),
          ..._categorySection(
            context,
            ProductCategory.cosmetic,
            grouped[ProductCategory.cosmetic] ?? const [],
          ),
          if ((grouped[ProductCategory.unknown] ?? const []).isNotEmpty)
            ..._categorySection(
              context,
              ProductCategory.unknown,
              grouped[ProductCategory.unknown] ?? const [],
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  List<Widget> _categorySection(
    BuildContext context,
    ProductCategory category,
    List<ProductItem> items,
  ) {
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        sliver: SliverToBoxAdapter(
          child: Text(
            category.label,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      if (items.isEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          sliver: const SliverToBoxAdapter(child: _EmptyCategoryCard()),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          sliver: SliverList.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _ProductCard(product: items[index]),
          ),
        ),
    ];
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3ED),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color(0xFF12372A),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$total produit(s)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Catégories séparées pour garder la vue claire.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final ProductItem product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EFE5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    product.category == ProductCategory.food
                        ? Icons.restaurant
                        : Icons.palette,
                    color: const Color(0xFF12372A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${product.brand} • ${product.name}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Extraction: ${product.extractionMethod}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (product.ingredients.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: product.ingredients
                    .take(6)
                    .map((ingredient) => Chip(label: Text(ingredient)))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyCategoryCard extends StatelessWidget {
  const _EmptyCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'Aucun produit dans cette catégorie pour le moment.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
