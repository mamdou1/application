import 'package:flutter/material.dart';

class StockageDeToken with ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _userData;

  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  // Sauvegarder le token et les données utilisateur
  void sauvegarderToken(String token, Map<String, dynamic> userData) {
    _token = token;
    _userData = userData;
    notifyListeners();
  }

  // Effacer le token (déconnexion)
  void effacerToken() {
    _token = null;
    _userData = null;
    notifyListeners();
  }

  // Vérifier si l'utilisateur est connecté
  bool get estConnecte => _token != null;

  // Récupérer une donnée utilisateur spécifique
  String? obtenirDonneeUtilisateur(String cle) {
    return _userData?[cle]?.toString();
  }
}

