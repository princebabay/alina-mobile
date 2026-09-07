import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../types/session.request.dart';

class StorageUtil {
  static const storage = FlutterSecureStorage();

  static Future<void> saveAccessToken({required String accessToken}) async {
    await storage.write(key: "accessToken", value: accessToken);
    debugPrint('[StorageUtil] Access token sauvegardé');
  }

  static Future<void> saveRefreshToken({required String refreshToken}) async {
    await storage.write(key: "refreshToken", value: refreshToken);
    debugPrint('[StorageUtil] Refresh token sauvegardé');
  }

  static Future<String?> getAccessToken() async {
    final value = await storage.read(key: "accessToken");
    debugPrint('[StorageUtil] Access token présent: ${value != null}');
    return value;
  }

  static Future<String?> getRefreshToken() async {
    final value = await storage.read(key: "refreshToken");
    debugPrint('[StorageUtil] Refresh token présent: ${value != null}');
    return value;
  }

  static Future<void> deleteAccessToken() async {
    await storage.delete(key: "accessToken");
    debugPrint('[StorageUtil] Access token supprimé');
  }

  static Future<void> deleteRefreshToken() async {
    await storage.delete(key: "refreshToken");
    debugPrint('[StorageUtil] Refresh token supprimé');
  }

  static Future<void> saveParticipantDisconnect({
    required SessionDateRequest participantDisconnect,
  }) async {
    await storage.write(
      key: 'participantDisconnect',
      value: jsonEncode(participantDisconnect.toJson()),
    );
    debugPrint('[StorageUtil] Déconnexion participant sauvegardée');
  }

  static Future<SessionDateRequest?> getParticipantDisconnect() async {
    final participantDisconnect = await storage.read(
      key: 'participantDisconnect',
    );
    debugPrint(
      '[StorageUtil] Déconnexion participant présente: ${participantDisconnect != null}',
    );
    if (participantDisconnect == null) return null;

    return SessionDateRequest.fromJson(
      jsonDecode(participantDisconnect),
    );
  }

  static Future<void> deleteParticipantDisconnect() async {
    await storage.delete(key: 'participantDisconnect');
    debugPrint('[StorageUtil] Déconnexion participant supprimée');
  }
}
