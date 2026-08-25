import 'package:alina_mobile/services/auth_service.dart';
import 'package:alina_mobile/types/auth.request.dart';
import 'package:alina_mobile/utils/storage_util.dart';

class RegisterHandler {
  static Future<String?> submit({
    required String nomUtilisateur,
    required String email,
    required String motDePasse,
    required String confirmationMotDePasse,
  }) async {
    try {
      final response = await AuthService.register(
        RegisterRequest(
          nomUtilisateur: nomUtilisateur,
          email: email,
          motDePasse: motDePasse,
          confirmationMotDePasse: confirmationMotDePasse,
        ),
      );

      if (!response.success) {
        return response.message;
      }

      await StorageUtil.saveAccessToken(
        accessToken: response.data!.accessToken,
      );

      await StorageUtil.saveRefreshToken(
        refreshToken: response.data!.refreshToken,
      );

      return null;
    } catch (error) {
      return "Il y a un problème de déconnextion.";
    }
  }
}
