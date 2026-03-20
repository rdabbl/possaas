import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _identifierPrefilled = false;
  bool _offlineToggle = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.watch<AuthController>();
    if (_identifierPrefilled) return;
    final recentIdentifier = auth.recentUsers.isNotEmpty
        ? auth.recentUsers.first['identifier']
        : null;
    final label = auth.userLabel?.trim();
    final defaultIdentifier = (recentIdentifier != null &&
            recentIdentifier.isNotEmpty)
        ? recentIdentifier
        : (label != null && label.isNotEmpty ? label : null);
    if (defaultIdentifier != null && defaultIdentifier.isNotEmpty) {
      _identifierController.text = defaultIdentifier;
      _identifierPrefilled = true;
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    _offlineToggle = auth.offlineMode;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Connexion POS',
                              style: Theme.of(context).textTheme.headlineSmall,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            if (auth.recentUsers.isNotEmpty)
                              Column(
                                children: auth.recentUsers.map((user) {
                                  final identifier = user['identifier'] ?? '';
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          _identifierController.text =
                                              identifier.trim();
                                        });
                                        _passwordFocusNode.requestFocus();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Se reconnecter',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium,
                                                  ),
                                                  Text(
                                                    user['displayName'] ??
                                                        user['identifier']!,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline),
                                              tooltip: 'Supprimer le compte',
                                              onPressed: identifier.isEmpty
                                                  ? null
                                                  : () =>
                                                      _handleRemoveAccount(
                                                          identifier),
                                            ),
                                            const Icon(Icons.arrow_forward_ios,
                                                size: 16),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            TextFormField(
                              controller: _identifierController,
                              decoration: const InputDecoration(
                                labelText: 'Email ou nom d\'utilisateur',
                                prefixIcon: Icon(Icons.person_outline),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Identifiant requis';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mot de passe requis';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            if (auth.error != null)
                              Text(
                                auth.error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              title: const Text('Mode hors ligne'),
                              subtitle: const Text(
                                  'Utiliser le cache et différer la synchro'),
                              value: _offlineToggle,
                              onChanged: (value) async {
                                setState(() => _offlineToggle = value);
                                await auth.setOfflineMode(value);
                              },
                            ),
                            const SizedBox(height: 8),
                            FilledButton(
                              onPressed:
                                  auth.isSubmitting ? null : _handleLogin,
                              child: auth.isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Se connecter'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleLogin() {
    final auth = context.read<AuthController>();
    if (_formKey.currentState?.validate() ?? false) {
      auth.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );
    }
  }

  Future<void> _handleRemoveAccount(String identifier) async {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) return;
    await context.read<AuthController>().removeRecentUser(trimmed);
    if (!mounted) return;
    if (_identifierController.text.trim() == trimmed) {
      _identifierController.clear();
      _passwordController.clear();
      _identifierPrefilled = false;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compte supprime localement'),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
