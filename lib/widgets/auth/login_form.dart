import 'package:flutter/material.dart';

import '../../handlers/auth/login_handler.dart';
import '../../services/session_service.dart';
import '../common/app_button.dart';
import '../common/app_message.dart';
import '../common/app_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onAuthenticated});
  final VoidCallback onAuthenticated;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_loading) return;
    debugPrint('[LoginForm] Connexion demandée');
    setState(() { _loading = true; _error = null; });
    final error = await LoginHandler.submit(email: _emailController.text.trim(), motDePasse: _passwordController.text);
    if (!mounted) return;
    if (error == null) {
      await SessionService.synchronizePendingDisconnections();
      if (!mounted) return;
      debugPrint('[LoginForm] Navigation vers Home');
      widget.onAuthenticated();
      return;
    }
    debugPrint('[LoginForm] Connexion échouée: $error');
    setState(() { _loading = false; _error = error; });
  }

  @override
  void dispose() { _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Column(children: [
    AppTextField(controller: _emailController, label: 'Email', hint: 'vous@exemple.com', keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, enabled: !_loading),
    const SizedBox(height: 18),
    AppTextField(controller: _passwordController, label: 'Mot de passe', hint: 'Votre mot de passe', obscureText: true, textInputAction: TextInputAction.done, onSubmitted: (_) => _submit(), enabled: !_loading),
    if (_error != null) ...[const SizedBox(height: 18), AppMessage(message: _error!)],
    const SizedBox(height: 26),
    AppButton(label: 'Se connecter', onPressed: _submit, loading: _loading),
  ]);
}
