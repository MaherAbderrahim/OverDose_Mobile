import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../models.dart';
import '../ui/ui_kit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();
  final _newAllergyController = TextEditingController();


  DateTime? _dateOfBirth;
  String _gender = 'male';
  String _userType = '';
  int? _initializedUserId;
  final Set<int> _selectedAllergyIds = <int>{};
  bool _isEditing = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    _newAllergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    final user = controller.currentUser;

    if (user != null && _initializedUserId != user.id) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _notesController.text = user.notes;
      _dateOfBirth = user.dateOfBirth;
      _gender = user.gender.isEmpty ? 'male' : user.gender;
      _userType = user.userType;
      _selectedAllergyIds
        ..clear()
        ..addAll(controller.selectedAllergyIds);
      _initializedUserId = user.id;
    }

    if (!_isEditing) {
      return _buildReadView(user, controller);
    }
    return _buildEditView(user, controller);
  }

  Widget _buildReadView(AppUser? user, AppController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        HighlightBanner(
          title: 'Mon Profil',
          subtitle: 'Consultez vos informations personnelles et votre contexte de sante.',
          icon: Icons.person_outline_rounded,
          colors: const [AppColors.softBlue, AppColors.softPink],
        ),
        const SizedBox(height: 16),
        _ProfileHeader(user: user),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
                title: 'Informations',
                subtitle: 'Donnees principales du compte',
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Prenom', user?.firstName ?? '-'),
              const SizedBox(height: 8),
              _buildInfoRow('Nom', user?.lastName ?? '-'),
              const SizedBox(height: 8),
              _buildInfoRow('Email', user?.email ?? '-'),
              const SizedBox(height: 8),
              _buildInfoRow('Date de naissance', user?.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(user!.dateOfBirth!) : '-'),
              const SizedBox(height: 8),
              _buildInfoRow('Genre', _formatGender(user?.gender ?? '')),
              const SizedBox(height: 8),
              _buildInfoRow('Profil sante', user?.userTypeLabel ?? '-'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
                title: 'Allergies et Notes',
                subtitle: 'Votre contexte',
              ),
              const SizedBox(height: 16),
              if (controller.selectedAllergyIds.isEmpty)
                const Text('Aucune allergie renseignee', style: TextStyle(color: AppColors.muted))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.allergies
                      .where((a) => controller.selectedAllergyIds.contains(a.id))
                      .map((a) => Chip(
                            label: Text(a.name),
                            backgroundColor: AppColors.softBlue.withValues(alpha: 0.1),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
              if (user != null && user.notes.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Autres informations', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text(user.notes, style: const TextStyle(color: AppColors.muted)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => setState(() => _isEditing = true),
          icon: const Icon(Icons.edit_outlined),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Modifier le profil'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.muted)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _formatGender(String gender) {
    return switch (gender) {
      'male' => 'Homme',
      'female' => 'Femme',
      'other' => 'Autre',
      'prefer_not_to_say' => 'Non precise',
      _ => '-',
    };
  }

  Widget _buildEditView(AppUser? user, AppController controller) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      children: [
        HighlightBanner(
          title: 'Edition du Profil',
          subtitle:
              'Edition simple de vos informations, de votre profil sante et de vos allergies.',
          icon: Icons.edit_note_rounded,
          colors: const [AppColors.softPink, AppColors.softBlue],
        ),
        const SizedBox(height: 16),
        _ProfileHeader(user: user),
        const SizedBox(height: 16),
        GlassCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionTitle(
                  title: 'Informations personnelles',
                  subtitle: 'Mode edition unique avec sauvegarde atomique.',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'Prenom'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Prenom requis'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Nom requis'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Email requis' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(labelText: 'Genre'),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Homme')),
                    DropdownMenuItem(value: 'female', child: Text('Femme')),
                    DropdownMenuItem(value: 'other', child: Text('Autre')),
                    DropdownMenuItem(
                      value: 'prefer_not_to_say',
                      child: Text('Ne pas preciser'),
                    ),
                  ],
                  onChanged: (value) => setState(() => _gender = value ?? 'male'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _userType.isEmpty ? null : _userType,
                  decoration: const InputDecoration(labelText: 'Profil sante'),
                  items: const [
                    DropdownMenuItem(value: 'adult', child: Text('Adulte')),
                    DropdownMenuItem(value: 'pregnant', child: Text('Grossesse')),
                    DropdownMenuItem(value: 'child', child: Text('Enfant')),
                    DropdownMenuItem(
                      value: 'sensitive_skin',
                      child: Text('Peau sensible'),
                    ),
                    DropdownMenuItem(value: 'athlete', child: Text('Sportif')),
                    DropdownMenuItem(value: 'other', child: Text('Autre')),
                  ],
                  onChanged: (value) => setState(() => _userType = value ?? ''),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _pickDateOfBirth,
                  icon: const Icon(Icons.cake_outlined),
                  label: Text(
                    _dateOfBirth == null
                        ? 'Date de naissance'
                        : DateFormat('dd/MM/yyyy').format(_dateOfBirth!),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionTitle(
                title: 'Allergies et notes',
                subtitle: 'Vous pouvez selectionner vos allergies et enrichir votre contexte.',
              ),
              const SizedBox(height: 14),
              if (controller.allergies.isEmpty)
                const Chip(label: Text('Liste vide'))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.allergies
                      .map(
                        (allergy) => FilterChip(
                          label: Text(allergy.name),
                          selected: _selectedAllergyIds.contains(allergy.id),
                          onSelected: controller.isBusy
                              ? null
                              : (selected) => setState(() {
                                  if (selected) {
                                    _selectedAllergyIds.add(allergy.id);
                                  } else {
                                    _selectedAllergyIds.remove(allergy.id);
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
                        hintText: 'Ex. arachide, soja, kiwi',
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Autres informations',
                  hintText:
                      'Ex. je suis sensible aux parfums forts, je suis vegetarien...',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.isBusy ? null : () {
                  setState(() {
                    _isEditing = false;
                    _initializedUserId = null; // force reload from user
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Annuler'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: controller.isBusy ? null : _save,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: controller.isBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      initialDate: _dateOfBirth ?? DateTime(now.year - 20),
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
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
        _selectedAllergyIds.add(allergy.id);
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final controller = context.read<AppController>();
    final current = controller.currentUser;
    if (current == null) {
      return;
    }

    final updatedUser = current.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      userType: _userType,
      gender: _gender,
      dateOfBirth: _dateOfBirth,
      notes: _notesController.text.trim(),
    );

    await controller.saveProfilePreferences(
      updatedUser: updatedUser,
      allergyIds: _selectedAllergyIds.toList(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil et allergies enregistrés.'),
        backgroundColor: Color(0xFF12372A),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.ink,
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Profil non connecte',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? 'Connectez-vous pour synchroniser les donnees'),
                const SizedBox(height: 4),
                Text(
                  user?.userTypeLabel ?? 'A definir',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
