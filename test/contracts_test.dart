import 'package:alina_mobile/types/auth.request.dart';
import 'package:alina_mobile/types/auth.response.dart';
import 'package:alina_mobile/types/interaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'verification payload preserves registration details and six digit code',
    () {
      final request = VerifierInscriptionRequest(
        nomUtilisateur: 'Lova',
        email: 'lova@example.com',
        motDePasse: 'password123',
        confirmationMotDePasse: 'password123',
        code: '123456',
      );
      expect(request.toJson(), {
        'nomUtilisateur': 'Lova',
        'email': 'lova@example.com',
        'motDePasse': 'password123',
        'confirmationMotDePasse': 'password123',
        'code': '123456',
      });
      final response = RegisterResponse.fromJson({
        'email': 'lova@example.com',
        'codeEnvoye': true,
        'validiteMinutes': 15,
      });
      expect(response.codeEnvoye, isTrue);
      expect(response.validiteMinutes, 15);
    },
  );

  test('client poll keeps current vote and option totals', () {
    final poll = Poll.fromJson({
      'id': 4,
      'question': 'Quelle musique ?',
      'dateFin': '2026-11-10T19:00:00Z',
      'options': [
        {
          'id': 1,
          'libelle': 'A',
          '_count': {'votes': 2},
        },
        {
          'id': 2,
          'libelle': 'B',
          '_count': {'votes': 3},
        },
      ],
      'votes': [
        {'optionId': 2},
      ],
    });
    expect(poll.selectedOptionId, 2);
    expect(poll.options.map((option) => option.votes), [2, 3]);
  });
}
