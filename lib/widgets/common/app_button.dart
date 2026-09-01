import 'package:flutter/material.dart';

import 'app_colors.dart';

enum AppButtonVariant { primary, secondary, ghost, danger, success }

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.label, required this.onPressed, this.loading = false, this.variant = AppButtonVariant.primary});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final colors = switch (variant) {
      AppButtonVariant.primary => const [Color(0xFFFF5AA8), AppColors.primaryDark],
      AppButtonVariant.danger => const [Color(0xFFFF7783), AppColors.danger],
      AppButtonVariant.success => const [Color(0xFF63C99C), AppColors.success],
      _ => const [AppColors.surfaceTertiary, AppColors.surfaceTertiary],
    };
    final isGhost = variant == AppButtonVariant.ghost;
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isGhost ? null : LinearGradient(colors: colors),
          color: isGhost ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(14),
          border: isGhost ? Border.all(color: AppColors.border) : null,
          boxShadow: enabled && variant == AppButtonVariant.primary ? [BoxShadow(color: AppColors.primary.withValues(alpha: .2), blurRadius: 16)] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 52,
              child: Center(
                child: loading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)) : Text(label, style: TextStyle(color: isGhost ? AppColors.textPrimary : Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
