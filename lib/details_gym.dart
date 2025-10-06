import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'demande_inscription.dart'; // 🔥 IMPORT DU NOUVEAU FICHIER
import 'StockageDeToken.dart';

class DetailsGymPage extends StatelessWidget {
  const DetailsGymPage({super.key});

  @override
  Widget build(BuildContext context) {
    return detailsGym();
  }
}

class detailsGym extends StatefulWidget {
  const detailsGym({super.key});

  @override
  State<detailsGym> createState() => _CreatedetailsGymPage();
}

class _CreatedetailsGymPage extends State<detailsGym> {
  Map<String, dynamic> gymDetails = {};
  List<dynamic> typeService = [];
  bool _isLoading = true;
  String? errorMessage;
  int id = 0; // ID récupéré

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupérez les arguments ici, pas dans initState
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    id = args?['id'] ?? 0;
    if (id != 0) {
      _fetchGymDetails();
      _fetchTypesService(); // 🔥 AJOUT : Charger les types de service
    } else {
      setState(() {
        errorMessage = 'ID du gym non fourni.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchGymDetails() async {
    // Récupérez le token depuis le Provider
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'Token manquant. Veuillez vous reconnecter.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getGymById(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Authentification
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          gymDetails = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() { // Ajout de setState ici
          errorMessage = 'Erreur lors du chargement des détails: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() { // Ajout de setState pour le catch
        errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  // 🔥 NOUVELLE MÉTHODE : Récupérer les types de service du gym
  Future<void> _fetchTypesService() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if (token == null || token.isEmpty) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.getTypeServiceByIdGym(id)), // Utilisez votre endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> allServices = jsonDecode(response.body);

        setState(() {
          typeService = allServices;
          _isLoading = false; // Arrêter le chargement une fois les services chargés
        });
      } else {
        setState(() {
          errorMessage = 'Erreur lors du chargement des services: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion lors du chargement des services: $e';
        _isLoading = false;
      });
    }
  }

  // 🔥 MÉTHODE POUR AFFICHER UN SERVICE
  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service['nom'] ?? 'Service sans nom',
              style: TextStyle(
                color: Colors.orange[900],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            // Tarifs
            if (service['tarifUnique'] != null)
              _buildTarifLine('Tarif unique', service['tarifUnique']),

            if (service['tarifHomme'] != null)
              _buildTarifLine('Tarif homme', service['tarifHomme']),

            if (service['tarifFemme'] != null)
              _buildTarifLine('Tarif femme', service['tarifFemme']),

            if (service['fraisInscription'] != null)
              _buildTarifLine('Frais d\'inscription', service['fraisInscription']),
          ],
        ),
      ),
    );
  }

  Widget _buildTarifLine(String label, dynamic tarif) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            '${tarif.toString()} FCFA', // Adaptez la devise selon vos besoins
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  // 🔥 MÉTHODE POUR AFFICHER LA BOÎTE DE DIALOGUE
  void _showInscriptionDialog() {
    if (typeService.isEmpty) {
      _showError("Aucun service disponible pour ce gym.");
      return;
    }

    DemandeInscriptionDialog.show(
      context: context,
      gymId: id,
      typesService: typeService,
      onSuccess: (message) {
        _showSuccess(message);
      },
      onError: (error) {
        _showError(error);
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }



  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back, color: Colors.orange[900], size: 25),
            ),
            SizedBox(width: 50),
            const Text('Détails du gym', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.black,
      ),
        body: Container(
          height: double.infinity,
          color: Colors.black, // ✅ fond noir complet
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
              : errorMessage != null
              ? Center(child: Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 18)))
              : gymDetails.isEmpty
              ? const Center(child: Text('Aucun détail disponible', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gymDetails['photo'] != null && gymDetails['photo'].isNotEmpty
                    ? Container(
                      height: 300,
                      color: Colors.grey,
                      child: Image.memory(
                                        base64Decode(gymDetails['photo']),
                                        width: double.infinity,
                                        height: 300,
                                        fit: BoxFit.cover,
                                      ),
                    )
                    : Center(child: Icon(Icons.home_work_outlined, color: Colors.orange[900], size: 50)),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${gymDetails['nom'] ?? 'Inconnu'}', style: const TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.pin_drop_outlined, color: Colors.orange[900]),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Adresse:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 35.0),
                                  child: Text(
                                    '${gymDetails['adresse'] ?? 'Adresse non disponible'}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 30),

                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.phone, color: Colors.orange[900]),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Téléphone:',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 35.0),
                                  child: Text(
                                    '${gymDetails['telephone'] ?? 'Téléphone non disponible'}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange[900]),
                                const SizedBox(width: 10),
                                Text(
                                  'Description:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text(
                                '${gymDetails['description'] ?? 'Aucune description'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 🔥 NOUVELLE SECTION : Types de service
                      Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.fitness_center, color: Colors.orange[900]),
                                SizedBox(width: 10),
                                Text(
                                  'Services proposés:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),

                            if (typeService.isEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 35.0),
                                child: Text(
                                  'Aucun service disponible pour ce gym',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: typeService.map((service) {
                                  return _buildServiceCard(service);
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),


                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.email_outlined, color: Colors.orange[900]),
                                const SizedBox(width: 10),
                                Text(
                                  'Email:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.only(left: 35.0),
                              child: Text(
                                '${gymDetails['email'] ?? 'Email non disponible'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: SizedBox(
                          height: 50,
                          width: 330,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : ElevatedButton(
                            onPressed: _showInscriptionDialog,   // 🔥 APPEL SIMPLIFIÉ
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[900],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.all(12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                            child: const Text(
                              "Envoyer une demande d'inscription",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),

                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}