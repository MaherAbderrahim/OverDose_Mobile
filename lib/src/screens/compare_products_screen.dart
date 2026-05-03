import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'compare_lists_screen.dart';

class CompareProductsScreen extends StatefulWidget {
  const CompareProductsScreen({super.key});

  @override
  State<CompareProductsScreen> createState() => _CompareProductsScreenState();
}

class _CompareProductsScreenState extends State<CompareProductsScreen> {
  late List<ComparisonProduct> listA;
  late List<ComparisonProduct> listB;
  ComparisonProduct? currentA;
  ComparisonProduct? currentB;

  @override
  void initState() {
    super.initState();
    // Replicating lists from CompareListsScreen for demo
    listA = [
      ComparisonProduct(name: 'Red Matte Lipstick', category: 'Cosmetics', toxicity: ToxicityLevel.high),
      ComparisonProduct(name: 'Full Coverage Foundation', category: 'Cosmetics', toxicity: ToxicityLevel.high),
      ComparisonProduct(name: 'Instant Noodles (Spicy)', category: 'Food', toxicity: ToxicityLevel.high),
      ComparisonProduct(name: 'Sunscreen SPF 50', category: 'Cosmetics', toxicity: ToxicityLevel.moderate),
      ComparisonProduct(name: 'Potato Chips (Classic)', category: 'Food', toxicity: ToxicityLevel.moderate),
      ComparisonProduct(name: 'Hair Color (Dark Brown)', category: 'Cosmetics', toxicity: ToxicityLevel.moderate),
      ComparisonProduct(name: 'Energy Drink', category: 'Food', toxicity: ToxicityLevel.high),
      ComparisonProduct(name: 'Acne Face Wash', category: 'Cosmetics', toxicity: ToxicityLevel.moderate),
    ];

    listB = [
      ComparisonProduct(name: 'Natural Lip Balm', category: 'Cosmetics', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Mineral Foundation', category: 'Cosmetics', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Organic Oatmeal', category: 'Food', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Sunscreen SPF 30 (Mineral)', category: 'Cosmetics', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Air Popped Popcorn', category: 'Food', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Herbal Shampoo', category: 'Cosmetics', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Coconut Water', category: 'Food', toxicity: ToxicityLevel.low),
      ComparisonProduct(name: 'Gentle Face Cleanser', category: 'Cosmetics', toxicity: ToxicityLevel.low),
    ];

    currentA = listA[0];
    currentB = listB[0];
  }

  void _selectProductA(ComparisonProduct p) {
    setState(() {
      currentA = p;
      // Auto-find matching category in List B
      currentB = listB.firstWhere(
        (item) => item.category == p.category,
        orElse: () => listB[0],
      );
    });
  }

