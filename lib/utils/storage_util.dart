import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../types/session.request.dart';
import '../types/session.response.dart';

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

  static Future<void> saveSession({required Session session}) async {
    await storage.write(
      key: 'session',
      value: jsonEncode(session.toJson()),
    );
    debugPrint('[StorageUtil] Session sauvegardée');
  }

  static Future<Session?> getSession() async {
    final session = await storage.read(key: 'session');
    debugPrint('[StorageUtil] Session présente: ${session != null}');
    if (session == null) return null;

    return Session.fromJson(jsonDecode(session));
  }

  static Future<void> deleteSession() async {
    await storage.delete(key: 'session');
    debugPrint('[StorageUtil] Session supprimée');
  }

  static Future<void> saveParticipant({required Participant participant}) async {
    await storage.write(
      key: 'participant',
      value: jsonEncode(participant.toJson()),
    );
    debugPrint('[StorageUtil] Participant sauvegardé');
  }

  static Future<Participant?> getParticipant() async {
    final participant = await storage.read(key: 'participant');
    debugPrint('[StorageUtil] Participant présent: ${participant != null}');
    if (participant == null) return null;

    return Participant.fromJson(jsonDecode(participant));
  }

  static Future<void> deleteParticipant() async {
    await storage.delete(key: 'participant');
    debugPrint('[StorageUtil] Participant supprimé');
  }

  static Future<void> saveSessionToken({required String token}) async {
    await storage.write(key: 'sessionToken', value: token);
    debugPrint('[StorageUtil] Token de session sauvegardé');
  }

  static Future<String?> getSessionToken() async {
    final value = await storage.read(key: 'sessionToken');
    debugPrint('[StorageUtil] Token de session présent: ${value != null}');
    return value;
  }

  static Future<void> deleteSessionToken() async {
    await storage.delete(key: 'sessionToken');
    debugPrint('[StorageUtil] Token de session supprimé');
  }

  static Future<void> saveRevokeSession({
    required SessionDateRequest revokeSession,
  }) async {
    await storage.write(
      key: 'revokeSession',
      value: jsonEncode(revokeSession.toJson()),
    );
    debugPrint('[StorageUtil] Révocation de session sauvegardée');
  }

  static Future<SessionDateRequest?> getRevokeSession() async {
    final revokeSession = await storage.read(key: 'revokeSession');
    debugPrint('[StorageUtil] Révocation de session présente: ${revokeSession != null}');
    if (revokeSession == null) return null;

    return SessionDateRequest.fromJson(jsonDecode(revokeSession));
  }

  static Future<void> deleteRevokeSession() async {
    await storage.delete(key: 'revokeSession');
    debugPrint('[StorageUtil] Révocation de session supprimée');
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
