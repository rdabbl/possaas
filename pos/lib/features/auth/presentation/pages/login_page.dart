import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state/auth_controller.dart';
import 'package:pos_nimirik/core/i18n/i18n.dart';

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
    final defaultIdentifier =
        (recentIdentifier != null && recentIdentifier.isNotEmpty)
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
    final accent = const Color(0xFFF7C045);
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEFEFEF)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: accent,
                                    child: Text(
                                      tr('POS'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    tr('Connexion POS'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              if (auth.recentUsers.isNotEmpty)
                                Column(
                                  children: auth.recentUsers.map((user) {
                                    final identifier = user['identifier'] ?? '';
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
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
                                            color: const Color(0xFFF3F4F6),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: accent,
                                                child: const Icon(
                                                  Icons.person,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      tr('Se reconnecter'),
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
                                                tooltip:
                                                    tr('Supprimer le compte'),
                                                onPressed: identifier.isEmpty
                                                    ? null
                                                    : () =>
                                                        _handleRemoveAccount(
                                                            identifier),
                                              ),
                                              const Icon(
                                                  Icons.arrow_forward_ios,
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
                                decoration: InputDecoration(
                                  labelText: tr('Nom d\'utilisateur'),
                                  prefixIcon: const Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF7C045)),
                                  ),
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
                                  labelText: tr('PIN POS (4 chiffres)'),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  filled: true,
                                  fillColor: const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFF7C045)),
                                  ),
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
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'PIN requis';
                                  }
                                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                                    return 'PIN invalide (4 chiffres)';
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
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: const Color(0xFFE5E7EB)),
                                ),
                                child: SwitchListTile(
                                  title: Text(tr('Mode hors ligne')),
                                  subtitle: Text(tr(
                                      'Utiliser le cache et différer la synchro')),
                                  value: _offlineToggle,
                                  onChanged: (value) async {
                                    setState(() => _offlineToggle = value);
                                    await auth.setOfflineMode(value);
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: accent,
                                  foregroundColor: Colors.black,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed:
                                    auth.isSubmitting ? null : _handleLogin,
                                child: auth.isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : Text(
                                        tr('Se connecter'),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ],
                          ),
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
      debugPrint(
        '[LoginPage] Login tapped. identifier="${_identifierController.text.trim()}" offlineMode=${auth.offlineMode}',
      );
      auth.login(
        _identifierController.text.trim(),
        _passwordController.text,
      );
    } else {
      debugPrint('[LoginPage] Login validation failed.');
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
      SnackBar(
        content: Text(tr('Compte supprime localement')),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
