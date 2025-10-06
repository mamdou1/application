import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_salle_de_sport/StockageDeToken.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:provider/provider.dart';
// import 'details_gym.dart'; // Importez si nécessaire pour la navigation

class ChoixGymPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChoixGym();
  }
}

class ChoixGym extends StatefulWidget {
  @override
  State<ChoixGym> createState() => _ChoixGymState();
}

class _ChoixGymState extends State<ChoixGym> {
  List<dynamic> gyms = [];
  bool _isLoading = true;
  String? errorMessage;

  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredGyms = [];

  @override
  void initState() {
    super.initState();
    _fetchGyms();
  }

  Future<void> _fetchGyms() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if(token == null || token.isEmpty){
      setState(() {
        errorMessage = 'Token manquant. Veuillez vous reconnecter';
        _isLoading = false;
      });
    }

    try {
      final response = await http.get(
          Uri.parse(ApiEndpoints.listeGym),
        headers: {
            'Content-Type':'application/json',
            'Authorization': 'Bearer $token'   // Ajout du token
        }
      );
      print('Réponse API: Status ${response.statusCode} - Body: ${response.body}'); // Log pour déboguer

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          gyms = jsonDecode(response.body);
          filteredGyms = data; // copie initiale
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur lors du chargement des gyms: ${response.statusCode}';
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

  void _filterGyms(String query) {
    final results = gyms.where((gym) {
      final nom = gym['nom']?.toLowerCase() ?? '';
      return nom.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredGyms = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(child: const Text("Liste des Salles de sport", style: TextStyle(color: Colors.white))),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: RefreshIndicator(
          onRefresh: _fetchGyms, // Permet de rafraîchir en tirant vers le bas
          child: _isLoading
              ?  Center(child: CircularProgressIndicator(color: Colors.orange[900]))
              : errorMessage != null
              ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 18)))
              : gyms.isEmpty
              ? const Center(child: Text('Aucune salle de sport disponible', style: TextStyle(color: Colors.white)))
              : Column(
                children: [
                    Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterGyms,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Rechercher par nom...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[900],
                        // border: OutlineInputBorder(
                        //   borderRadius: BorderRadius.circular(12),
                        //   borderSide: BorderSide(color: Colors.orange[900]!),
                        // ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange[900]!),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                                itemCount: filteredGyms.length,
                                itemBuilder: (context, index) {
                    final gym = filteredGyms[index];
                    final String nom = gym['nom'] ?? 'Nom inconnu';
                    final String? photoBase64 = gym['photo']; // Assumez que c'est déjà une chaîne Base64

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/details_gym',
                          arguments: {'id': gym['id']},
                        );
                      },
                      child: SizedBox(
                        height: 75,
                        child: Card(
                          color: Colors.grey[300],
                          child: Center(
                            child: ListTile(
                              leading: photoBase64 != null && photoBase64.isNotEmpty
                                  ? CircleAvatar(
                                backgroundImage: MemoryImage(base64Decode(photoBase64)),
                                radius: 30,
                              )
                                  :  Icon(Icons.home_work_outlined, color: Colors.orange[900], size: 40),
                              title: Text(nom, style: const TextStyle(color: Colors.black, fontSize: 18)),
                              trailing:  Icon(Icons.arrow_forward_ios, color: Colors.orange[900]),
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
}

