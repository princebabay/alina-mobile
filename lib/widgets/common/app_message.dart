import 'package:flutter/material.dart';

import 'app_colors.dart';

enum AppMessageType { error, success, warning }

class AppMessage extends StatelessWidget {
  const AppMessage({super.key, required this.message, this.type = AppMessageType.error});

  final String message;
  final AppMessageType type;

  @override
  Widget build(BuildContext context) {
    final color = switch (type) {
      AppMessageType.error => AppColors.danger,
      AppMessageType.success => AppColors.success,
      AppMessageType.warning => AppColors.warning,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: TextStyle(color: color, fontSize: 13))),
        ],
      ),
    );
  }
}
