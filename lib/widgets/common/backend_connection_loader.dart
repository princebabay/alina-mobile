import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_logo.dart';

class BackendConnectionLoader extends StatelessWidget {
  const BackendConnectionLoader({
    super.key,
    this.message = 'Connexion au backend...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: AppColors.textNormal, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
