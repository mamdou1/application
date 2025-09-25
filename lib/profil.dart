import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return Profil();
  }
}

class Profil extends StatefulWidget {
  const Profil({super.key});


  @override
  State<Profil> createState()=> _CreateProfilPage();
}

class _CreateProfilPage extends State<Profil> {
  Map<String, dynamic> args = {};
  Uint8List? profileImageBytes; // Pour stocker les octets de l'image décodée

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(args.isEmpty){
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      print("Args in Profil: $args"); // Vérifiez les valeurs
      _loadProfileImage(); // Charge l'image au démarrage
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Charge les données au démarrage
  }

  Future<void> _loadInitialData() async {
    args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    print("Args in Acceuille: $args"); // Vérifiez les valeurs
    await _loadProfileImage(); // Attend le chargement de l'image
  }

  Future<void> _loadProfileImage() async {
    final profilBase64 = args["profil"] ?? "";
    if (profilBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profilBase64);
        if (mounted) { // Vérifie si le widget est encore monté
          setState(() {
            profileImageBytes = bytes;
          });
        }
      } catch (e) {
        print("Erreur décodage image dans Acceuille : $e");
      }
    }
  }

  @override
  Widget build( context) {
    String nom = args["nom"] ?? "";
    String prenom = args["prenom"] ?? "";
    String email = args["email"] ?? "";
    String adresse = args["adresse"] ?? "";
    String telephone = args["telephone"] ?? "";
    String genre = args["genre"] ?? "";
    String role = args["role"] ?? "";
    String dateDeNaissanceRaw = args["date_de_naissance"] ?? "";
    String dateCreationRaw = args["date_creation"] ?? "";

    String dateDeNaissance = dateDeNaissanceRaw.isNotEmpty
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(dateDeNaissanceRaw))
        : "Non spécifiée";
    String dateCreation = dateCreationRaw.isNotEmpty
        ? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateCreationRaw))
        : "Non spécifiée";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
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
              "Création de compte",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0, // Positionne le conteneur en bas
            left: 0,
            right: 0,
            child: Container(
              height: 650,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20), // 👈 tous les coins arrondis
              ),
              child: Center(
                child: SizedBox(
                  height: 630,
                  width: 340,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    color: Colors.grey[300],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: 60),
                          Center(
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey[400],
                                  child: profileImageBytes != null
                                      ? ClipOval(
                                    child: Image.memory(
                                      profileImageBytes!,
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    ),
                                  )
                                      : Icon(Icons.person, size: 50, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                const Image(
                                  image: AssetImage('images/camera-pofil.png'),
                                  // width: 300,
                                  // height: 100,
                                  fit: BoxFit.contain,
                                ),
                                    Text("$prenom $nom ", style: TextStyle(fontSize: 20),),
                                    SizedBox(width: 30),
                                    Text(role, style: TextStyle(color: Colors.grey[600], fontSize: 20),),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text("Adresse : ", style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: 20),
                              Text(adresse, style: TextStyle(color: Colors.grey[600]),),
                            ],
                          ),
                          SizedBox(height: 40),
                          Row(
                            children: [
                              Text("Email : ", style: TextStyle(fontWeight: FontWeight.bold),),
                              SizedBox(width: 20),
                              Text(email, style: TextStyle(color: Colors.grey[600]),),
                            ],
                          ),
                          SizedBox(height: 40),
                          Row(
                            children: [
                              Text("Date de naissance : ", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text(dateDeNaissance, style: TextStyle(color: Colors.grey[600]),),
                            ],
                          ),
                          SizedBox(height: 40),
                          Row(
                            children: [
                              Text("Téléphone : ", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text(telephone, style: TextStyle(color: Colors.grey[600]),),
                            ],
                          ),
                          SizedBox(height: 40),
                          Row(
                            children: [
                              Text("Genre : ", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text(genre, style: TextStyle(color: Colors.grey[600]),),
                            ],
                          ),
                          SizedBox(height: 40),
                          Row(
                            children: [
                              Text("Date de créaction : ", style: TextStyle(fontWeight: FontWeight.bold),),
                              Text(dateCreation, style: TextStyle(color: Colors.grey[600]),),
                            ],
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}