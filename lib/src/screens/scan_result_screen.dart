import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>>? results;

  const ScanResultScreen({super.key, this.results});

  Future<Map<String, dynamic>> _loadDashboardData() async {
    final String response = await rootBundle.loadString('Assets/Data/Input_Dash.json');
    return json.decode(response);
  }

  @override
  Widget build(BuildContext context) {
    final bool isNested = Navigator.canPop(context);

    Widget content = FutureBuilder<Map<String, dynamic>>(
      future: _loadDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading data: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No data found'));
        }

        final data = snapshot.data!;
        final globalSummary = data['global_summary'] ?? {};
        final products = data['product_verdicts'] ?? [];
        final scoringAnalysis = data['scoring_analysis'] ?? {};
        final highestRiskProduct = scoringAnalysis['highest_risk_product'];
        final combinationRisks = data['combination_risks'] ?? {};

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // SECTION 1: KPI CARDS
            _buildKPICards(globalSummary),
            const SizedBox(height: 24),

            // SECTION 2: PRODUCT CARDS
            Center(
              child: Text(
                'Product Analysis',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 280, // Reduced height for smaller cards
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final productScores = (scoringAnalysis['product_risk_results'] as List?)?.firstWhere(
                  (p) => p['product_id'] == product['product_id'],
                  orElse: () => null,
                );
                return _ProductCard(
                  product: product,
                  ingredients: productScores?['ingredient_scores'] ?? [],
                );
              },
            ),
            const SizedBox(height: 24),

            // SECTION 3: COMBINATION RISK
            _buildCombinationRiskCard(combinationRisks),
            const SizedBox(height: 16),

            // SECTION 4: CUMULATIVE RISK
            _buildCumulativeRiskCard(data['unverified_chemicals'] ?? []),
            const SizedBox(height: 16),

            // SECTION 5: PERSONALIZATION REPORT
            _buildPersonalizationSection(data['chemicals_summary'] ?? []),
            const SizedBox(height: 16),

            // SECTION 6: PRODUCT TO CHANGE
            if (highestRiskProduct != null)
              _buildHighestRiskCard(highestRiskProduct, scoringAnalysis['product_risk_results']),

            const SizedBox(height: 40),
          ],
        );
      },
    );

    if (isNested) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            'Health Dashboard',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: content,
      );
    } else {
      // When in AppShell, we don't need another Scaffold/AppBar
      return content;
    }
  }

  Widget _buildKPICards(Map<String, dynamic> summary) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _KPICard(
            icon: Icons.sanitizer_outlined,
            value: '${summary['total_products'] ?? 0}',
            label: 'Products',
            color: Colors.blue[800]!,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KPICard(
            icon: Icons.warning_amber_rounded,
            value: '${summary['products_to_reduce'] ?? 0}',
            label: 'At Risk',
            color: Colors.orange[900]!,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _KPICard(
            icon: Icons.science_outlined,
            value: '${summary['unique_chemicals_found'] ?? 0}',
            label: 'Chemicals',
            color: Colors.purple[800]!,
          ),
        ),
      ],
    );
  }

  Widget _buildCombinationRiskCard(Map<String, dynamic> combinationRisks) {
    final overlapMsg = combinationRisks['organ_overlap_summary'] ?? "No organ overlap detected";
    final bool hasOverlap = overlapMsg.toLowerCase().contains("detected") && !overlapMsg.toLowerCase().contains("no");

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Combination Risk',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  hasOverlap ? Icons.error_outline : Icons.check_circle_outline,
                  color: hasOverlap ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    overlapMsg,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const _RiskBadge(level: 'LOW'),
          ],
        ),
      ),
    );
  }

  Widget _buildCumulativeRiskCard(List unverified) {
    final counts = <String, int>{};
    for (var chem in unverified) {
      counts[chem.toString()] = (counts[chem.toString()] ?? 0) + 1;
    }
    final repeated = counts.entries.where((e) => e.value > 1).map((e) => e.key).toList();
    final bool hasRepeated = repeated.isNotEmpty;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cumulative Risk',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              hasRepeated
                ? 'Repeated exposure detected across products'
                : 'No repeated chemicals detected',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasRepeated)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Chemical: ${repeated.join(", ")}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.indigo[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _RiskBadge(level: hasRepeated ? 'MODERATE' : 'LOW'),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizationSection(List chemicals) {
    // Unique by name to avoid duplicates if same chemical appears in multiple products
    final seenNames = <String>{};
    final personalizedChems = chemicals.where((c) {
      final name = c['name']?.toString() ?? '';
      if (c['personalisation']?['found'] == true && !seenNames.contains(name)) {
        seenNames.add(name);
        return true;
      }
      return false;
    }).toList();

    if (personalizedChems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Personalized Health Insights',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: personalizedChems.asMap().entries.map((entry) {
                final index = entry.key;
                final chem = entry.value;
                final p = chem['personalisation'];
                final kb = p['kb_entry'] ?? {};
                final riskLevel = p['risk_level'] ?? chem['risk_level'] ?? 'UNKNOWN';
                final disease = p['disease_name'] ?? kb['Disease Name'] ?? 'N/A';
                final analysis = p['llm_analysis'] ?? 'No analysis available.';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (index > 0) const Divider(height: 40, thickness: 1.5, color: Colors.black12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chem['name'] ?? 'Unknown Chemical',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[900],
                            ),
                          ),
                        ),
                        _RiskBadge(level: riskLevel),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.medical_information_outlined, size: 20, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Potential Impact: $disease',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.red[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      analysis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: Colors.indigo[700],
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighestRiskCard(Map<String, dynamic> highest, List? allProducts) {
    final String productName = highest['product_name'] ?? 'Unknown';
    final String level = highest['verdict'] ?? 'UNKNOWN';
    final double score = (highest['score'] as num?)?.toDouble() ?? 0.0;

    // Try to find a driver ingredient from the detailed product results
    String? driver;
    if (allProducts != null) {
      final productDetails = allProducts.firstWhere(
        (p) => p['product_id'] == highest['product_id'],
        orElse: () => null,
      );
      if (productDetails != null && productDetails['ingredient_scores'] != null) {
        final List ingredients = productDetails['ingredient_scores'];
        if (ingredients.isNotEmpty) {
          // Sort by score descending to find the main driver
          final sorted = List.from(ingredients)..sort((a, b) => (b['weighted_score'] as num).compareTo(a['weighted_score'] as num));
          driver = sorted.first['name'];
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.priority_high, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Product to change first',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.orange[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              productName,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RiskBadge(level: level),
                Text(
                  'Score: ${score.toStringAsFixed(1)}',
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Recommendation: Reduce use',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (driver != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Main driver: $driver',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KPICard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _KPICard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
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

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final List ingredients;

  const _ProductCard({required this.product, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final String level = product['risk_level'] ?? 'UNKNOWN';
    final String recommendation = product['recommendation'] ?? 'keep';

    // Filter ingredients: MODERATE, LOW, UNKNOWN
    final filteredIngredients = ingredients.where((ing) {
      final l = (ing['danger_level'] ?? '').toString().toUpperCase();
      return l == 'MODERATE' || l == 'LOW' || l == 'UNKNOWN';
    }).toList();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product['product_name'] ?? 'Unknown Product',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            _RiskBadge(level: level, small: true),
            const SizedBox(height: 10),
            Text(
              'Rec: ${recommendation.replaceAll('_', ' ')}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (filteredIngredients.isNotEmpty) ...[
              const Divider(height: 16, color: Colors.black26),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const ClampingScrollPhysics(),
                  itemCount: filteredIngredients.length,
                  itemBuilder: (context, index) {
                    final ing = filteredIngredients[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${ing['name'] ?? 'Unknown'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  final Map<String, dynamic> ingredient;

  const _IngredientTile({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final String name = ingredient['name'] ?? 'Unknown';
    final String level = (ingredient['danger_level'] ?? 'UNKNOWN').toString().toUpperCase();

    // Determine Type
    String type = "Unverified";
    final List justification = ingredient['justification'] ?? [];
    bool isPersonalized = justification.any((j) => j.toString().toLowerCase().contains('personalisation') || j.toString().toLowerCase().contains('profile'));
    bool isKG = justification.any((j) => j.toString().toLowerCase().contains('knowledge graph'));

    if (isPersonalized) type = "Personalized";
    else if (isKG && !justification.any((j) => j.toString().toLowerCase().contains('not found'))) type = "KG verified";

    // Reason
    String reason = justification.isNotEmpty ? justification.first.toString() : "No reason provided";

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: _getRiskColor(level),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    _RiskBadge(level: level, small: true),
                  ],
                ),
                Text(
                  'Type: $type',
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  reason,
                  style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String level;
  final bool small;

  const _RiskBadge({required this.level, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 10,
        vertical: small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getRiskColor(level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getRiskColor(level).withOpacity(0.5)),
      ),
      child: Text(
        level.toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: small ? 11 : 13,
          fontWeight: FontWeight.w800,
          color: _getRiskColor(level),
        ),
      ),
    );
  }
}

Color _getRiskColor(String level) {
  switch (level.toUpperCase()) {
    case 'LOW':
      return Colors.green[800]!;
    case 'MODERATE':
      return Colors.orange[900]!;
    case 'HIGH':
    case 'CRITICAL':
      return Colors.red[900]!;
    case 'UNKNOWN':
    default:
      return Colors.blueGrey[900]!;
  }
}
