import '../../services/auth_service.dart';
import '../../types/auth.request.dart';
import '../../types/auth.response.dart';
import '../../utils/storage_util.dart';

class RegisterHandler {
  static Future<RegisterResponse> submit(RegisterRequest registration) async {
    final response = await AuthService.register(registration);
    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }
    return response.data!;
  }

  static Future<void> verify(RegisterRequest registration, String code) async {
    final response = await AuthService.verifierInscription(
      VerifierInscriptionRequest(
        nomUtilisateur: registration.nomUtilisateur,
        email: registration.email,
        motDePasse: registration.motDePasse,
        confirmationMotDePasse: registration.confirmationMotDePasse,
        code: code,
      ),
    );
    if (!response.success || response.data == null) {
      throw Exception(response.message);
    }
    await StorageUtil.saveAccessToken(accessToken: response.data!.accessToken);
    await StorageUtil.saveRefreshToken(
      refreshToken: response.data!.refreshToken,
    );
  }

  static Future<void> resend(String email) async {
    final response = await AuthService.renvoyerCodeInscription(email);
    if (!response.success) throw Exception(response.message);
  }
}
