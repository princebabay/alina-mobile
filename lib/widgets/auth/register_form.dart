import 'package:flutter/material.dart';
import '../../handlers/auth/register_handler.dart';
import '../../types/auth.request.dart';
import '../../types/auth.response.dart';
import '../common/app_button.dart';
import '../common/app_message.dart';
import '../common/app_text_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key, required this.onCodeSent});
  final void Function(RegisterRequest, RegisterResponse) onCodeSent;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_loading) return;
    final registration = RegisterRequest(
      nomUtilisateur: _username.text.trim(),
      email: _email.text.trim(),
      motDePasse: _password.text,
      confirmationMotDePasse: _confirmation.text,
    );
    if (registration.nomUtilisateur.length < 3 ||
        !registration.email.contains('@') ||
        registration.motDePasse.length < 8 ||
        registration.motDePasse != registration.confirmationMotDePasse) {
      setState(
        () => _error =
            'Vérifiez le nom, l’email et les mots de passe (8 caractères minimum).',
      );
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await RegisterHandler.submit(registration);
      if (mounted) widget.onCodeSent(registration, result);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      AppTextField(
        controller: _username,
        icon: Icons.person_outline_rounded,
        label: "Nom d'utilisateur",
        hint: 'Votre pseudo',
        textInputAction: TextInputAction.next,
        enabled: !_loading,
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _email,
        icon: Icons.mail_outline_rounded,
        label: 'Email',
        hint: 'vous@exemple.com',
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        enabled: !_loading,
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _password,
        icon: Icons.lock_outline_rounded,
        label: 'Mot de passe',
        hint: '8 caractères minimum',
        obscureText: true,
        textInputAction: TextInputAction.next,
        enabled: !_loading,
      ),
      const SizedBox(height: 16),
      AppTextField(
        controller: _confirmation,
        icon: Icons.lock_reset_rounded,
        label: 'Confirmer le mot de passe',
        hint: 'Répétez le mot de passe',
        obscureText: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        enabled: !_loading,
      ),
      if (_error != null) ...[
        const SizedBox(height: 16),
        AppMessage(message: _error!),
      ],
      const SizedBox(height: 24),
      AppButton(
        label: 'Recevoir le code',
        onPressed: _submit,
        loading: _loading,
      ),
    ],
  );
}
