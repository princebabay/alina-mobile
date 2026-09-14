import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../services/livekit_service.dart';
import '../common/app_colors.dart';

class NetworkQualityIndicator extends StatefulWidget {
  const NetworkQualityIndicator({super.key, required this.setError});

  final ValueChanged<String> setError;

  @override
  State<NetworkQualityIndicator> createState() =>
      _NetworkQualityIndicatorState();
}

class _NetworkQualityIndicatorState extends State<NetworkQualityIndicator> {
  ConnectionQuality _quality = ConnectionQuality.unknown;

  @override
  void initState() {
    super.initState();
    LivekitService.onCurrentUserConnectionQualityChanged(
      onChanged: _updateQuality,
      onParticipantConnectionIssue: _showParticipantConnectionIssue,
    );
  }

  void _updateQuality(ConnectionQuality quality) {
    if (mounted) {
      setState(() => _quality = quality);
    }
  }

  void _showParticipantConnectionIssue(
    ConnectionQuality quality,
    ParticipantRole role,
  ) {
    final participant = role == ParticipantRole.dj ? 'Le DJ' : 'La Salle';
    final problem = quality == ConnectionQuality.poor
        ? 'a une connexion instable.'
        : 'a perdu sa connexion.';

    widget.setError('$participant $problem');
  }

  int get _activeBars => switch (_quality) {
    ConnectionQuality.excellent => 3,
    ConnectionQuality.good => 2,
    ConnectionQuality.poor => 1,
    ConnectionQuality.lost || ConnectionQuality.unknown => 0,
  };

  Color get _activeColor => _quality == ConnectionQuality.poor
      ? AppColors.warning
      : AppColors.success;

  String get _label => switch (_quality) {
    ConnectionQuality.excellent => 'Qualité réseau excellente',
    ConnectionQuality.good => 'Qualité réseau bonne',
    ConnectionQuality.poor => 'Connexion instable',
    ConnectionQuality.lost => 'Connexion perdue',
    ConnectionQuality.unknown => 'Qualité réseau inconnue',
  };

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: _label,
      child: Semantics(
        label: _label,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final bar = index + 1;
            return Container(
              width: 3,
              height: 5 + (bar * 3),
              margin: EdgeInsets.only(right: bar == 3 ? 0 : 2),
              decoration: BoxDecoration(
                color: bar <= _activeBars ? _activeColor : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ),
    );
  }
}
