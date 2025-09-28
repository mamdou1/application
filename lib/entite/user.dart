class User {
  String telephone;
  String password;

  User(this.telephone, this.password);

  // Pour encoder en JSON (POST)
  Map<String, dynamic> toJson() {
    return {
      'telephone': telephone,
      'password': password,
    };
  }

  // Pour décoder depuis JSON (réponse du backend)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['telephone'] ?? '', json['password'] ?? '');
  }
}

