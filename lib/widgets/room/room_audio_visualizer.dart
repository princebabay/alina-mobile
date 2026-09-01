import 'package:flutter/material.dart';

import '../common/app_colors.dart';

class RoomAudioVisualizer extends StatelessWidget {
  const RoomAudioVisualizer({super.key, required this.level});

  final double level;

  @override
  Widget build(BuildContext context) {
    final activeWidth = (level / 100).clamp(0.02, 1.0) as double;
    return Container(
      height: 4,
      decoration: BoxDecoration(color: AppColors.surfaceTertiary, borderRadius: BorderRadius.circular(4)),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: activeWidth,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFFF5AA8), AppColors.primaryDark]),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: .45), blurRadius: 7)],
          ),
        ),
      ),
    );
  }
}
