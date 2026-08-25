import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageUtil {
  static const storage = FlutterSecureStorage();

  static Future<void> saveAccessToken({required String accessToken}) async {
    await storage.write(key: "accessToken", value: accessToken);
  }

  static Future<void> saveRefreshToken({required String refreshToken}) async {
    await storage.write(key: "refreshToken", value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: "accessToken");
  }

  static Future<String?> getRefreshToken() async {
    return await storage.read(key: "refreshToken");
  }

  static Future<void> deleteAccessToken() async {
    await storage.delete(key: "accessToken");
  }

  static Future<void> deleteRefreshToken() async {
    await storage.delete(key: "refreshToken");
  }
}
