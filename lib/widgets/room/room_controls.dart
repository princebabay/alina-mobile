import 'package:flutter/material.dart';

import '../common/app_colors.dart';

class RoomControls extends StatelessWidget {
  const RoomControls({
    super.key,
    required this.microphoneEnabled,
    required this.cameraEnabled,
    required this.enabled,
    required this.onMicrophonePressed,
    required this.onCameraPressed,
  });

  final bool microphoneEnabled;
  final bool cameraEnabled;
  final bool enabled;
  final VoidCallback onMicrophonePressed;
  final VoidCallback onCameraPressed;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ControlButton(
            icon: microphoneEnabled ? Icons.mic : Icons.mic_off,
            tooltip: microphoneEnabled
                ? 'Couper le microphone'
                : 'Activer le microphone',
            active: microphoneEnabled,
            onPressed: enabled ? onMicrophonePressed : null,
          ),
          const SizedBox(width: 14),
          _ControlButton(
            icon: cameraEnabled ? Icons.videocam : Icons.videocam_off,
            tooltip: cameraEnabled
                ? 'Désactiver la caméra'
                : 'Activer la caméra',
            active: cameraEnabled,
            onPressed: enabled ? onCameraPressed : null,
          ),
        ],
      ),
    ],
  );
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.tooltip,
    required this.active,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surfaceTertiary,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? AppColors.primaryLight : AppColors.border,
            ),
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    ),
  );
}
