import 'dart:io' show File;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../ui/animated_widgets.dart';
import '../ui/transitions.dart';
import '../ui/ui_kit.dart';
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        HighlightBanner(
          title: 'Scanner un produit',
          subtitle:
              'Choisissez une image puis lancez soit une analyse rapide, soit une segmentation pour plusieurs produits.',
          icon: Icons.center_focus_strong_outlined,
          colors: const [AppColors.softBlue, AppColors.softPink],
        ),
        const SizedBox(height: 16),
        _ScanHero(
          selectedImage: _selectedImage,
          isPicking: _isPicking || controller.isBusy,
          onCamera: () => _pickImage(ImageSource.camera),
          onGallery: () => _pickImage(ImageSource.gallery),
          onAnalyze: _selectedImage == null ? null : _openSegmentationFlow,
          onQuickScan: _selectedImage == null ? null : _runQuickScan,
        ),
        const SizedBox(height: 16),
        const _HowItWorksCard(),
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
      result = await _runWithLoading<List<dynamic>?>(
        'Préparation de la segmentation...',
        () => Navigator.of(context).push<List<dynamic>>(
          SlideUpRoute(builder: (_) => SegmentationScreen(imageFile: image)),
        ),
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

    final payload = result.cast<Map<String, dynamic>>();
    context.read<AppController>().setLastScanPayload(payload);
    await showScanResultSheet(context, results: payload);
  }

  Future<void> _runQuickScan() async {
    final image = _selectedImage;
    if (image == null) return;

    final controller = context.read<AppController>();
    try {
      final response = await _runWithLoading(
        'Analyse en cours...',
        () => controller.quickScanImage(image),
      );
      if (!mounted) return;

      final payload = [
        {
          ...(response.analysis ?? <String, dynamic>{}),
          'product_id': response.scanId.toString(),
          'ingredients': response.ingredients,
          'risks': response.risks,
          'recommendations': response.recommendations,
          'cumulative_report': response.cumulativeReport,
        },
      ];

      controller.setLastScanPayload(payload);
      await showScanResultSheet(context, results: payload);
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

  Future<T> _runWithLoading<T>(
    String title,
    Future<T> Function() action,
  ) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LoadingDialog(title: title),
    );
    try {
      return await action();
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
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
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color(0xFFF5EEE8),
              image: selectedImage == null
                  ? null
                  : DecorationImage(
                      image: _xFileImageProvider(selectedImage!),
                      fit: BoxFit.cover,
                    ),
            ),
            child: selectedImage == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulsingDot(
                          color: AppColors.ink.withValues(alpha: 0.35),
                          size: 14,
                        ),
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.camera_enhance_outlined,
                          size: 42,
                          color: AppColors.ink,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Prenez une photo ou importez une image',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
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
                  onPressed: (isPicking || kIsWeb) ? null : onCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: Text(kIsWeb ? 'Camera indisponible' : 'Camera'),
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
            icon: const Icon(Icons.grid_view_rounded),
            label: const Text('Segmenter et selectionner'),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            onPressed: onQuickScan,
            icon: const Icon(Icons.flash_on_outlined),
            label: const Text('Analyse rapide'),
          ),
        ],
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          SectionTitle(
            title: 'Flux de scan',
            subtitle: 'Progression simple, sans surcharge scientifique immediate.',
          ),
          SizedBox(height: 12),
          _StepItem(
            index: '1',
            title: 'Capture ou import',
            subtitle: 'Prenez une photo ou choisissez une image depuis la galerie.',
          ),
          SizedBox(height: 10),
          _StepItem(
            index: '2',
            title: 'Segmentation optionnelle',
            subtitle: 'Le backend renvoie les crops detectes si plusieurs produits sont presents.',
          ),
          SizedBox(height: 10),
          _StepItem(
            index: '3',
            title: 'Decision rapide',
            subtitle: 'Vous obtenez un verdict, des details optionnels et une action immediate.',
          ),
        ],
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
          backgroundColor: AppColors.ink,
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

class _LoadingDialog extends StatefulWidget {
  const _LoadingDialog({required this.title});

  final String title;

  @override
  State<_LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<_LoadingDialog> {
  int _step = 0;
  static const _messages = [
    'Extraction des ingredients',
    'Analyse des risques',
    'Adaptation au profil',
    'Recherche d alternatives',
  ];

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted || _step >= _messages.length - 1) return false;
      setState(() => _step++);
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 8),
            Text(
              _messages[_step],
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
