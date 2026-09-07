import 'package:flutter/material.dart';

import '../common/app_colors.dart';
import '../common/app_logo.dart';

class RoomHeader extends StatelessWidget {
  const RoomHeader({
    super.key,
    required this.isConnected,
    required this.isLive,
    required this.isFullscreen,
    required this.onFullscreenPressed,
    required this.onLeavePressed,
    required this.isLeaving,
  });

  final bool isConnected;
  final bool isLive;
  final bool isFullscreen;
  final VoidCallback onFullscreenPressed;
  final VoidCallback onLeavePressed;
  final bool isLeaving;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const AppLogo(size: 30),
          const SizedBox(width: 9),
          const Text('Alina', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
          if (isLive) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .14), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.circle, color: AppColors.primaryLight, size: 7),
                SizedBox(width: 5),
                Text('EN DIRECT', style: TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: .5)),
              ]),
            ),
          ],
          const Spacer(),
          Tooltip(message: isConnected ? 'Connecté à LiveKit' : 'Connexion indisponible', child: Icon(Icons.circle, size: 10, color: isConnected ? AppColors.success : AppColors.danger)),
          const SizedBox(width: 8),
          _HeaderButton(icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen, tooltip: isFullscreen ? 'Quitter le plein écran' : 'Plein écran', onPressed: onFullscreenPressed),
          const SizedBox(width: 6),
          _HeaderButton(
            icon: Icons.close,
            tooltip: isConnected
                ? 'Quitter la salle'
                : 'Connexion LiveKit indisponible',
            onPressed: isLeaving || !isConnected ? null : onLeavePressed,
            danger: true,
            loading: isLeaving,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.tooltip, required this.onPressed, this.danger = false, this.loading = false});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: .88), shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
          child: Center(child: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary)) : Icon(icon, color: danger ? AppColors.danger : AppColors.textPrimary, size: 20)),
        ),
      ),
    ),
  );
}
