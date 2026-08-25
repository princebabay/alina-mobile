import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../common/app_colors.dart';

class RoomVideo extends StatelessWidget {
  const RoomVideo({super.key, this.remoteTrack, this.localTrack});

  final RemoteVideoTrack? remoteTrack;
  final LocalVideoTrack? localTrack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(color: AppColors.surfaceTertiary),
          child: remoteTrack == null
              ? const Center(child: Icon(Icons.videocam_off_outlined, color: AppColors.textMuted, size: 34))
              : ClipRRect(borderRadius: BorderRadius.circular(18), child: VideoTrackRenderer(remoteTrack!, fit: VideoViewFit.cover)),
        ),
        if (localTrack != null)
          Positioned(
            right: 12,
            bottom: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 104,
                height: 142,
                decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
                child: VideoTrackRenderer(localTrack!, fit: VideoViewFit.cover),
              ),
            ),
          ),
      ],
    );
  }
}
