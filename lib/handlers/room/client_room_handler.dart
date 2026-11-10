import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../services/interaction_service.dart';
import '../../services/livekit_service.dart';
import '../../services/session_service.dart';
import '../../types/interaction.dart';
import '../../types/session.request.dart';
import '../../utils/storage_util.dart';

class ClientRoomHandler extends ChangeNotifier {
  ClientRoomHandler(this.room);
  final Room room;
  String get code => room.name ?? '';
  CancelListenFunc? _cancelEvents;
  Timer? _refreshTimer;
  Timer? _pollTimer;
  bool _disposed = false;
  bool _reconciling = false;
  bool historyLoaded = false;
  bool connected = true;
  bool loadingMessages = true;
  bool loadingPolls = true;
  bool loadingHistory = false;
  bool hasOlder = false;
  bool sending = false;
  bool voting = false;
  String? error;
  List<SessionMessage> messages = [];
  List<Poll> polls = [];
  List<Poll> history = [];

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _fail(Object exception) {
    error = exception.toString().replaceFirst('Exception: ', '');
    _notify();
  }

  void clearError() {
    error = null;
    _notify();
  }

  void _requireSuccess(bool success, String message) {
    if (!success) throw Exception(message);
  }

  Future<void> initialize() async {
    _cancelEvents = room.events.listen((event) {
      if (event is RoomReconnectingEvent ||
          event is RoomResumingEvent ||
          event is RoomDisconnectedEvent) {
        connected = false;
        _notify();
      } else if (event is RoomReconnectedEvent || event is RoomConnectedEvent) {
        connected = true;
        _notify();
        unawaited(reconcileMessages());
        unawaited(refreshPolls());
      } else if (event is DataReceivedEvent) {
        if (event.topic == 'alina.interaction.chat') {
          unawaited(reconcileMessages());
        } else if (event.topic == 'alina.interaction.poll') {
          try {
            final packet =
                jsonDecode(utf8.decode(event.data)) as Map<String, dynamic>;
            if (packet['type'] == 'poll.changed' &&
                packet['sessionCode'] == code) {
              _refreshTimer?.cancel();
              _refreshTimer = Timer(const Duration(milliseconds: 250), () {
                unawaited(refreshPolls());
                if (historyLoaded) {
                  unawaited(refreshHistory());
                }
              });
            }
          } catch (_) {
            /* Ignore unknown packets. */
          }
        }
      }
    });
    _pollTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      unawaited(refreshPolls());
      if (historyLoaded) unawaited(refreshHistory());
    });
    await Future.wait([loadMessages(), refreshPolls()]);
  }

  void _mergeMessages(List<SessionMessage> incoming) {
    final byId = {for (final message in messages) message.id: message};
    for (final message in incoming) {
      byId[message.id] = message;
    }
    messages = byId.values.toList()..sort((a, b) => a.id.compareTo(b.id));
    _notify();
  }

  Future<void> loadMessages() async {
    try {
      final result = await InteractionService.getMessages(code);
      _requireSuccess(result.success, result.message);
      if (_disposed) return;
      _mergeMessages(result.data ?? []);
      hasOlder = (result.data?.length ?? 0) == 10;
      if (messages.isNotEmpty) await reconcileMessages();
    } catch (e) {
      if (!_disposed) _fail(e);
    } finally {
      loadingMessages = false;
      _notify();
    }
  }

  Future<void> reconcileMessages() async {
    if (_disposed || _reconciling) return;
    if (messages.isEmpty) {
      await loadMessages();
      return;
    }
    _reconciling = true;
    try {
      for (var page = 0; page < 30; page++) {
        final lastId = messages.last.id;
        final result = await InteractionService.getMessages(
          code,
          after: lastId,
        );
        _requireSuccess(result.success, result.message);
        if (_disposed) return;
        final incoming = result.data ?? [];
        _mergeMessages(incoming);
        if (incoming.length < 10 || messages.last.id == lastId) break;
      }
    } catch (e) {
      if (!_disposed) _fail(e);
    } finally {
      _reconciling = false;
    }
  }

  Future<void> loadOlder() async {
    if (!hasOlder || messages.isEmpty || loadingMessages) return;
    loadingMessages = true;
    _notify();
    try {
      final result = await InteractionService.getMessages(
        code,
        before: messages.first.id,
      );
      _requireSuccess(result.success, result.message);
      if (_disposed) return;
      _mergeMessages(result.data ?? []);
      hasOlder = (result.data?.length ?? 0) == 10;
    } catch (e) {
      if (!_disposed) _fail(e);
    } finally {
      loadingMessages = false;
      _notify();
    }
  }

  Future<void> sendMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty || content.length > 2000 || sending) return;
    sending = true;
    _notify();
    try {
      final response = await InteractionService.sendMessage(code, content);
      _requireSuccess(response.success, response.message);
      await reconcileMessages();
      try {
        final data = response.data!;
        await room.localParticipant?.publishData(
          utf8.encode(
            jsonEncode({
              'type': 'chat.message',
              'id': '${data['id']}',
              'content': content,
              'createdAt': data['dateCreation'],
              'color': '#ffb020',
            }),
          ),
          reliable: true,
          topic: 'alina.interaction.chat',
        );
      } catch (_) {
        /* Message is saved; peers catch up through the API. */
      }
    } catch (e) {
      if (!_disposed) _fail(e);
      rethrow;
    } finally {
      sending = false;
      _notify();
    }
  }

  Future<void> refreshPolls() async {
    loadingPolls = true;
    _notify();
    try {
      final result = await InteractionService.getPolls(code);
      _requireSuccess(result.success, result.message);
      if (_disposed) return;
      polls = result.data ?? [];
      _notify();
    } catch (e) {
      if (!_disposed) _fail(e);
    } finally {
      loadingPolls = false;
      _notify();
    }
  }

  Future<void> refreshHistory() async {
    loadingHistory = true;
    _notify();
    try {
      final result = await InteractionService.getPolls(code, history: true);
      _requireSuccess(result.success, result.message);
      if (_disposed) return;
      history = result.data ?? [];
      historyLoaded = true;
      _notify();
    } catch (e) {
      if (!_disposed) _fail(e);
    } finally {
      loadingHistory = false;
      _notify();
    }
  }

  Future<void> vote(Poll poll, PollOption option) async {
    if (voting || poll.selectedOptionId != null) return;
    voting = true;
    _notify();
    try {
      final response = await InteractionService.vote(poll.id, option.id);
      _requireSuccess(response.success, response.message);
      await refreshPolls();
      try {
        await room.localParticipant?.publishData(
          utf8.encode(
            jsonEncode({
              'type': 'poll.changed',
              'sessionCode': code,
              'sondageId': poll.id,
              'action': 'voted',
            }),
          ),
          reliable: true,
          topic: 'alina.interaction.poll',
        );
      } catch (_) {
        /* Vote is saved. */
      }
    } catch (e) {
      if (!_disposed) _fail(e);
    } finally {
      voting = false;
      _notify();
    }
  }

  Future<void> leave() async {
    final date = DateTime.now().toUtc();
    try {
      final response = await SessionService.leaveParticipant(
        SessionEndRequest(code: code, date: date),
      );
      if (!response.success &&
          !SessionService.isTerminalClientError(response.statusCode)) {
        await StorageUtil.saveParticipantLeave(
          participantLeave: SessionDateRequest(code: code, date: date),
        );
      }
    } catch (_) {
      await StorageUtil.saveParticipantLeave(
        participantLeave: SessionDateRequest(code: code, date: date),
      );
    } finally {
      await LivekitService.disconnect();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    _pollTimer?.cancel();
    _cancelEvents?.call();
    super.dispose();
  }
}