  void _selectProductB(ComparisonProduct p) {
    setState(() {
      currentB = p;
      // Auto-find matching category in List A
      currentA = listA.firstWhere(
        (item) => item.category == p.category,
        orElse: () => listA[0],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Compare Products',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Selection Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _ProductDropdown(
                      selected: currentA!,
                      options: listA,
                      onSelected: _selectProductA,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('vs', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: _ProductDropdown(
                      selected: currentB!,
                      options: listB,
                      onSelected: _selectProductB,
                    ),
                  ),
                ],
              ),
            ),

            // Comparison Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _ComparisonCard(
                        isGood: false,
                        product: currentA!,
                        rating: '4.5/5',
                        reviews: '1,250 reviews',
                        price: '\$25.00',
                        pros: ['High quality materials', 'Long battery life', 'Good customer reviews'],
                        cons: ['Slightly expensive'],
                        explanation: 'This product performs well because it uses durable components and has consistent user satisfaction over time.',
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ComparisonCard(
                        isGood: true,
                        product: currentB!,
                        rating: '2.8/5',
                        reviews: '620 reviews',
                        price: '\$20.00',
                        pros: ['Affordable'],
                        cons: ['Poor durability', 'Low battery life', 'Negative reviews'],
                        explanation: 'This product is less reliable due to weak build quality and frequent complaints from users regarding performance issues.',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Comparison Table
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bar_chart, color: Colors.indigo, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Quick Comparison',
                        style: GoogleFonts.spaceGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ComparisonTable(productA: currentA!, productB: currentB!),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom buttons
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => _DeepComparisonBottomSheet(
                productA: currentA!,
                productB: currentB!,
              ),
            );
          },
          icon: const Icon(Icons.visibility_outlined),
          label: const Text('View Deep Comparison Details'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _ProductDropdown extends StatelessWidget {
  final ComparisonProduct selected;
  final List<ComparisonProduct> options;
  final Function(ComparisonProduct) onSelected;

  const _ProductDropdown({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ComparisonProduct>(
      onSelected: onSelected,
      itemBuilder: (context) => options.map((p) => PopupMenuItem(
        value: p,
        child: Text(p.name, style: GoogleFonts.spaceGrotesk(fontSize: 12)),
      )).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                selected.category == 'Food' ? Icons.fastfood_outlined : Icons.brush_outlined,
                size: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  final bool isGood;
  final ComparisonProduct product;
  final String rating;
  final String reviews;
  final String price;
  final List<String> pros;
  final List<String> cons;
  final String explanation;
  final Color color;

  const _ComparisonCard({
    required this.isGood,
    required this.product,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.pros,
    required this.cons,
    required this.explanation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final lightColor = color.withOpacity(0.05);
    final borderColor = color.withOpacity(0.3);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isGood ? Icons.check_circle : Icons.cancel, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  isGood ? 'GOOD CHOICE' : 'BAD CHOICE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          // Image PlaceHolder
          Container(
            height: 120,
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              product.category == 'Food' ? Icons.fastfood_outlined : Icons.brush_outlined,
              size: 64,
              color: Colors.black54,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' ($reviews)',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: GoogleFonts.spaceGrotesk(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Divider(height: 24),

                // Pros
                _BulletList(title: 'Pros', items: pros, icon: Icons.thumb_up_alt_outlined, color: Colors.green),
                const SizedBox(height: 16),

                // Cons
                _BulletList(title: 'Cons', items: cons, icon: Icons.thumb_down_alt_outlined, color: Colors.red),
                const SizedBox(height: 16),

                // Explanation
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            'Explanation',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        explanation,
                        style: const TextStyle(fontSize: 10, height: 1.4, color: Colors.black87),
                      ),
                    ],
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

class _BulletList extends StatelessWidget {
  final String title;
  final List<String> items;
  final IconData icon;
  final Color color;

  const _BulletList({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(color: Colors.grey)),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  final ComparisonProduct productA;
  final ComparisonProduct productB;

  const _ComparisonTable({required this.productA, required this.productB});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        children: [
          _buildHeaderRow(),
          _buildDataRow('Toxicity', productA.toxicity.label, productB.toxicity.label, isCheck: true),
          _buildDataRow('Price', 'Higher', 'Lower', isCheck: true, inverse: true),
          _buildDataRow('Eco-Friendly', 'Moderate', 'High', isCheck: true),
          _buildDataRow('Rating', '4.5 / 5', '2.8 / 5', isStar: true),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      children: [
        _tableCell('Feature', isHeader: true),
        _tableCell('List A Item', isHeader: true, color: Colors.red),
        _tableCell('List B Item', isHeader: true, color: Colors.green),
      ],
    );
  }

  TableRow _buildDataRow(String feature, String valA, String valB, {bool isCheck = false, bool isStar = false, bool inverse = false}) {
    return TableRow(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
      children: [
        _tableCell(feature),
        _tableCell(valA, isData: true, icon: isCheck ? (inverse ? Icons.cancel : Icons.warning_amber_rounded) : (isStar ? Icons.star : null), color: Colors.red),
        _tableCell(valB, isData: true, icon: isCheck ? (inverse ? Icons.check_circle : Icons.check_circle) : (isStar ? Icons.star : null), color: Colors.green),
      ],
    );
  }

  Widget _tableCell(String text, {bool isHeader = false, bool isData = false, IconData? icon, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: isHeader ? Colors.grey.shade50 : null,
      child: Row(
        mainAxisAlignment: isHeader ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color ?? (icon == Icons.star ? Colors.amber : Colors.grey)),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                color: color ?? (isHeader ? Colors.black87 : Colors.black54),
              ),
              textAlign: isHeader ? TextAlign.center : TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeepComparisonBottomSheet extends StatelessWidget {
  final ComparisonProduct productA;
  final ComparisonProduct productB;

  const _DeepComparisonBottomSheet({
    required this.productA,
    required this.productB,
  });

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
                  'Deep Details Comparison',
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
                _DeepDetailSection(
                  title: 'Ingredient Safety Analysis',
                  content: 'Comparing the core ingredients of both products:\n\n'
                      '**${productA.name} (Risk Factor):** Contains synthetic preservatives and colorants. Analysis shows trace amounts of heavy metals and petroleum-derived waxes which can block skin pores and lead to irritation.\n\n'
                      '**${productB.name} (Safety Choice):** Formulated with plant-based emollients and organic extracts. Uses cold-pressed oils that maintain nutritional value and provide natural hydration without chemical residues.',
                ),
                const SizedBox(height: 24),
                _DeepDetailSection(
                  title: 'Long-term Health Impact',
                  content: 'Research suggests that continued use of ${productA.name} might expose the user to endocrine disruptors. In contrast, ${productB.name} uses bio-identical ingredients that are easily processed by the body, significantly reducing the cumulative toxic load.\n\n'
                      '**Clinical Recommendation:** Switching to ${productB.name} is advised for individuals with sensitive skin or those looking to minimize synthetic chemical exposure.',
                ),
                const SizedBox(height: 24),
                _DeepDetailSection(
                  title: 'Environmental Sustainability',
                  content: 'Beyond personal health, the production of ${productB.name} follows ethical sourcing and uses 100% recyclable packaging. ${productA.name} involves intensive industrial processing with a higher carbon footprint and non-biodegradable components.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeepDetailSection extends StatelessWidget {
  final String title;
  final String content;

  const _DeepDetailSection({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
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
