import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'compare_products_screen.dart';

enum ToxicityLevel {
  low,
  moderate,
  high;

  String get label => switch (this) {
    ToxicityLevel.low => 'Low',
    ToxicityLevel.moderate => 'Moderate',
    ToxicityLevel.high => 'High',
  };

  Color get color => switch (this) {
    ToxicityLevel.low => const Color(0xFF4CAF50),
    ToxicityLevel.moderate => const Color(0xFFFF9800),
    ToxicityLevel.high => const Color(0xFFF44336),
  };

  IconData get icon => switch (this) {
    ToxicityLevel.low => Icons.check_circle_outline,
    ToxicityLevel.moderate => Icons.remove_circle_outline,
    ToxicityLevel.high => Icons.arrow_circle_up_rounded,
  };
}

class ComparisonProduct {
  final String name;
  final String category;
  final ToxicityLevel toxicity;
  final String? imageUrl;

  ComparisonProduct({
    required this.name,
    required this.category,
    required this.toxicity,
    this.imageUrl,
  });
}

class CompareListsScreen extends StatelessWidget {
  const CompareListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final listA = [
      ComparisonProduct(name: 'Red Matte Lipstick', category: 'Cosmetics', toxicity: ToxicityLevel.high),
      ComparisonProduct(name: 'Full Coverage Foundation', category: 'Cosmetics', toxicity: ToxicityLevel.high),
      ComparisonProduct(name: 'Instant Noodles (Spicy)', category: 'Food', toxicity: ToxicityLevel.high),
      ComparisonProduct(name: 'Sunscreen SPF 50', category: 'Cosmetics', toxicity: ToxicityLevel.moderate),
      ComparisonProduct(name: 'Potato Chips (Classic)', category: 'Food', toxicity: ToxicityLevel.moderate),
      ComparisonProduct(name: 'Hair Color (Dark Brown)', category: 'Cosmetics', toxicity: ToxicityLevel.moderate),
      ComparisonProduct(name: 'Energy Drink', category: 'Food', toxicity: ToxicityLevel.high),
      ComparisonProduct(name: 'Acne Face Wash', category: 'Cosmetics', toxicity: ToxicityLevel.moderate),
    ];

    final listB = [
      ComparisonProduct(name: 'Natural Lip Balm', category: 'Cosmetics', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Mineral Foundation', category: 'Cosmetics', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Organic Oatmeal', category: 'Food', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Sunscreen SPF 30 (Mineral)', category: 'Cosmetics', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Air Popped Popcorn', category: 'Food', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Herbal Shampoo', category: 'Cosmetics', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Coconut Water', category: 'Food', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Gentle Face Cleanser', category: 'Cosmetics', toxicity: ToxicityLevel.low),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Compare Lists',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield_outlined, size: 18, color: Color(0xFF673AB7)),
                const SizedBox(width: 8),
                Text(
                  'Compare products by toxicity',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ListColumn(
                        title: 'List A',
                        subtitle: '8 products',
                        riskBadge: _RiskBadge(
                          label: 'Moderate to High',
                          color: const Color(0xFFFBE9E7),
                          textColor: const Color(0xFFD84315),
                          icon: Icons.warning_amber_rounded,
                        ),
                        products: listA,
                        headerColor: const Color(0xFFEDE7F6),
                        titleColor: const Color(0xFF673AB7),
                      ),
                    ),
                    const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                    Expanded(
                      child: _ListColumn(
                        title: 'List B',
                        subtitle: '8 products',
                        riskBadge: _RiskBadge(
                          label: 'Low',
                          color: const Color(0xFFE8F5E9),
                          textColor: const Color(0xFF2E7D32),
                          icon: Icons.shield_outlined,
                        ),
                        products: listB,
                        headerColor: const Color(0xFFE8F5E9),
                        titleColor: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 28,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'VS',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _Footer(),
        ],
      ),
    );
  }
}

class _ListColumn extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget riskBadge;
  final List<ComparisonProduct> products;
  final Color headerColor;
  final Color titleColor;

  const _ListColumn({
    required this.title,
    required this.subtitle,
    required this.riskBadge,
    required this.products,
    required this.headerColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 80,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.3),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: titleColor,
                      ),
                    ),
                    riskBadge,
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: products.length,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) => _ProductTile(product: products[index]),
          ),
        ),
      ],
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _RiskBadge({
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ComparisonProduct product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CompareProductsScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                product.category == 'Food' ? Icons.fastfood_outlined : Icons.brush_outlined,
                size: 20,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    product.category,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _ToxicitySmallBadge(level: product.toxicity),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _ToxicitySmallBadge extends StatelessWidget {
  final ToxicityLevel level;

  const _ToxicitySmallBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(level.icon, size: 14, color: level.color),
        const SizedBox(width: 4),
        Text(
          level.label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: level.color,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Color(0xFF673AB7), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Toxicity indicates the potential harmful impact of ingredients based on safety data and scientific research.',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: const Color(0xFF673AB7),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const _ComparisonReportBottomSheet(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4527A0),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, size: 24),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Analysis Report',
                      style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    Text(
                      'See health risks and recommendations',
                      style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonReportBottomSheet extends StatelessWidget {
  const _ComparisonReportBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analysis Report',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Part 1: Danger Analysis
                _ReportSection(
                  title: 'Why List A contains risks',
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.red,
                  backgroundColor: const Color(0xFFFFEBEE),
                  content: 'Several products in List A contain ingredients linked to hormonal disruption and skin irritation. Specifically, the "Red Matte Lipstick" and "Energy Drink" contain synthetic dyes and high levels of preservatives that exceed recommended daily safety limits.\n\n'
                      '⚠️ **Advise to remove:**\n'
                      '• Red Matte Lipstick (contains Lead traces)\n'
                      '• Energy Drink (Excessive synthetic Taurine)\n'
                      '• Instant Noodles (High Sodium & MSG)',
                ),
                const SizedBox(height: 24),

                // Part 2: Recommendations
                _ReportSection(
                  title: 'Why List B is recommended',
                  icon: Icons.check_circle_outline,
                  iconColor: Colors.green,
                  backgroundColor: const Color(0xFFE8F5E9),
                  content: 'List B focuses on products with 100% biodegradable ingredients and natural preservatives like Vitamin E. These alternatives provide the same functionality without the long-term toxicity risks associated with synthetic chemicals.\n\n'
                      '✅ **Why they are better:**\n'
                      '• Natural Lip Balm: Uses Beeswax instead of Petrolatum.\n'
                      '• Organic Oatmeal: No added sugars or artificial flavors.\n'
                      '• Mineral Foundation: Free from Parabens and Talc.',
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CompareProductsScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Go to Product-by-Product View',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _ReportSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            content,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
