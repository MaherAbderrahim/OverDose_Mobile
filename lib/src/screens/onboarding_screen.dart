import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../ui/ui_kit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _userType = '';
  final Set<int> _selectedAllergies = <int>{};
  final _newAllergyController = TextEditingController();

  @override
  void dispose() {
    _newAllergyController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.read<AppController>();
    if (_userType.isEmpty) {
      _userType = controller.currentUser?.userType ?? '';
      _selectedAllergies
        ..clear()
        ..addAll(controller.selectedAllergyIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final options = const [
      ('adult', 'Adulte'),
      ('pregnant', 'Grossesse'),
      ('child', 'Enfant'),
      ('sensitive_skin', 'Peau sensible'),
      ('athlete', 'Sportif'),
      ('other', 'Autre'),
    ];

    return Scaffold(
      body: Container(
        decoration: buildPageBackground(),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: controller.isBusy
                      ? null
                      : () => context.read<AppController>().skipOnboarding(),
                  child: const Text('Passer'),
                ),
              ),
              HighlightBanner(
                title: 'Personnalise votre experience',
                subtitle:
                    'Choisissez votre profil principal et vos allergies pour obtenir des analyses plus utiles des le dashboard et le scan.',
                icon: Icons.tune,
                colors: const [AppColors.softBlue, AppColors.softPink],
              ),
              const SizedBox(height: 20),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      title: 'Votre profil sante',
                      subtitle: 'Un seul choix principal pour demarrer.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: options
                          .map(
                            (item) => ChoiceChip(
                              label: Text(item.$2),
                              selected: _userType == item.$1,
                              onSelected: controller.isBusy
                                  ? null
                                  : (_) => setState(() => _userType = item.$1),
                            ),
                          )
                          .toList(),
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
                      title: 'Allergies et sensibilites',
                      subtitle: 'Vous pouvez tout selectionner ou laisser vide.',
                    ),
                    const SizedBox(height: 16),
                    if (controller.allergies.isEmpty)
                      const Text('Aucune allergie disponible pour le moment.')
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: controller.allergies
                            .map(
                              (allergy) => FilterChip(
                                label: Text(allergy.name),
                                selected: _selectedAllergies.contains(allergy.id),
                                onSelected: controller.isBusy
                                    ? null
                                    : (selected) => setState(() {
                                        if (selected) {
                                          _selectedAllergies.add(allergy.id);
                                        } else {
                                          _selectedAllergies.remove(allergy.id);
                                        }
                                      }),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newAllergyController,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              labelText: 'Ajouter une allergie',
                              hintText: 'Ex. arachide, soja, diabète',
                            ),
                            onSubmitted: (_) => _addAllergy(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: controller.isBusy ? null : () => _addAllergy(context),
                          child: const Text('Ajouter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: controller.isBusy ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: controller.isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_userType.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un profil principal ou utilisez Passer.')),
      );
      return;
    }

    try {
      await context.read<AppController>().completeOnboarding(
        userType: _userType,
        allergyIds: _selectedAllergies.toList(),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Impossible de terminer l onboarding: $error')));
    }
  }

  Future<void> _addAllergy(BuildContext context) async {
    final controller = context.read<AppController>();
    final rawName = _newAllergyController.text.trim();
    if (rawName.isEmpty) {
      return;
    }

    try {
      final allergy = await controller.createAllergy(rawName);
      if (!context.mounted) {
        return;
      }
      setState(() {
        _selectedAllergies.add(allergy.id);
        _newAllergyController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Allergie ajoutée : ${allergy.name}'),
          backgroundColor: const Color(0xFF12372A),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ajouter l\'allergie : $error'),
          backgroundColor: const Color(0xFFB53F2F),
        ),
      );
    }
  }
}
