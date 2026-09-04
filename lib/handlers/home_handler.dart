import 'package:alina_mobile/services/auth_service.dart';
import 'package:alina_mobile/services/session_service.dart';
import 'package:alina_mobile/types/auth.request.dart';
import 'package:alina_mobile/types/session.request.dart';
import 'package:alina_mobile/utils/storage_util.dart';
import 'package:flutter/foundation.dart';

import '../services/livekit_service.dart';

class HomeHandler {
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

      StorageUtil.saveSession(session: joinSession.data!.session);
      StorageUtil.saveParticipant(participant: joinSession.data!.participant);
      StorageUtil.saveSessionToken(token: joinSession.data!.token);

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
          debugPrint('[HomeHandler] Révocation distante impossible, nettoyage local');
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
