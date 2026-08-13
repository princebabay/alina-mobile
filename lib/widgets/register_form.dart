import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../types/auth.request.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final nomController = TextEditingController();
  final emailController = TextEditingController();
  final motDePasseController = TextEditingController();
  final confirmationController = TextEditingController();

  String? message;
  bool? isSuccess;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nomController,
          decoration: const InputDecoration(labelText: 'Nom d’utilisateur'),
        ),

        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
        ),

        TextField(
          controller: motDePasseController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Mot de passe'),
        ),

        TextField(
          controller: confirmationController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Confirmation du mot de passe',
          ),
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () async {
            final request = RegisterRequest(
              nomUtilisateur: nomController.text,
              email: emailController.text,
              motDePasse: motDePasseController.text,
              confirmationMotDePasse: confirmationController.text,
            );

            final response = await AuthService.register(request);

            setState(() {
              message = response.message;
              isSuccess = response.success;
            });
          },
          child: const Text('S’inscrire'),
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
