import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:livekit_client/livekit_client.dart';

class LivekitService {
  static Room? _room;
  static Room? getRoom() => _room;

  static Future<Room> connect({required String token}) async {
    await disconnect();
    final room = Room();
    try {
      await room.connect(dotenv.env['VITE_LIVEKIT_URL']!, token);
      _room = room;
      return room;
    } catch (_) {
      await room.dispose();
      rethrow;
    }
  }

  static Future<void> disconnect() async {
    final room = _room;
    _room = null;
    if (room == null) return;
    try {
      await room.disconnect();
    } finally {
      await room.dispose();
    }
  }
}
