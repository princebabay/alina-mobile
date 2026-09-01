import 'package:flutter/material.dart';

import '../handlers/home_handler.dart';
import '../widgets/common/app_button.dart';
import '../widgets/common/app_colors.dart';
import '../widgets/common/app_logo.dart';
import '../widgets/common/app_message.dart';
import '../widgets/home/session_code_field.dart';
import 'auth_screen.dart';
import 'salle_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _code = '';
  bool _joining = false;
  bool _disconnecting = false;
  String? _error;

  bool get _isBusy => _joining || _disconnecting;

  Future<void> _joinRoom() async {
    if (_isBusy) return;
    setState(() { _joining = true; _error = null; });
    final error = await HomeHandler.joinRoom(code: _code);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SalleScreen()));
      return;
    }
    setState(() { _joining = false; _error = error; });
  }

  Future<void> _disconnect() async {
    if (_isBusy) return;
    setState(() { _disconnecting = true; _error = null; });
    final disconnected = await HomeHandler.deconnexion();
    if (!mounted) return;
    if (disconnected) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
      return;
    }
    setState(() {
      _disconnecting = false;
      _error = 'La déconnexion a échoué. Veuillez réessayer.';
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Rejoindre une session',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Saisissez le code à 6 caractères partagé par votre salle.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textNormal,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 30),
                    SessionCodeField(
                      enabled: !_isBusy,
                      onChanged: (code) => setState(() {
                        _code = code;
                        _error = null;
                      }),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 18),
                      AppMessage(message: _error!),
                    ],
                    const SizedBox(height: 26),
                    AppButton(
                      label: 'Rejoindre une session',
                      onPressed: _code.length == 6 ? _joinRoom : null,
                      loading: _joining,
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      label: 'Se déconnecter',
                      onPressed: _isBusy ? null : _disconnect,
                      loading: _disconnecting,
                      variant: AppButtonVariant.ghost,
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
