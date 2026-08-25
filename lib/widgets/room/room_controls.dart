import 'package:flutter/material.dart';

import '../common/app_colors.dart';

class RoomControls extends StatelessWidget {
  const RoomControls({
    super.key,
    required this.microphoneEnabled,
    required this.cameraEnabled,
    required this.volume,
    required this.showVolume,
    required this.enabled,
    required this.onMicrophonePressed,
    required this.onCameraPressed,
    required this.onVolumePressed,
    required this.onVolumeChanged,
  });

  final bool microphoneEnabled;
  final bool cameraEnabled;
  final double volume;
  final bool showVolume;
  final bool enabled;
  final VoidCallback onMicrophonePressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onVolumePressed;
  final ValueChanged<double> onVolumeChanged;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (showVolume) ...[
        Row(children: [
          const Icon(Icons.volume_down_outlined, color: AppColors.textSecondary, size: 20),
          Expanded(child: Slider(value: volume, activeColor: AppColors.primary, inactiveColor: AppColors.surfaceTertiary, onChanged: enabled ? onVolumeChanged : null)),
          const Icon(Icons.volume_up_outlined, color: AppColors.textSecondary, size: 20),
        ]),
        const SizedBox(height: 6),
      ],
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _ControlButton(icon: microphoneEnabled ? Icons.mic : Icons.mic_off, tooltip: microphoneEnabled ? 'Couper le microphone' : 'Activer le microphone', active: microphoneEnabled, onPressed: enabled ? onMicrophonePressed : null),
        const SizedBox(width: 14),
        _ControlButton(icon: cameraEnabled ? Icons.videocam : Icons.videocam_off, tooltip: cameraEnabled ? 'Désactiver la caméra' : 'Activer la caméra', active: cameraEnabled, onPressed: enabled ? onCameraPressed : null),
        const SizedBox(width: 14),
        _ControlButton(icon: Icons.volume_up_outlined, tooltip: 'Volume', active: showVolume, onPressed: onVolumePressed),
      ]),
    ],
  );
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.icon, required this.tooltip, required this.active, required this.onPressed});

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
          decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.surfaceTertiary, shape: BoxShape.circle, border: Border.all(color: active ? AppColors.primaryLight : AppColors.border)),
          child: Icon(icon, color: active ? Colors.white : AppColors.textPrimary),
        ),
      ),
    ),
  );
}
