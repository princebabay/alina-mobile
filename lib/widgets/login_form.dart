import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../types/auth.request.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final emailController = TextEditingController();
  final motDePasseController = TextEditingController();

  String? message;
  bool? isSuccess;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),

        TextField(
          controller: motDePasseController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () async {
            final request = LoginRequest(
              email: emailController.text,
              motDePasse: motDePasseController.text,
            );

            final response = await AuthService.login(request);

            setState(() {
              message = response.message;
              isSuccess = response.success;
            });
          },
          child: const Text('Se connecter'),
        ),

        if (message != null) ...[
          const SizedBox(height: 15),
          Text(
            message!,
            style: TextStyle(
              color: isSuccess == true ? Colors.green : Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}
