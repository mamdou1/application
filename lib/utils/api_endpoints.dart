class ApiEndpoints {
  // 🔗 Base URL de ton backend (utilisez baseUrl pour émulateur, baseUrls pour appareil physique)
  static const String baseUrls = 'http://10.0.2.2:8080'; // Pour émulateur Android
  static const String baseUrl = 'http://192.168.1.11:8080'; // Pour appareil physique ou réseau local

  // 🔐 Authentification
  static const String connexion = '$baseUrls/api/auth/connexion';

  // 👤 Utilisateurs et Profil
  static String profil(int id) => '$baseUrls/api/users/profil/$id';
  static String modifierProfil(int id) => '$baseUrls/api/users/modifier-membre/$id';
  static const String changerMotDePasse = '$baseUrls/api/users/changer';

  // 📝 Inscription et Demandes
  static const String inscriptionEnLigne = '$baseUrls/api/demandeInscriptions/inscriptin/en-ligne';
  static String soumettreDemande (int id) => '$baseUrls/api/demandeInscriptions/soumis/$id';

  //  liste des gyms
  static String listeGym = '$baseUrls/api/gyms';
  static String getGymById(int id) => '$baseUrls/api/gyms/$id';
  static String demande (int id) =>'$baseUrls/api/demandeInscriptions/soumis/$id';

  //  Liste des paiements
  static String listePaiement = '$baseUrls/api/paiements';
  static String listePaiementType(String type) => '$baseUrls/api/paiements/type/$type';
  static String listePaiementPeriode = '$baseUrls/api/paiements/periode';
  static String listePaiementToutPeriode = '$baseUrls/api/paiements/total-periode';


  //  Statue abonnement
  static String nombreMembreActifs = '$baseUrls/api/abonnements/nombre/membre/actif';
  static String nombreMembreExpirer = '$baseUrls/api/abonnements/nombre/membre/expirer';
  static String nombreMembreBientotExpirer = '$baseUrls/api/abonnements/nombre/membre/bientot-expirer';

  // Statistic abonnement
  static String nombreabonnementJour = '$baseUrls/api/abonnements/nombre/journalier';
  static String montantabonnementJour = '$baseUrls/api/abonnements/montant/journalier';

  static String nombreabonnementHebdomadaire = '$baseUrls/api/abonnements/nombre/hebdomadaire';
  static String montantabonnementHebdomadaire = '$baseUrls/api/abonnements/montant/hebdomadaire';

  static String nombreabonnementMensuel = '$baseUrls/api/abonnements/nombre/mensuel';
  static String montantabonnementMensuel = '$baseUrls/api/abonnement/montant/mensuel';

  static String nombreabonnementAnuuel = '$baseUrls/api/abonnements/nombre/annuel';
  static String montantabonnementAnnuel = '$baseUrls/api/abonnements/montant/annuel';


  // Statistic Vente
  static String nombreVenteJour = '$baseUrls/api/ventes/statistiques/nombre/journalier';
  static String montantVenteJour = '$baseUrls/api/ventes/statistiques/montant/journalier';

  static String nombreVenteHebdomadaire = '$baseUrls/api/ventes/statistiques/nombre/hebdomadaire';
  static String montantVenteHebdomadaire = '$baseUrls/api/ventes/statistiques/montant/hebdomadaire';

  static String nombreVenteMensuel = '$baseUrls/api/ventes/statistiques/nombre/mensuel';
  static String montantVenteMensuel = '$baseUrls/api/ventes/statistiques/montant/mensuel';

  static String nombreVenteAnuuel = '$baseUrls/api/ventes/statistiques/nombre/annuel';
  static String montantVenteAnnuel = '$baseUrls/api/ventes/statistiques/montant/annuel';


  //  types de service
  static String listeTypeService = '$baseUrls/api/services';
  //static String getTypeServiceById (int id) => '$baseUrl/api/services/$id';
  static String getTypeServiceByIdGym (int id) => '$baseUrls/api/services/app/$id';

  //  Les gym de l'utilisateur
  static String gymsDeMembre = '$baseUrls/api/users/gyms';

  // historique
  static String historiqueAbonnement(int userId) => '$baseUrls/api/abonnements/historique';

  //  Notificatiion
  static String notificationUser = '$baseUrls/api/notifications/user_notification';
  static String notificationGym = '$baseUrls/api/notifications/gym_notification';
  //static String notificationMarqueCommeLu (int id) => '$baseUrls/api/notifications/user_notification/{id}/lu';

  //  Evénnement
  static String evennement = '$baseUrls/api/evenements/liste';
  static String detailEvennement (int id) => '$baseUrls/api/evenements/getById/$id';

  //  Coaching
  static String coaching = '$baseUrls/api/coachings/liste';
  static String detailCoaching (int id) => '$baseUrls/api/coachings/mettre_a-jour/$id';

  // Boutique - Liste des produits
  //static String listeProduits = '$baseUrls/api/produits/lister';
  // 🛍️ ENDPOINTS PRODUITS
  static const String ajouterProduit = '$baseUrls/api/produits/ajouter';
  static const String listeProduits = '$baseUrls/api/produits/lister';
  //static const String getAllProduits = '$baseUrls/api/produits';
  static String getPhotoProduit(int id) => '$baseUrls/api/produits/photo/$id';
  static String modifierProduit(int id) => '$baseUrls/api/produits/modifier/$id';
  static String supprimerProduit(int id) => '$baseUrls/api/produits/supprimer/$id';
  static String detailProduit(int produitId) => '$baseUrls/api/produits/$produitId';

  // 🛒 Endpoints Panier
  static const String creerPanier = '$baseUrls/api/paniers/creer_panier';
  static String ajouterProduitPanier(int panierId, int produitId) =>
      '$baseUrls/api/paniers/ajout_produit/$panierId/$produitId';
  static String modifierQuantitePanier(int ligneId) =>
      '$baseUrls/api/paniers/modifier_quantite/$ligneId';
  static String supprimerLignePanier(int ligneId) =>
      '$baseUrls/api/paniers/supprimer_ligne/$ligneId';
  static String supprimerPanier(int panierId) =>
      '$baseUrls/api/paniers/supprimer_panier/$panierId';
  static String envoyerPanier(int panierId) =>
      '$baseUrls/api/paniers/envoie_panier/$panierId';
  static const String paniersEnAttente = '$baseUrls/api/paniers/attente';

// Ajoutez d'autres endpoints ici au besoin, par exemple :
// static const String ajoutMembre = '$baseUrl/api/users/ajouter/membre';
// static String modifierMembre(int id) => '$baseUrl/api/users/modifier-membre/$id';
}

