import 'package:alina_mobile/services/auth_service.dart';
import 'package:alina_mobile/types/auth.request.dart';
import 'package:alina_mobile/utils/storage_util.dart';
import 'package:flutter/foundation.dart';

class RegisterHandler {
  static Future<String?> submit({
    required String nomUtilisateur,
    required String email,
    required String motDePasse,
    required String confirmationMotDePasse,
  }) async {
    try {
      debugPrint('[RegisterHandler] Soumission de l’inscription');
      final response = await AuthService.register(
        RegisterRequest(
          nomUtilisateur: nomUtilisateur,
          email: email,
          motDePasse: motDePasse,
          confirmationMotDePasse: confirmationMotDePasse,
        ),
      );

      if (!response.success) {
        debugPrint('[RegisterHandler] Inscription refusée: ${response.message}');
        return response.message;
      }

      await StorageUtil.saveAccessToken(
        accessToken: response.data!.accessToken,
      );

      await StorageUtil.saveRefreshToken(
        refreshToken: response.data!.refreshToken,
      );

      debugPrint('[RegisterHandler] Inscription réussie');
      return null;
    } catch (error) {
      debugPrint('[RegisterHandler] Erreur inattendue: $error');
      return "Il y a un problème de déconnextion.";
    }
  }
}
