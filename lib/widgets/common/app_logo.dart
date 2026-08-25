import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 76, this.compact = true});

  final double size;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final asset = compact
        ? 'assets/images/alina-square.png'
        : 'assets/images/alina.png';
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(compact ? size * .25 : 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .22),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Image.asset(
        asset,
        width: compact ? size : size * 2.2,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
