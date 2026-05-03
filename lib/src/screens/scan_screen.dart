import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import 'scan_result_screen.dart';
import 'segmentation_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  XFile? _selectedImage;
  bool _isPicking = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Scan produit',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: _ScanHero(
              selectedImage: _selectedImage,
              isPicking: _isPicking || controller.isBusy,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
              onAnalyze: _selectedImage == null ? null : _openSegmentationFlow,
              onQuickScan: _selectedImage == null ? null : _runQuickScan,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 18)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(child: _HowItWorksCard()),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // La caméra n'est pas disponible sur Flutter Web
    if (kIsWeb && source == ImageSource.camera) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La caméra n\'est pas disponible sur navigateur. Utilisez la galerie.',
            ),
            backgroundColor: Color(0xFF8B6914),
          ),
        );
      }
      return;
    }

    setState(() => _isPicking = true);

    try {
      final file = await _picker.pickImage(source: source, imageQuality: 92);
      if (file != null && mounted) {
        setState(() => _selectedImage = file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection : ${e.toString()}'),
            backgroundColor: const Color(0xFFB53F2F),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPicking = false);
      }
    }
  }

  Future<void> _openSegmentationFlow() async {
    final image = _selectedImage;
    if (image == null) return;

    List<dynamic>? result;
    try {
      result = await Navigator.of(context).push<List<dynamic>>(
        MaterialPageRoute(builder: (_) => SegmentationScreen(imageFile: image)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de segmentation : ${e.toString()}'),
            backgroundColor: const Color(0xFFB53F2F),
          ),
        );
      }
      return;
    }

    if (!mounted || result == null || result.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ScanResultScreen(results: result!.cast<Map<String, dynamic>>()),
      ),
    );
  }

  Future<void> _runQuickScan() async {
    final image = _selectedImage;
    if (image == null) return;

    final controller = context.read<AppController>();
    try {
      final response = await controller.quickScanImage(image);
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            results: [
              {
                ...(response.analysis ?? <String, dynamic>{}),
                'product_id': response.scanId.toString(),
                'ingredients': response.ingredients,
              },
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du scan : ${e.toString()}'),
            backgroundColor: const Color(0xFFB53F2F),
          ),
        );
      }
    }
  }
}

/// Retourne un [ImageProvider] compatible Web et mobile pour un [XFile].
ImageProvider _xFileImageProvider(XFile file) {
  if (kIsWeb) {
    // Sur Web, le path est une blob URL directement utilisable par le navigateur
    return NetworkImage(file.path);
  }
  // Sur mobile/desktop, c'est un chemin système de fichiers
  return FileImage(File(file.path));
}

class _ScanHero extends StatelessWidget {
  const _ScanHero({
    required this.selectedImage,
    required this.isPicking,
    required this.onCamera,
    required this.onGallery,
    required this.onAnalyze,
    required this.onQuickScan,
  });

  final XFile? selectedImage;
  final bool isPicking;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onAnalyze;
  final VoidCallback? onQuickScan;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFF1F7F3),
                image: selectedImage == null
                    ? null
                    : DecorationImage(
                        image: _xFileImageProvider(selectedImage!),
                        fit: BoxFit.cover,
                      ),
              ),
              child: selectedImage == null
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_enhance_outlined,
                            size: 42,
                            color: Color(0xFF12372A),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Prends une photo ou importe une image pour démarrer.',
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    // Désactiver la caméra sur Web
                    onPressed: (isPicking || kIsWeb) ? null : onCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: Text(kIsWeb ? 'Caméra (N/A)' : 'Caméra'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isPicking ? null : onGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galerie'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onAnalyze,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Segmenter et sélectionner'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onQuickScan,
              icon: const Icon(Icons.flash_on_outlined),
              label: const Text('Analyse rapide'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Text(
              'Flux de scan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 12),
            _StepItem(
              index: '1',
              title: 'Capture ou import',
              subtitle: 'Prends une photo ou choisis depuis la galerie.',
            ),
            SizedBox(height: 10),
            _StepItem(
              index: '2',
              title: 'Segmentation',
              subtitle: 'Le backend renvoie les crops détectés dans l\'image.',
            ),
            SizedBox(height: 10),
            _StepItem(
              index: '3',
              title: 'Sélection et analyse',
              subtitle: 'Choisis un ou plusieurs produits puis lance le scan.',
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.index,
    required this.title,
    required this.subtitle,
  });

  final String index;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: const Color(0xFF12372A),
          child: Text(
            index,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}
