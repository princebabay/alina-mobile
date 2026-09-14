import 'dart:async';

import 'package:flutter/material.dart';

import 'app_colors.dart';

enum AppMessageType { error, success, warning }

class AppMessage extends StatefulWidget {
  const AppMessage({
    super.key,
    required this.message,
    this.type = AppMessageType.error,
    this.duree,
    this.onClose,
  });

  final String message;
  final AppMessageType type;
  final Duration? duree;
  final VoidCallback? onClose;

  @override
  State<AppMessage> createState() => _AppMessageState();
}

class _AppMessageState extends State<AppMessage> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _scheduleDismissal();
  }

  @override
  void didUpdateWidget(covariant AppMessage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.message != widget.message ||
        oldWidget.duree != widget.duree) {
      _scheduleDismissal();
    }
  }

  void _scheduleDismissal() {
    _dismissTimer?.cancel();

    final duree = widget.duree;
    final onClose = widget.onClose;
    if (duree == null || onClose == null) {
      return;
    }

    _dismissTimer = Timer(duree, onClose);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.type) {
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
          Expanded(
            child: Text(
              widget.message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
          if (widget.onClose != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: widget.onClose,
              icon: Icon(Icons.close, color: color, size: 18),
              tooltip: 'Fermer le message',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}
