import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';

// ✅ Boîte de dialogue modale avec fond sombre
// ✅ Liste déroulante des types de service disponibles
// ✅ Spinner pour la période d'abonnement (Journalier, Mensuel, etc.)
// ✅ Champ numérique pour la durée avec texte d'aide contextuel
// ✅ Validation des champs avant envoi
// ✅ Boutons Annuler/Envoyer avec actions appropriées
// ✅ Design cohérent avec votre thème (couleurs orange/noir)
// ✅ Gestion d'erreurs et messages utilisateur




class DemandeInscriptionDialog {
  // 🔥 MÉTHODE STATIQUE POUR AFFICHER LA DIALOGUE
  static void show({
    required BuildContext context,
    required int gymId,
    required List<dynamic> typesService,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _DemandeInscriptionDialogContent(
          gymId: gymId,
          typesService: typesService,
          onSuccess: onSuccess,
          onError: onError,
        );
      },
    );
  }
}

class _DemandeInscriptionDialogContent extends StatefulWidget {
  final int gymId;
  final List<dynamic> typesService;
  final Function(String) onSuccess;
  final Function(String) onError;

  const _DemandeInscriptionDialogContent({
    required this.gymId,
    required this.typesService,
    required this.onSuccess,
    required this.onError,
  });

  @override
  __DemandeInscriptionDialogContentState createState() => __DemandeInscriptionDialogContentState();
}

class __DemandeInscriptionDialogContentState extends State<_DemandeInscriptionDialogContent> {
  // Variables d'état
  int? _selectedServiceId;
  String? _selectedServiceName;
  String _selectedPeriod = 'MENSUEL';
  final TextEditingController _nombrePeriodeController = TextEditingController();
  final List<String> _periods = ['JOURNALIER', 'MENSUEL', 'TRIMESTRIEL', 'SEMESTRIEL', 'ANNUEL'];
  bool _isLoading = false;

  @override
  void dispose() {
    _nombrePeriodeController.dispose();
    super.dispose();
  }

  // 🔥 MÉTHODE POUR OBTENIR LE LIBELLÉ DE LA PÉRIODE EN FRANÇAIS
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

  // 🔥 MÉTHODE POUR OBTENIR LE TEXTE D'AIDE
  String _getHintText(String period) {
    switch (period) {
      case 'JOURNALIER': return 'Ex: 30 pour 30 jours';
      case 'MENSUEL': return 'Ex: 6 pour 6 mois';
      case 'TRIMESTRIEL': return 'Ex: 2 pour 2 trimestres';
      case 'SEMESTRIEL': return 'Ex: 1 pour 1 semestre';
      case 'ANNUEL': return 'Ex: 2 pour 2 années';
      default: return 'Entrez le nombre';
    }
  }

  // 🔥 MÉTHODE POUR VALIDER LES CHAMPS
  bool _validerChamps() {
    if (_selectedServiceId == null) {
      widget.onError("Veuillez sélectionner un type de service.");
      return false;
    }

    if (_nombrePeriodeController.text.isEmpty) {
      widget.onError("Veuillez saisir le nombre de ${_getPeriodUnit(_selectedPeriod)}.");
      return false;
    }

    final nombre = int.tryParse(_nombrePeriodeController.text);
    if (nombre == null || nombre <= 0) {
      widget.onError("Veuillez saisir un nombre valide.");
      return false;
    }

    return true;
  }

  // 🔥 MÉTHODE POUR ENVOYER LA DEMANDE AU BACKEND
  Future<void> _envoyerDemande() async {
    if (!_validerChamps()) return;

    setState(() {
      _isLoading = true;
    });

    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if (token == null || token.isEmpty) {
      widget.onError("Token manquant. Veuillez vous reconnecter.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {

      // 🔥 AJOUT DE LOGS POUR DÉBOGUER
      print("=== DONNÉES ENVOYÉES ===");
      print("Gym ID: ${widget.gymId}");
      print("Service ID: $_selectedServiceId");
      print("Période: $_selectedPeriod");
      print("Nombre période: ${_nombrePeriodeController.text}");
      print("Date début: ${DateTime.now().toIso8601String()}");

      // Préparer les données pour l'API
      final Map<String, dynamic> demandeData = {
        'typeDeService': _selectedServiceId,
        'periodAbonnement': _selectedPeriod,
        'nombreDeMois': int.parse(_nombrePeriodeController.text),
        // 'dateDebut': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(ApiEndpoints.soumettreDemande(widget.gymId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(demandeData),
      );

      if (response.statusCode == 201) {
        final successMessage = response.body; // ✅ réponse brute en texte
        widget.onSuccess(successMessage);
        Navigator.of(context).pop();
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ??
            'Erreur lors de l\'envoi de la demande (${response.statusCode})';
        widget.onError(errorMessage);
      }
    } catch (e) {
      widget.onError("Erreur de connexion: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            "Demande d'inscription",
            style: TextStyle(
              color: Colors.orange[900],
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Liste déroulante pour les types de service
                Text(
                  "Type de service:",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedServiceId,
                      hint: Text(
                        "Choisir un service",
                        style: TextStyle(color: Colors.grey),
                      ),
                      icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
                      isExpanded: true,
                      items: widget.typesService.map((service) {
                        return DropdownMenuItem<int>(
                          value: service['id'],
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              service['nom'] ?? 'Service sans nom',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedServiceId = newValue;
                          final selectedService = widget.typesService.firstWhere(
                                (service) => service['id'] == newValue,
                            orElse: () => {},
                          );
                          _selectedServiceName = selectedService['nom'];
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Spinner pour la période d'abonnement
                Text(
                  "Période d'abonnement:",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPeriod,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.orange),
                      isExpanded: true,
                      items: _periods.map((String period) {
                        return DropdownMenuItem<String>(
                          value: period,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              _getPeriodLabel(period),
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPeriod = newValue!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Champ pour le nombre de période
                Text(
                  "Nombre de ${_getPeriodUnit(_selectedPeriod)}:",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _nombrePeriodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    hintText: _getHintText(_selectedPeriod),
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          actions: [
            // Bouton Annuler
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Annuler",
                style: TextStyle(color: Colors.grey),
              ),
            ),

            // Bouton Envoyer
            ElevatedButton(
              onPressed: _isLoading ? null : _envoyerDemande,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[900],
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text("Envoyer"),
            ),
          ],
        );
      },
    );
  }
}