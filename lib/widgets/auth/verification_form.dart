import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../handlers/auth/register_handler.dart';
import '../../types/auth.request.dart';
import '../../types/auth.response.dart';
import '../common/app_button.dart';
import '../common/app_colors.dart';
import '../common/app_message.dart';

class VerificationForm extends StatefulWidget {
  const VerificationForm({
    super.key,
    required this.registration,
    required this.response,
    required this.onAuthenticated,
    required this.onBack,
  });
  final RegisterRequest registration;
  final RegisterResponse response;
  final VoidCallback onAuthenticated;
  final VoidCallback onBack;

  @override
  State<VerificationForm> createState() => _VerificationFormState();
}

class _VerificationFormState extends State<VerificationForm> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _message;
  bool _error = false;

  Future<void> _verify() async {
    if (_busy || _code.text.length != 6) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await RegisterHandler.verify(widget.registration, _code.text);
      if (mounted) widget.onAuthenticated();
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = true;
          _message = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await RegisterHandler.resend(widget.response.email);
      _code.clear();
      if (mounted) {
        setState(() {
          _error = false;
          _message = 'Un nouveau code a été envoyé.';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = true;
          _message = error.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'Saisissez le code à 6 chiffres envoyé à ${widget.response.email}. Valable ${widget.response.validiteMinutes} minutes.',
        style: const TextStyle(color: AppColors.textNormal, height: 1.5),
      ),
      const SizedBox(height: 24),
      TextField(
        controller: _code,
        enabled: !_busy,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        onChanged: (_) => setState(() => _message = null),
        onSubmitted: (_) => _verify(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 28,
          letterSpacing: 10,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: '••••••',
          filled: true,
          fillColor: AppColors.surfaceSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
      if (_message != null) ...[
        const SizedBox(height: 16),
        _error
            ? AppMessage(message: _message!)
            : Text(_message!, style: const TextStyle(color: AppColors.success)),
      ],
      const SizedBox(height: 22),
      AppButton(
        label: 'Valider mon email',
        onPressed: _code.text.length == 6 ? _verify : null,
        loading: _busy,
      ),
      TextButton(
        onPressed: _busy ? null : _resend,
        child: const Text('Renvoyer le code'),
      ),
      TextButton(
        onPressed: _busy ? null : widget.onBack,
        child: const Text("Retour à l’inscription"),
      ),
    ],
  );
}
