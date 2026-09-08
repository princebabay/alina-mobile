import 'package:alina_mobile/services/livekit_service.dart';
import 'package:alina_mobile/services/session_service.dart';
import 'package:alina_mobile/types/session.request.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';

class SalleHandler {
  static Future<void> initialize({
    required void Function(bool) setIsEnDirect,
    required void Function(bool) setIsConnected,
    required void Function(bool) setCameraEnabled,
    required void Function(String?) setRoomName,
    required void Function(LocalVideoTrack?) setLocalVideoTrack,
    required void Function(bool) setMicrophoneEnabled,
    required void Function(RemoteVideoTrack?) setRemoteVideoTrack,
    required void Function(RemoteAudioTrack?) setRemoteAudioTrack,
  }) async {
    try {
      final room = LivekitService.getRoom();
      final code = room?.name;

      if (room == null || code == null) {
        debugPrint('[SalleHandler] Aucune room disponible');
        return;
      }

      setIsConnected(true);
      setRoomName(code);

      LivekitService.isEnDirectCall(setIsEnDirect);

      await LivekitService.enableCamera();
      setLocalVideoTrack(LivekitService.getCameraTrack());
      setCameraEnabled(true);

      await LivekitService.enableMicrophone();
      setMicrophoneEnabled(true);

      LivekitService.onRemoteVideoTrack(setRemoteVideoTrack);
      LivekitService.onRemoteAudioTrack(setRemoteAudioTrack);

      LivekitService.onConnectionStateChange(
        onReconnecting: () => setIsConnected(false),
        onReconnected: () => setIsConnected(true),
        onDisconnected: () => setIsConnected(false),
      );
    } catch (error) {
      debugPrint('[SalleHandler] Erreur initialisation salle: $error');
    }
  }

  static Future<bool> quitterSalle() async {
    try {
      final code = LivekitService.getRoom()?.name;

      if (code != null) {
        try {
          final response = await SessionService.leaveParticipant(
            SessionEndRequest(code: code, date: DateTime.now().toUtc()),
          );

          if (!response.success) {
            debugPrint('[SalleHandler] Depart participant non confirme');
          }
        } catch (error) {
          debugPrint('[SalleHandler] Erreur depart participant: $error');
        }
      }

      await LivekitService.disconnect();
      return true;
    } catch (error) {
      debugPrint('[SalleHandler] Erreur sortie salle: $error');
      return false;
    }
  }

  static Future<String?> toggleCamera({required bool etat}) async {
    try {
      if (etat) {
        await LivekitService.enableCamera();
      } else {
        await LivekitService.disableCamera();
      }
      return null;
    } catch (_) {
      return 'Erreur lors du changement de camera';
    }
  }

  static Future<String?> toggleMicrophone({required bool etat}) async {
    try {
      if (etat) {
        await LivekitService.enableMicrophone();
      } else {
        await LivekitService.disableMicrophone();
      }
      return null;
    } catch (_) {
      return 'Erreur lors du changement de microphone';
    }
  }
}
