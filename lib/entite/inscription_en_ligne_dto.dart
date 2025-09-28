class InscriptionEnLigneDTO {
  final String nom;
  final String prenom;
  final String adresse;
  final String email;
  final String telephone;
  final String genre;
  final String date_de_naissance; // 🔥 CHANGER ICI : dateDeNaissance → date_de_naissance
  final String password;

  InscriptionEnLigneDTO({
    required this.nom,
    required this.prenom,
    required this.adresse,
    required this.email,
    required this.telephone,
    required this.genre,
    required this.date_de_naissance, // 🔥 CHANGER ICI
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'prenom': prenom,
      'adresse': adresse,
      'email': email,
      'telephone': telephone,
      'genre': genre,
      'date_de_naissance': date_de_naissance, // 🔥 CHANGER ICI
      'password': password,
    };
  }
}