import 'package:flutter/material.dart';

import '../../handlers/auth/register_handler.dart';
import '../../services/session_service.dart';
import '../common/app_button.dart';
import '../common/app_message.dart';
import '../common/app_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.onAuthenticated});
  final VoidCallback onAuthenticated;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_loading) return;
    debugPrint('[RegisterForm] Inscription demandée');
    setState(() { _loading = true; _error = null; });
    final error = await RegisterHandler.submit(nomUtilisateur: _usernameController.text.trim(), email: _emailController.text.trim(), motDePasse: _passwordController.text, confirmationMotDePasse: _confirmationController.text);
    if (!mounted) return;
    if (error == null) {
      await SessionService.synchronizePendingDisconnections();
      if (!mounted) return;
      debugPrint('[RegisterForm] Navigation vers Home');
      widget.onAuthenticated();
      return;
    }
    debugPrint('[RegisterForm] Inscription échouée: $error');
    setState(() { _loading = false; _error = error; });
  }

  @override
  void dispose() { _usernameController.dispose(); _emailController.dispose(); _passwordController.dispose(); _confirmationController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    AppTextField(controller: _usernameController, label: "Nom d'utilisateur", hint: 'Votre pseudo', textInputAction: TextInputAction.next, enabled: !_loading),
    const SizedBox(height: 16),
    AppTextField(controller: _emailController, label: 'Email', hint: 'vous@exemple.com', keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, enabled: !_loading),
    const SizedBox(height: 16),
    AppTextField(controller: _passwordController, label: 'Mot de passe', hint: 'Choisissez un mot de passe', obscureText: true, textInputAction: TextInputAction.next, enabled: !_loading),
    const SizedBox(height: 16),
    AppTextField(controller: _confirmationController, label: 'Confirmation', hint: 'Confirmez le mot de passe', obscureText: true, textInputAction: TextInputAction.done, onSubmitted: (_) => _submit(), enabled: !_loading),
    if (_error != null) ...[const SizedBox(height: 18), AppMessage(message: _error!)],
    const SizedBox(height: 26),
    AppButton(label: "S'inscrire", onPressed: _submit, loading: _loading),
  ]);
}
