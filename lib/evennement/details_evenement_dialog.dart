import 'package:flutter/material.dart';

import '../entite/evenement_model.dart';

class DetailsEvenementDialog {
  static void show({
    required BuildContext context,
    required EvenementModel evenement,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _DetailsEvenementDialogContent(evenement: evenement);
      },
    );
  }
}

class _DetailsEvenementDialogContent extends StatelessWidget {
  final EvenementModel evenement;

  const _DetailsEvenementDialogContent({required this.evenement});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Center(
              child: Text(
                'Détails de l\'événement',
                style: TextStyle(
                  color: Colors.orange[900],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Nom de l'événement
            _buildDetailRow('Événement', evenement.nom),

            // Description
            if (evenement.description.isNotEmpty)
              _buildDetailRow('Description', evenement.description),

            // Statut
            _buildDetailRow('Statut', _getStatutLabel(evenement.statutEvent)),

            // Gym
            _buildDetailRow('Salle de sport', evenement.gymNom),

            // Créé par
            _buildDetailRow('Créé par', evenement.createdBy),

            // Dates
            _buildDetailRow('Début', _formatDateTime(evenement.dateDebut)),
            _buildDetailRow('Fin', _formatDateTime(evenement.dateFin)),

            // Durée
            _buildDetailRow('Durée', _calculateDuration(evenement.dateDebut, evenement.dateFin)),

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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  String _getStatutLabel(String statut) {
    switch (statut) {
      case 'EN_COURS': return 'En cours';
      case 'EN_ATTENTE': return 'En attente';
      case 'TERMINER': return 'Terminé';
      default: return statut;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _calculateDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours h ${minutes > 0 ? '$minutes min' : ''}';
    } else {
      return '$minutes min';
    }
  }
}