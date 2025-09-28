import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gestion_salle_de_sport/StockageDeToken.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:provider/provider.dart';

class MaGymPage extends StatefulWidget {
  final Map<String, dynamic>? userData; // 🔥 ACCEPTER LES DONNÉES UTILISATEUR

  const MaGymPage({super.key, this.userData});

  @override
  State<MaGymPage> createState() => _CreateMaGymPage();
}

class _CreateMaGymPage extends State<MaGymPage> {
  List<dynamic> gyms = [];
  bool _isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? userData; // 🔥 Données utilisateur

  @override
  void initState() {
    super.initState();
    _fetchUserGym();
    _getUserData(); // 🔥 Récupérer les données utilisateur
  }

  // 🔥 MÉTHODE POUR RÉCUPÉRER LES DONNÉES UTILISATEUR
  void _getUserData() {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    userData = stockageToken.userData;
    print("Données utilisateur dans ma_gym: $userData");
  }

  Future<void> _fetchUserGym() async{
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if(token == null || token.isEmpty){
      setState(() {
        errorMessage = 'Token manquant. Veuillez vous reconnecter.';
        _isLoading = false;
      });
      return;
    }
    try{
      final response = await http.get(Uri.parse(ApiEndpoints.gymsDeMembre),
      headers: {
        'Content-Type':'application/json',
        'Authorization':'Bearer $token',
      },
      );

      print('Réponse Api gyms utilisateur: Status ${response.statusCode}');

      if(response.statusCode == 200){
        setState(() {
          gyms = jsonDecode(response.body);
          _isLoading = false;
        });
      }else{
        setState(() {
          errorMessage = 'Erreur lors du chargement des gyms: ${response.statusCode}';
          _isLoading = false;
        });
      }
    }catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion : $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build( context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Center(
            child: Text("Ma salle de sport.",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
        ),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.orange[900],))
        : errorMessage != null
            ? Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 18))
            : gyms.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Text("Vous n'êtes abonné à aucune salle de sport", style: TextStyle(color: Colors.white, fontSize: 30)),
                      ),
                     )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1, //Cards carrées
                      ),
                      padding: const EdgeInsets.all(16),
                      itemCount: gyms.length,
                      itemBuilder: (context, index){
                        final gym = gyms[index];
                        final String nom = gym['nom'] ?? 'Nom inconnu';
                        final String? photoBase64 = gym['photo'];  //Assumer Base64

                        return GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(
                              context,
                              '/acceuille',
                              arguments: {
                                'id': gym['id'],
                              }, // Optionnel : passer l'ID du gym
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: photoBase64 != null && photoBase64.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                            child: Image.memory(
                                              base64Decode(photoBase64),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          )
                                        : Icon(Icons.home_work_outlined, color: Colors.orange[900], size: 60),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    nom,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
      )
    );
  }
}

