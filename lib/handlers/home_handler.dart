import 'package:alina_mobile/services/auth_service.dart';
import 'package:alina_mobile/services/session_service.dart';
import 'package:alina_mobile/types/auth.request.dart';
import 'package:alina_mobile/types/session.request.dart';
import 'package:alina_mobile/utils/storage_util.dart';
import 'package:flutter/foundation.dart';

import '../services/livekit_service.dart';

class HomeHandler {
  static Future<String?> restoreActiveSession() async {
    try {
      final activeParticipant =
          await SessionService.getActiveParticipantSession();

      if (!activeParticipant.success) {
        throw Exception(activeParticipant.message);
      }

      final activeSession = activeParticipant.data;

      if (activeSession == null) {
        return null;
      }

      final session = activeSession.session;
      final sessionIsClosed =
          !session.estActif ||
          session.dateRevocation != null ||
          !DateTime.parse(
            session.dateExpiration,
          ).toUtc().isAfter(DateTime.now().toUtc());

      if (sessionIsClosed) {
        final leaveDate = DateTime.parse(
          session.dateRevocation ?? session.dateExpiration,
        ).toUtc();
        final leaveRequest = SessionDateRequest(
          code: session.code,
          date: leaveDate,
        );

        try {
          final leaveResponse = await SessionService.leaveParticipant(
            SessionEndRequest(code: leaveRequest.code, date: leaveRequest.date),
          );

          if (!leaveResponse.success) {
            throw Exception(leaveResponse.message);
          }
        } catch (_) {
          await StorageUtil.saveParticipantLeave(
            participantLeave: leaveRequest,
          );
          rethrow;
        }

        return null;
      }

      final joinSession = await SessionService.joinSession(
        JoinSessionRequest(code: session.code, role: activeSession.role),
      );

      if (!joinSession.success) {
        throw Exception(joinSession.message);
      }

      await LivekitService.connect(token: joinSession.data!.token);

      return activeSession.role;
    } catch (error) {
      debugPrint('[HomeHandler] Erreur restauration session: $error');
      rethrow;
    }
  }

  static Future<String?> joinRoom({required String code}) async {
    debugPrint('[HomeHandler] Tentative de rejoindre une session');
    if (code.length != 6) {
      debugPrint('[HomeHandler] Code session invalide');
      return "Le code doit contenir exactement 6 caractères.";
    }

    try {
      final joinSession = await SessionService.joinSession(
        JoinSessionRequest(code: code, role: "SALLE"),
      );

      if (!joinSession.success) {
        debugPrint('[HomeHandler] Session refusée: ${joinSession.message}');
        return joinSession.message;
      }

      await LivekitService.connect(token: joinSession.data!.token);

      debugPrint('[HomeHandler] Session rejointe avec succès');
      return null;
    } catch (error) {
      debugPrint('[HomeHandler] Erreur pour rejoindre la session: $error');
      return "Une erreur est survenue lors de la connexion.";
    }
  }

  static Future<bool> deconnexion() async {
    try {
      debugPrint('[HomeHandler] Déconnexion utilisateur');
      final refreshToken = await StorageUtil.getRefreshToken();
      if (refreshToken != null) {
        // final response = await AuthService.revokeTokenAPI(
        //   RefreshTokenRequest(refreshToken: refreshToken),
        // );

        try {
          await AuthService.revokeTokenAPI(
            RefreshTokenRequest(refreshToken: refreshToken),
          );
        } catch (_) {
          debugPrint(
            '[HomeHandler] Révocation distante impossible, nettoyage local',
          );
          // best effort : on déconnecte localement quoi qu'il arrive
        }

        await StorageUtil.deleteAccessToken();
        await StorageUtil.deleteRefreshToken();

        debugPrint('[HomeHandler] Déconnexion locale terminée');
        return true;
      }
      debugPrint('[HomeHandler] Aucun refresh token à révoquer');
      return false;
    } catch (error) {
      debugPrint('[HomeHandler] Erreur de déconnexion: $error');
      return false;
    }
  }
}
