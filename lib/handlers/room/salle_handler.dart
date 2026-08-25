import 'package:alina_mobile/services/livekit_service.dart';
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
      if (room != null) {
        setIsConnected(true);

        LivekitService.isEnDirectCall((etat) {
          setIsEnDirect(etat);
        });

        setRoomName(room.name);

        await LivekitService.enableCamera();
        final localTrack = LivekitService.getCameraTrack();
        setLocalVideoTrack(localTrack);
        setCameraEnabled(true);

        await LivekitService.enableMicrophone();
        setMicrophoneEnabled(true);

        LivekitService.onRemoteVideoTrack((track) {
          setRemoteVideoTrack(track);
        });

        LivekitService.onRemoteAudioTrack((track) {
          setRemoteAudioTrack(track);
        });
      }
      return;
    } catch (error) {
      return;
    }
  }

  static Future<bool> quitterSalle() async {
    try {
      await LivekitService.disconnect();
      return true;
    } catch (error) {
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
    } catch (error) {
      return "Erreur lors du toggle caméra";
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
    } catch (error) {
      return "Erreur lors du toggle microphone";
    }
  }
}
