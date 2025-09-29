import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';
import 'details_historique.dart'; // 🔥 IMPORT DU NOUVEAU FICHIER

class HistoriquePage extends StatelessWidget {
  const HistoriquePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Historique();
  }
}

class Historique extends StatefulWidget {
  const Historique({super.key});

  @override
  State<Historique> createState() => _CreateHistoriquePage();
}

class _CreateHistoriquePage extends State<Historique> {
  List<dynamic> abonnements = [];
  bool _isLoading = true;
  String? errorMessage;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredAbonnements = [];

  @override
  void initState() {
    super.initState();
    _fetchHistoriqueAbonnements();
  }

  Future<void> _fetchHistoriqueAbonnements() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'Token manquant. Veuillez vous reconnecter';
        _isLoading = false;
      });
      return;
    }

    try {
      // Récupérer l'ID de l'utilisateur connecté depuis le token ou les données utilisateur
      final userData = stockageToken.userData;
      final int? userId = userData?['id'] as int?;

      if (userId == null) {
        setState(() {
          errorMessage = 'ID utilisateur non disponible';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(ApiEndpoints.historiqueAbonnement(userId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Réponse API Historique: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          abonnements = data;
          filteredAbonnements = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur lors du chargement de l\'historique: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  void _filterAbonnements(String query) {
    final results = abonnements.where((abonnement) {
      final nomService = abonnement['typeDeService']?['nom']?.toLowerCase() ?? '';
      final nomGym = abonnement['gym']?['nom']?.toLowerCase() ?? '';
      return nomService.contains(query.toLowerCase()) ||
          nomGym.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredAbonnements = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.orange[900], size: 25),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 10),
            Text(
              "Historique des Abonnements",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: RefreshIndicator(
          onRefresh: _fetchHistoriqueAbonnements,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
              : errorMessage != null
              ? Center(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          )
              : abonnements.isEmpty
              ? const Center(
            child: Text(
              'Aucun abonnement trouvé',
              style: TextStyle(color: Colors.white),
            ),
          )
              : Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterAbonnements,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher par service ou gym...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.orange[900]!),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredAbonnements.length,
                  itemBuilder: (context, index) {
                    final abonnement = filteredAbonnements[index];
                    final typeService = abonnement['typeDeService'] ?? {};
                    final gym = abonnement['gym'] ?? {};
                    final String nomService = typeService['nom'] ?? 'Service inconnu';
                    final String nomGym = gym['nom'] ?? 'Gym inconnu';
                    final String dateDebut = abonnement['dateDebutAbonnement'] ?? '';
                    final String? photoBase64 = gym['photo'];
                    final String statut = abonnement['statut'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        // 🔥 APPEL SIMPLIFIÉ VERS LE NOUVEAU FICHIER
                        DetailsHistoriqueDialog.show(
                          context: context,
                          abonnement: abonnement,
                        );
                      },
                      child: SizedBox(
                        height: 110,
                        child: Card(
                          color: Colors.grey[300],
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            // leading: photoBase64 != null && photoBase64.isNotEmpty
                            //     ? CircleAvatar(
                            //   backgroundImage: MemoryImage(base64Decode(photoBase64)),
                            //   radius: 25,
                            // )
                            //     : Icon(Icons.fitness_center, color: Colors.orange[900], size: 40),
                            title: Text(
                              nomService,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   nomGym,
                                //   style: const TextStyle(color: Colors.black54),
                                // ),
                                Text(
                                  'Début: ${_formatDate(dateDebut)}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 15),
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStatutChip(statut),
                                //const Icon(Icons.info_outline, color: Colors.orange),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 WIDGET POUR LE CHIP DE STATUT
  Widget _buildStatutChip(String statut) {
    Color chipColor;
    String statutText;

    switch (statut) {
      case 'EN_COURS':
        chipColor = Colors.green;
        statutText = 'En cours';
        break;
      case 'TERMINE':
        chipColor = Colors.red;
        statutText = 'Terminé';
        break;
      case 'EN_ATTENTE':
        chipColor = Colors.orange;
        statutText = 'En attente';
        break;
      case 'PAUSE':
        chipColor = Colors.blue;
        statutText = 'En pause';
        break;
      default:
        chipColor = Colors.grey;
        statutText = statut;
    }

    return Chip(
      label: Text(
        statutText,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  // 🔥 MÉTHODE POUR FORMATER LA DATE
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}