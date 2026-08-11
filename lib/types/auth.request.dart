class RegisterRequest {
  final String nomUtilisateur;
  final String email;
  final String motDePasse;
  final String confirmationMotDePasse;

  RegisterRequest({
    required this.nomUtilisateur,
    required this.email,
    required this.motDePasse,
    required this.confirmationMotDePasse,
  });

  Map<String, dynamic> toJson() {
    return {
      'nomUtilisateur': nomUtilisateur,
      'email': email,
      'motDePasse': motDePasse,
      'confirmationMotDePasse': confirmationMotDePasse,
    };
  }
}

class LoginRequest {
  final String email;
  final String motDePasse;

  LoginRequest({required this.email, required this.motDePasse});

  Map<String, dynamic> toJson() {
    return {'email': email, 'motDePasse': motDePasse};
  }
}
