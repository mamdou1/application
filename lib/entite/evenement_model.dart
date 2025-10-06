class EvenementModel {
  final int id;
  final String nom;
  final String description;
  final String statutEvent;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String createdBy;
  final String gymNom;

  EvenementModel({
    required this.id,
    required this.nom,
    required this.description,
    required this.statutEvent,
    required this.dateDebut,
    required this.dateFin,
    required this.createdBy,
    required this.gymNom,
  });

  factory EvenementModel.fromJson(Map<String, dynamic> json) {
    return EvenementModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      description: json['description'] ?? '',
      statutEvent: json['statutEvent'] ?? '',
      dateDebut: DateTime.parse(json['dateDebut']),
      dateFin: DateTime.parse(json['dateFin']),
      createdBy: json['createdBy']?['nom'] ?? 'Inconnu',
      gymNom: json['gym']?['nom'] ?? 'Gym inconnu',
    );
  }
}