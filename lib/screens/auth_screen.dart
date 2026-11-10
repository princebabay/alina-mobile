import 'package:flutter/material.dart';

import '../handlers/auth/login_handler.dart';
import '../widgets/auth/login_form.dart';
import '../widgets/auth/register_form.dart';
import '../widgets/auth/verification_form.dart';
import '../types/auth.request.dart';
import '../types/auth.response.dart';
import '../widgets/common/app_colors.dart';
import '../widgets/common/app_logo.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  RegisterRequest? _pendingRegistration;
  RegisterResponse? _registrationResponse;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    debugPrint('[AuthScreen] Vérification de la session');
    final needsAuthentication = await LoginHandler.initialize();
    if (!mounted) return;
    if (!needsAuthentication) {
      debugPrint('[AuthScreen] Session restaurée, navigation vers Home');
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      return;
    }
    debugPrint('[AuthScreen] Affichage de l’authentification');
    setState(() => _initializing = false);
  }

  void _goHome() => Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    final verifying =
        _pendingRegistration != null && _registrationResponse != null;
    final title = verifying
        ? 'Vérifiez votre email'
        : _isLogin
        ? 'Bon retour parmi nous'
        : 'Créez votre compte';
    final subtitle = verifying
        ? 'Saisissez le code reçu pour activer votre compte.'
        : _isLogin
        ? 'Connectez-vous pour rejoindre une room.'
        : 'Rejoignez Alina en quelques instants.';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo()),
                    const SizedBox(height: 28),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textNormal,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: _isLogin
                          ? LoginForm(
                              key: const ValueKey('login'),
                              onAuthenticated: _goHome,
                            )
                          : verifying
                          ? VerificationForm(
                              key: const ValueKey('verification'),
                              registration: _pendingRegistration!,
                              response: _registrationResponse!,
                              onAuthenticated: _goHome,
                              onBack: () => setState(() {
                                _pendingRegistration = null;
                                _registrationResponse = null;
                              }),
                            )
                          : RegisterForm(
                              key: const ValueKey('register'),
                              onCodeSent: (registration, response) =>
                                  setState(() {
                                    _pendingRegistration = registration;
                                    _registrationResponse = response;
                                  }),
                            ),
                    ),
                    const SizedBox(height: 24),
                    if (!verifying)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'Pas encore de compte ?'
                                : 'Déjà inscrit ?',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                setState(() => _isLogin = !_isLogin),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryLight,
                            ),
                            child: Text(
                              _isLogin ? "S'inscrire" : 'Se connecter',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
