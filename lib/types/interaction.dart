class SessionMessage {
  final int id;
  final String contenu;
  final String dateCreation;
  final String auteur;
  final String role;

  SessionMessage({
    required this.id,
    required this.contenu,
    required this.dateCreation,
    required this.auteur,
    required this.role,
  });

  factory SessionMessage.fromJson(Map<String, dynamic> json) {
    final participant = json['participant'] as Map<String, dynamic>? ?? {};
    final utilisateur =
        participant['utilisateur'] as Map<String, dynamic>? ?? {};
    final role = participant['role'] as Map<String, dynamic>? ?? {};
    return SessionMessage(
      id: json['id'] as int,
      contenu: json['contenu'] as String,
      dateCreation: json['dateCreation'] as String,
      auteur: utilisateur['nomUtilisateur'] as String? ?? 'Participant',
      role: role['nom'] as String? ?? 'CLIENT',
    );
  }
}

class PollOption {
  final int id;
  final String libelle;
  final int votes;
  PollOption({required this.id, required this.libelle, required this.votes});
  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
    id: json['id'] as int,
    libelle: json['libelle'] as String,
    votes: (json['_count'] as Map<String, dynamic>?)?['votes'] as int? ?? 0,
  );
}

class Poll {
  final int id;
  final String question;
  final String dateFin;
  final List<PollOption> options;
  final int? selectedOptionId;
  Poll({
    required this.id,
    required this.question,
    required this.dateFin,
    required this.options,
    required this.selectedOptionId,
  });
  factory Poll.fromJson(Map<String, dynamic> json) => Poll(
    id: json['id'] as int,
    question: json['question'] as String,
    dateFin: json['dateFin'] as String,
    options: (json['options'] as List<dynamic>? ?? [])
        .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
        .toList(),
    selectedOptionId:
        ((json['votes'] as List<dynamic>?)?.firstOrNull
                as Map<String, dynamic>?)?['optionId']
            as int?,
  );
}
