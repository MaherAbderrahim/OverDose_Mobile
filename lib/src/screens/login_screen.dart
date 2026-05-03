import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  DateTime? _dateOfBirth;
  String _gender = 'male';
  bool _showRegister = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AppController>();
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xAD00D3FF), Color(0xFFF5F1E8), Color(0xFFE0F7FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // _HeroCard(
                //   showRegister: _showRegister,
                //   onToggle: () =>
                //       setState(() => _showRegister = !_showRegister),
                // ),
                const SizedBox(height: 20),
                if (controller.errorMessage != null)
                  _ErrorBanner(message: controller.errorMessage!),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _showRegister
                      ? _buildRegisterForm(context)
                      : _buildLoginForm(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    final controller = context.read<AppController>();

    return Card(
      key: const ValueKey('login'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _loginFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Connexion',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text('Accède à ton profil, tes produits et tes scans.'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _loginEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Email requis'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _loginPasswordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Mot de passe requis'
                    : null,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: controller.isBusy ? null : _submitLogin,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: controller.isBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Text('Se connecter'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showRegister = true),
                child: const Text('Créer un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    final controller = context.read<AppController>();

    return Card(
      key: const ValueKey('register'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _registerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Créer un compte',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              const Text(
                'Un seul compte pour le scan, le profil et les produits.',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
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
                      decoration: const InputDecoration(labelText: 'Nom'),
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
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Email requis'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) => (value == null || value.length < 6)
                    ? '6 caractères minimum'
                    : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: const InputDecoration(labelText: 'Genre'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Homme')),
                  DropdownMenuItem(value: 'female', child: Text('Femme')),
                ],
                onChanged: (value) =>
                    setState(() => _gender = value ?? 'other'),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _pickBirthDate,
                icon: const Icon(Icons.cake_outlined),
                label: Text(
                  _dateOfBirth == null
                      ? 'Date de naissance'
                      : _dateOfBirth!.toIso8601String().split('T').first,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: controller.isBusy ? null : _submitRegister,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: controller.isBusy
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Text('Créer le compte'),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showRegister = false),
                child: const Text('J’ai déjà un compte'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
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

  Future<void> _submitLogin() async {
    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    await context.read<AppController>().login(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );
  }

  Future<void> _submitRegister() async {
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    await context.read<AppController>().register(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: _gender,
      dateOfBirth: _dateOfBirth,
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.showRegister, required this.onToggle});

  final bool showRegister;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF00D2FF), Color(0xFF3AD2FF), Color(0xAD00D3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'Interface mobile pour le scan produit',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Scanner, segmenter, sélectionner et analyser des produits sans friction.',
            style: TextStyle(
              fontSize: 28,
              height: 1.05,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Connexion locale au backend Django avec base URL configurable.',
            style: TextStyle(color: Color(0xFFE1F5FE), height: 1.4),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: onToggle,
            icon: Icon(showRegister ? Icons.login : Icons.person_add_alt_1),
            label: Text(
              showRegister ? 'Revenir à la connexion' : 'Ouvrir l’inscription',
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB53F2F)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFF7F2D21)),
            ),
          ),
        ],
      ),
    );
  }
}
