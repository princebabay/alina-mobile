import 'package:alina_mobile/services/auth_service.dart';
import 'package:alina_mobile/types/auth.request.dart';
import 'package:alina_mobile/utils/storage_util.dart';
import 'package:flutter/foundation.dart';

class LoginHandler {
  static Future<String?> submit({
    required String email,
    required String motDePasse,
  }) async {
    try {
      debugPrint('[LoginHandler] Soumission de la connexion');
      final response = await AuthService.login(
        LoginRequest(email: email, motDePasse: motDePasse),
      );

      if (!response.success) {
        debugPrint('[LoginHandler] Connexion refusée: ${response.message}');
        return response.message;
      }

      await StorageUtil.saveAccessToken(
        accessToken: response.data!.accessToken,
      );

      await StorageUtil.saveRefreshToken(
        refreshToken: response.data!.refreshToken,
      );

      debugPrint('[LoginHandler] Connexion réussie');
      return null;
    } catch (error) {
      debugPrint('[LoginHandler] Erreur inattendue: $error');
      return "Une erreur est survenue lors de la connexion.";
    }
  }

  static Future<bool> initialize() async {
    try {
      debugPrint('[LoginHandler] Recherche d’une session existante');
      final refreshToken = await StorageUtil.getRefreshToken();
      if (refreshToken != null) {
        debugPrint('[LoginHandler] Refresh token trouvé');
        final response = await AuthService.refreshTokenAPI(
          RefreshTokenRequest(refreshToken: refreshToken),
        );

        if (!response.success) {
          debugPrint('[LoginHandler] Session existante invalide');
          return true;
        }

        await StorageUtil.saveAccessToken(
          accessToken: response.data!.accessToken,
        );

        await StorageUtil.saveRefreshToken(
          refreshToken: response.data!.refreshToken,
        );

        debugPrint('[LoginHandler] Session restaurée');
        return false;
      }
      debugPrint('[LoginHandler] Aucune session existante');
      return true;
    } catch (error) {
      debugPrint('[LoginHandler] Erreur restauration session: $error');
      return true;
    }
  }
}
