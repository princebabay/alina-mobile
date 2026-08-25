import 'package:alina_mobile/services/auth_service.dart';
import 'package:alina_mobile/types/auth.request.dart';
import 'package:alina_mobile/utils/storage_util.dart';

class LoginHandler {
  static Future<String?> submit({
    required String email,
    required String motDePasse,
  }) async {
    try {
      final response = await AuthService.login(
        LoginRequest(email: email, motDePasse: motDePasse),
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
      return "Une erreur est survenue lors de la connexion.";
    }
  }

  static Future<bool> initialize() async {
    try {
      final refreshToken = await StorageUtil.getRefreshToken();
      if (refreshToken != null) {
        final response = await AuthService.refreshTokenAPI(
          RefreshTokenRequest(refreshToken: refreshToken),
        );

        if (!response.success) {
          return true;
        }
        await StorageUtil.saveAccessToken(
          accessToken: response.data!.accessToken,
        );

        return false;
      }
      return true;
    } catch (error) {
      return true;
    }
  }
}
