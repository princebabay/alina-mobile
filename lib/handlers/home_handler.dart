import 'package:alina_mobile/services/auth_service.dart';
import 'package:alina_mobile/types/auth.request.dart';
import 'package:alina_mobile/types/livekit.type.dart';
import 'package:alina_mobile/utils/storage_util.dart';

import '../services/livekit_service.dart';

class HomeHandler {
  static Future<String?> joinRoom({required String code}) async {
    if (code.length != 6) {
      return "Le code doit contenir exactement 6 caractères.";
    }

    try {
      final tokenResponse = await LivekitService.generateToken(
        TokenRequest(roomName: code, role: "SALLE"),
      );

      if (!tokenResponse.success) {
        return tokenResponse.message;
      }

      await LivekitService.connect(token: tokenResponse.data!.token);

      return null;
    } catch (error) {
      return "Une erreur est survenue lors de la connexion.";
    }
  }

  static Future<bool> deconnexion() async {
    try {
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
          // best effort : on déconnecte localement quoi qu'il arrive
        }

        await StorageUtil.deleteAccessToken();
        await StorageUtil.deleteRefreshToken();

        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }
}
