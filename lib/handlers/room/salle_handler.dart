import 'package:alina_mobile/services/session_service.dart';
import 'package:alina_mobile/services/livekit_service.dart';
import 'package:alina_mobile/types/api.response.dart';
import 'package:alina_mobile/types/session.request.dart';
import 'package:alina_mobile/types/session.response.dart';
import 'package:alina_mobile/utils/storage_util.dart';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import 'dart:async';

enum ParticipantPresence { disconnected, connecting, connected, disconnecting }

class ParticipantPresenceManager {
  ParticipantPresenceManager({
    ParticipantPresence initialPresence = ParticipantPresence.disconnected,
  }) : _presence = initialPresence;

  ParticipantPresence _presence;

  Future<ApiResponse<ParticipantHistoryResponse>?> connect({
    required String code,
  }) async {
    debugPrint('[PresenceManager] Demande de connexion participant');
    final participantDisconnect = await StorageUtil.getParticipantDisconnect();

    if (participantDisconnect != null) {
      debugPrint(
        '[PresenceManager] Nouvelle tentative de déconnexion en attente',
      );
      final response = await SessionService.disconnectParticipant(
        DisconnectParticipantRequest(
          code: participantDisconnect.code,
          date: participantDisconnect.date,
        ),
      );

      if (response.success) {
        await StorageUtil.deleteParticipantDisconnect();
        debugPrint('[PresenceManager] Déconnexion en attente traitée');
      }
    }

    if (_presence != ParticipantPresence.disconnected) {
      debugPrint(
        '[PresenceManager] Connexion ignorée, état actuel: $_presence',
      );
      return null;
    }

    _presence = ParticipantPresence.connecting;

    try {
      final response = await SessionService.connectParticipant(
        SessionCodeRequest(code: code),
      );
      _presence = response.success
          ? ParticipantPresence.connected
          : ParticipantPresence.disconnected;
      debugPrint('[PresenceManager] État après connexion: $_presence');
      return response;
    } catch (error) {
      _presence = ParticipantPresence.disconnected;
      debugPrint('[PresenceManager] Erreur de connexion: $error');
      rethrow;
    }
  }

  Future<ApiResponse<ParticipantHistoryResponse>?> disconnect({
    required String code,
  }) async {
    debugPrint('[PresenceManager] Demande de déconnexion participant');
    if (_presence != ParticipantPresence.connected) {
      debugPrint(
        '[PresenceManager] Déconnexion ignorée, état actuel: $_presence',
      );
      return null;
    }

    _presence = ParticipantPresence.disconnecting;

    try {
      final response = await SessionService.disconnectParticipant(
        DisconnectParticipantRequest(code: code),
      );
      if (!response.success) {
        await StorageUtil.saveParticipantDisconnect(
          participantDisconnect: SessionDateRequest(
            code: code,
            date: DateTime.now().toUtc(),
          ),
        );
        debugPrint(
          '[PresenceManager] Déconnexion sauvegardée pour synchronisation',
        );
      }
      _presence = ParticipantPresence.disconnected;
      debugPrint('[PresenceManager] Participant déconnecté');
      return response;
    } catch (error) {
      _presence = ParticipantPresence.disconnected;
      await StorageUtil.saveParticipantDisconnect(
        participantDisconnect: SessionDateRequest(
          code: code,
          date: DateTime.now().toUtc(),
        ),
      );
      debugPrint(
        '[PresenceManager] Déconnexion sauvegardée pour synchronisation',
      );
      debugPrint('[PresenceManager] Erreur de déconnexion: $error');
      rethrow;
    }
  }
}

class SalleHandler {
  static ParticipantPresenceManager createParticipantPresenceManager({
    ParticipantPresence initialPresence = ParticipantPresence.disconnected,
  }) {
    return ParticipantPresenceManager(initialPresence: initialPresence);
  }

  static Future<void> initialize({
    required ParticipantPresenceManager participantPresenceManager,
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
      debugPrint('[SalleHandler] Initialisation de la salle');
      final room = LivekitService.getRoom();
      if (room != null) {
        final code = room.name!;
        debugPrint('[SalleHandler] Room disponible: $code');
        setIsConnected(true);

        LivekitService.isEnDirectCall((etat) {
          setIsEnDirect(etat);
        });

        setRoomName(code);

        await participantPresenceManager.connect(code: code);

        LivekitService.onConnectionStateChange(
          onReconnecting: () {
            debugPrint('[SalleHandler] LiveKit en reconnexion');
            setIsConnected(false);
            unawaited(participantPresenceManager.disconnect(code: code));
          },
          onReconnected: () {
            debugPrint('[SalleHandler] LiveKit reconnecté');
            setIsConnected(true);
            unawaited(participantPresenceManager.connect(code: code));
          },
          onDisconnected: () {
            debugPrint('[SalleHandler] LiveKit déconnecté');
            setIsConnected(false);
            unawaited(participantPresenceManager.disconnect(code: code));
          },
        );

        await LivekitService.enableCamera();
        final localTrack = LivekitService.getCameraTrack();
        setLocalVideoTrack(localTrack);
        setCameraEnabled(true);

        await LivekitService.enableMicrophone();
        setMicrophoneEnabled(true);

        LivekitService.onRemoteVideoTrack((track) {
          debugPrint('[SalleHandler] Piste vidéo distante reçue');
          setRemoteVideoTrack(track);
        });

        LivekitService.onRemoteAudioTrack((track) {
          debugPrint('[SalleHandler] Piste audio distante reçue');
          setRemoteAudioTrack(track);
        });
      }
      if (room == null) debugPrint('[SalleHandler] Aucune room disponible');
      return;
    } catch (error) {
      debugPrint('[SalleHandler] Erreur d’initialisation: $error');
      return;
    }
  }

  static Future<bool> quitterSalle({
    required ParticipantPresenceManager participantPresenceManager,
  }) async {
    try {
      final room = LivekitService.getRoom();
      final code = room?.name;
      debugPrint('[SalleHandler] Sortie de la salle');
      await LivekitService.disconnect();
      if (code != null) {
        unawaited(participantPresenceManager.disconnect(code: code));
      }
      debugPrint('[SalleHandler] Salle quittée');
      return true;
    } catch (error) {
      debugPrint('[SalleHandler] Erreur en quittant la salle: $error');
      return false;
    }
  }

  static Future<String?> toggleCamera({required bool etat}) async {
    try {
      debugPrint('[SalleHandler] Caméra demandée: $etat');
      if (etat) {
        await LivekitService.enableCamera();
      } else {
        await LivekitService.disableCamera();
      }
      return null;
    } catch (error) {
      debugPrint('[SalleHandler] Erreur caméra: $error');
      return "Erreur lors du toggle caméra";
    }
  }

  static Future<String?> toggleMicrophone({required bool etat}) async {
    try {
      debugPrint('[SalleHandler] Microphone demandé: $etat');
      if (etat) {
        await LivekitService.enableMicrophone();
      } else {
        await LivekitService.disableMicrophone();
      }
      return null;
    } catch (error) {
      debugPrint('[SalleHandler] Erreur microphone: $error');
      return "Erreur lors du toggle microphone";
    }
  }
}
