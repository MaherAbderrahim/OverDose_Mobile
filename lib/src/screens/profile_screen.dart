import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../models.dart';

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
  int? _initializedUserId;
  final Set<int> _selectedAllergyIds = <int>{};

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
      _selectedAllergyIds
        ..clear()
        ..addAll(controller.selectedAllergyIds);
      _initializedUserId = user.id;
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          sliver: SliverToBoxAdapter(
            child: Text(
              'Profil',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(child: _ProfileHeader(user: user)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Informations personnelles',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Prénom',
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
                                  ? 'Prénom requis'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom',
                              ),
                              validator: (value) =>
                                  (value == null || value.trim().isEmpty)
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
                            (value == null || value.trim().isEmpty)
                            ? 'Email requis'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _gender,
                        decoration: const InputDecoration(labelText: 'Genre'),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Homme')),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text('Femme'),
                          ),
                          DropdownMenuItem(
                            value: 'other',
                            child: Text('Autre'),
                          ),
                          DropdownMenuItem(
                            value: 'prefer_not_to_say',
                            child: Text('Ne pas préciser'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _gender = value ?? 'male'),
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
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Allergies',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.allergies.isEmpty
                          ? 'Aucune allergie enregistrée pour le moment.'
                          : 'Sélectionne toutes les allergies qui te concernent.',
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
                                selected: _selectedAllergyIds.contains(
                                  allergy.id,
                                ),
                                onSelected: controller.isBusy
                                    ? null
                                    : (selected) => setState(() {
                                        if (selected) {
                                          _selectedAllergyIds.add(allergy.id);
                                        } else {
                                          _selectedAllergyIds.remove(
                                            allergy.id,
                                          );
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
                          onPressed: controller.isBusy
                              ? null
                              : () => _addAllergy(context),
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
                            'Ex. je suis sensible aux parfums forts, je suis végétarien...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
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
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5FE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person_outline,
                color: Color(0xFF00D2FF),
                size: 32,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Profil non connecté',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Connecte-toi pour synchroniser les données',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
