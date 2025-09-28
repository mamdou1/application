class ApiEndpoints {
  // 🔗 Base URL de ton backend (utilisez baseUrl pour émulateur, baseUrls pour appareil physique)
  static const String baseUrl = 'http://10.0.2.2:8080'; // Pour émulateur Android
  static const String baseUrls = 'http://192.168.137.1:8080'; // Pour appareil physique ou réseau local

  // 🔐 Authentification
  static const String connexion = '$baseUrl/api/auth/connexion';

  // 👤 Utilisateurs et Profil
  static String profil(int id) => '$baseUrl/api/users/profil/$id';
  static String modifierProfil(int id) => '$baseUrl/api/users/modifier-membre/$id';
  static const String changerMotDePasse = '$baseUrl/api/users/changer';

  // 📝 Inscription et Demandes
  static const String inscriptionEnLigne = '$baseUrl/api/demandeInscriptions/inscriptin/en-ligne';
  static String soumettreDemande (int id) => '$baseUrl/api/demandeInscriptions/soumis/$id';

  //  liste des gyms
  static String listeGym = '$baseUrl/api/gyms';
  static String getGymById(int id) => '$baseUrl/api/gyms/$id';
  static String demande (int id) =>'$baseUrl/api/demandeInscriptions/soumis/$id';

  //  types de service
  static String listeTypeService = '$baseUrl/api/services';
  //static String getTypeServiceById (int id) => '$baseUrl/api/services/$id';
  static String getTypeServiceByIdGym (int id) => '$baseUrl/api/services/app/$id';

  //  Les gym de l'utilisateur
  static String gymsDeMembre = '$baseUrl/api/users/gyms';

  // historique
  static String historiqueAbonnement (int id) => '$baseUrl/api/abonnements/historique/$id';

  //  Evénnement
  static String evennement = '$baseUrl/api/evenements/liste';
  static String detailEvennement (int id) => '$baseUrl/api/evenements/getById/$id';

  //  Coaching
  static String coaching = '$baseUrl/api/coachings/liste';
  static String detailCoaching (int id) => '$baseUrl/api/coachings/mettre_a-jour/$id';

// Ajoutez d'autres endpoints ici au besoin, par exemple :
// static const String ajoutMembre = '$baseUrl/api/users/ajouter/membre';
// static String modifierMembre(int id) => '$baseUrl/api/users/modifier-membre/$id';
}

