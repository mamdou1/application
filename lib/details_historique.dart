import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class DetailsHistoriqueDialog {
  // 🔥 MÉTHODE STATIQUE POUR AFFICHER LA DIALOGUE DES DÉTAILS
  static void show({
    required BuildContext context,
    required Map<String, dynamic> abonnement,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _DetailsAbonnementDialog(abonnement: abonnement);
      },
    );
  }
}

class _DetailsAbonnementDialog extends StatelessWidget {
  final Map<String, dynamic> abonnement;

  const _DetailsAbonnementDialog({required this.abonnement});

  @override
  Widget build(BuildContext context) {
    final typeService = abonnement['typeDeService'] ?? {};
    final gym = abonnement['gym'] ?? {};
    final String nomService = typeService['nom'] ?? 'Service inconnu';
    final String nomGym = gym['nom'] ?? 'Gym inconnu';
    final double prix = (abonnement['prixAbonnement'] ?? 0).toDouble();
    final String dateDebut = abonnement['dateDebutAbonnement'] ?? '';
    final String dateFin = abonnement['dateFinAbonnement'] ?? '';
    final String statut = abonnement['statut'] ?? '';
    final String periodAbonnement = abonnement['periodAbonnement'] ?? '';
    final String modePaiement = abonnement['modeDePaiement'] ?? '';
    final double nombreMois = (abonnement['nombreDeMois'] ?? 0).toDouble();
    final String? photoBase64 = gym['photo'];

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec photo du gym
            if (photoBase64 != null && photoBase64.isNotEmpty) ...[
              Center(
                child: CircleAvatar(
                  backgroundImage: MemoryImage(_decodeBase64(photoBase64)),
                  radius: 40,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Titre
            Center(
              child: Text(
                'Détails de l\'abonnement',
                style: TextStyle(
                  color: Colors.orange[900],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Service et Gym
            _buildDetailRow('Service', nomService),
            _buildDetailRow('Gym', nomGym),
            const SizedBox(height: 15),

            // Dates
            _buildDetailRow('Date de début', _formatDate(dateDebut)),
            _buildDetailRow('Date de fin', _formatDate(dateFin)),
            const SizedBox(height: 15),

            // Informations financières
            _buildDetailRow('Prix', '$prix FCFA'),
            _buildDetailRow('Période', _getPeriodLabel(periodAbonnement)),
            _buildDetailRow('Durée', '$nombreMois ${_getPeriodUnit(periodAbonnement)}'),
            const SizedBox(height: 15),

            // Statut et mode de paiement
            _buildDetailRow('Statut', _getStatutLabel(statut)),
            _buildDetailRow('Mode de paiement', _getModePaiementLabel(modePaiement)),

            const SizedBox(height: 25),

            // Bouton Fermer
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 WIDGET POUR UNE LIGNE DE DÉTAIL
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 MÉTHODE POUR FORMATER LA DATE
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Non spécifiée';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  // 🔥 MÉTHODE POUR TRADUIRE LA PÉRIODE
  String _getPeriodLabel(String period) {
    switch (period) {
      case 'JOURNALIER': return 'Journalier';
      case 'MENSUEL': return 'Mensuel';
      case 'TRIMESTRIEL': return 'Trimestriel';
      case 'SEMESTRIEL': return 'Semestriel';
      case 'ANNUEL': return 'Annuel';
      default: return period;
    }
  }

  // 🔥 MÉTHODE POUR OBTENIR L'UNITÉ DE PÉRIODE
  String _getPeriodUnit(String period) {
    switch (period) {
      case 'JOURNALIER': return 'jours';
      case 'MENSUEL': return 'mois';
      case 'TRIMESTRIEL': return 'trimestres';
      case 'SEMESTRIEL': return 'semestres';
      case 'ANNUEL': return 'années';
      default: return 'mois';
    }
  }

  // 🔥 MÉTHODE POUR TRADUIRE LE STATUT
  String _getStatutLabel(String statut) {
    switch (statut) {
      case 'EN_COURS': return 'En cours';
      case 'TERMINE': return 'Terminé';
      case 'EN_ATTENTE': return 'En attente';
      case 'PAUSE': return 'En pause';
      default: return statut;
    }
  }

  // 🔥 MÉTHODE POUR TRADUIRE LE MODE DE PAIEMENT
  String _getModePaiementLabel(String mode) {
    switch (mode) {
      case 'CASH': return 'Espèces';
      case 'CARD': return 'Carte bancaire';
      case 'MOBILE_MONEY': return 'Mobile Money';
      case 'VIREMENT': return 'Virement';
      default: return mode;
    }
  }

  // 🔥 MÉTHODE POUR DÉCODER LA BASE64
  Uint8List _decodeBase64(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      // Retourner une image par défaut si le décodage échoue
      return Uint8List(0);
    }
  }
}