import 'dart:async';
import 'package:flutter/material.dart';
import '../handlers/room/client_room_handler.dart';
import '../services/livekit_service.dart';
import '../types/interaction.dart';
import '../widgets/common/app_colors.dart';
import 'home_screen.dart';

class ClientRoomScreen extends StatefulWidget {
  const ClientRoomScreen({super.key});
  @override
  State<ClientRoomScreen> createState() => _ClientRoomScreenState();
}

class _ClientRoomScreenState extends State<ClientRoomScreen> {
  ClientRoomHandler? _handler;
  final _composer = TextEditingController();
  bool _pollTab = false;
  bool _history = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    final room = LivekitService.getRoom();
    if (room != null) {
      _handler = ClientRoomHandler(room)..addListener(_changed);
      unawaited(_handler!.initialize());
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _handler?.removeListener(_changed);
    _handler?.dispose();
    _composer.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    try {
      await _handler?.leave();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _leaving = false);
    }
  }

  Future<void> _send() async {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    try {
      await _handler?.sendMessage(text);
      if (mounted) _composer.clear();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final handler = _handler;
    if (handler == null) {
      return Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
            child: const Text('Room déconnectée · Retour à l’accueil'),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ROOM ${handler.room.name}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            Text(
              handler.connected ? 'Connecté' : 'Reconnexion…',
              style: TextStyle(
                fontSize: 12,
                color: handler.connected
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Quitter la room',
            onPressed: _leaving ? null : _leave,
            icon: _leaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (handler.error != null)
              MaterialBanner(
                content: Text(handler.error!),
                actions: [
                  TextButton(
                    onPressed: handler.clearError,
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: _tab(
                      'Messages',
                      Icons.chat_bubble_outline_rounded,
                      !_pollTab,
                      () => setState(() => _pollTab = false),
                    ),
                  ),
                  Expanded(
                    child: _tab('Sondages', Icons.poll_outlined, _pollTab, () {
                      setState(() => _pollTab = true);
                      unawaited(handler.refreshPolls());
                    }),
                  ),
                ],
              ),
            ),
            Expanded(child: _pollTab ? _polls(handler) : _messages(handler)),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, IconData icon, bool selected, VoidCallback tap) =>
      TextButton.icon(
        onPressed: tap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: TextButton.styleFrom(
          backgroundColor: selected
              ? AppColors.surfaceTertiary
              : Colors.transparent,
          foregroundColor: selected ? AppColors.primary : AppColors.textNormal,
        ),
      );

  Widget _messages(ClientRoomHandler h) => Column(
    children: [
      Expanded(
        child: RefreshIndicator(
          onRefresh: h.reconcileMessages,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: h.messages.length + (h.hasOlder ? 1 : 0),
            itemBuilder: (context, index) {
              if (h.hasOlder && index == 0) {
                return TextButton(
                  onPressed: h.loadingMessages ? null : h.loadOlder,
                  child: Text(
                    h.loadingMessages
                        ? 'Chargement…'
                        : 'Voir les messages précédents',
                  ),
                );
              }
              final message = h.messages[index - (h.hasOlder ? 1 : 0)];
              return _messageCard(message);
            },
          ),
        ),
      ),
      Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _composer,
                enabled: h.connected && !h.sending,
                maxLength: 2000,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Écrire un message…',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.surfaceSecondary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: 'Envoyer',
              onPressed: h.connected && !h.sending ? _send : null,
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _messageCard(SessionMessage message) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  message.auteur,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                message.role,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message.contenu,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    ),
  );

  Widget _polls(ClientRoomHandler h) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('En cours')),
            ButtonSegment(value: true, label: Text('Terminés')),
          ],
          selected: {_history},
          onSelectionChanged: (value) {
            setState(() => _history = value.first);
            if (_history) unawaited(h.refreshHistory());
          },
        ),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: _history ? h.refreshHistory : h.refreshPolls,
          child: Builder(
            builder: (context) {
              final polls = _history ? h.history : h.polls;
              if (polls.isEmpty) {
                return ListView(
                  children: [
                    SizedBox(height: 140),
                    Center(
                      child: Text(
                        _history
                            ? 'Aucun sondage terminé'
                            : 'Aucun sondage en cours',
                        style: const TextStyle(color: AppColors.textNormal),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                itemCount: polls.length,
                itemBuilder: (context, i) => _pollCard(h, polls[i]),
              );
            },
          ),
        ),
      ),
    ],
  );

  Widget _pollCard(ClientRoomHandler h, Poll poll) {
    final total = poll.options.fold<int>(
      0,
      (sum, option) => sum + option.votes,
    );
    final showResults = _history || poll.selectedOptionId != null;
    return Card(
      color: AppColors.surfaceSecondary,
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _history ? 'TERMINÉ' : 'EN COURS',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              poll.question,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$total vote${total > 1 ? 's' : ''}',
              style: const TextStyle(color: AppColors.textNormal),
            ),
            const SizedBox(height: 12),
            for (final option in poll.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed:
                      _history ||
                          poll.selectedOptionId != null ||
                          h.voting ||
                          !h.connected
                      ? null
                      : () => h.vote(poll, option),
                  style: OutlinedButton.styleFrom(
                    alignment: Alignment.centerLeft,
                    side: BorderSide(
                      color: poll.selectedOptionId == option.id
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(option.libelle)),
                      if (showResults)
                        Text(
                          total == 0
                              ? '0%'
                              : '${(option.votes * 100 / total).round()}%',
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
