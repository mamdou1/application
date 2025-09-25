import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AcceuillePage extends StatelessWidget {
  const AcceuillePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Acceuille();
  }
}

class Acceuille extends StatefulWidget {
  const Acceuille({super.key});

  @override
  State<Acceuille> createState() => _CreateAcceuillePage();
}

class _CreateAcceuillePage extends State<Acceuille> {
  Uint8List? profileImageBytes;
  Map<String, dynamic> args = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if(args.isEmpty){
      args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      print("Args in Profil: $args"); // Vérifiez les valeurs
      _loadProfileImage(); // Charge l'image au démarrage
    }
  }

  Future<void> _loadProfileImage() async {
    final profilBase64 = args["profil"] ?? "";
    if (profilBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profilBase64);
        setState(() {
          profileImageBytes = bytes;
        });
      } catch (e) {
        print("Erreur décodage image : $e");
      }
    }
  }

  static Uint8List _decodeBase64(String base64String) {
    return base64Decode(base64String);
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Déconnexion réussie.")));
    // Efface les données si tu utilises SharedPreferences ou autre
    // Exemple : SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.clear();

    // Redirection vers la page de connexion
    Navigator.pushNamedAndRemoveUntil(context, "/connexion", (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    String nom = args["nom"] ?? "";
    String prenom = args["prenom"] ?? "";
    String role = args["role"] ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.white, size: 25),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 25),
            onSelected: (value) {
              if (value == "profil") {
                Navigator.pushReplacementNamed(
                    context,
                    "/profil",
                    arguments: {
                      "nom": args["nom"],
                      "prenom": args["prenom"],
                      "email": args["email"],
                      "adresse": args["adresse"],
                      "telephone": args["telephone"],
                      "genre": args["genre"],
                      "role": args["role"],
                      "date_de_naissance": args["date_de_naissance"],
                      "date_creation": args["date_creation"],
                      "profil": args["profil"],
                    }
                );
              } else if (value == "mot de passe") {
                Navigator.pushNamed(context, "/changer_password");
              } else if (value == "a propos") {
                Navigator.pushNamed(context, "/a_propos");
              } else if (value == "deconnexion") {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "profil",
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("Profil"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "mot de passe",
                child: Row(
                  children: [
                    Icon(Icons.key, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("Mot de passe"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "a propos",
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("A propos"),
                  ],
                ),
              ),
              PopupMenuItem(
                value: "deconnexion",
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("Déconnexion"),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[400],
                child: profileImageBytes != null
                    ? ClipOval(
                  child: Image.memory(
                    profileImageBytes!,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                  ),
                )
                    : Icon(Icons.person, size: 50, color: Colors.white),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$prenom $nom",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  SizedBox(height: 5),
                  Text(
                    role,
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              )
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 600,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(50),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Color(0xFFE76702),
                  ],
                ),
              ),
              padding: EdgeInsets.only(top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      "Bienvenue, $nom",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 60),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 40,
                      padding: EdgeInsets.all(25),
                      children: List.generate(4, (index) {
                        List<String> labels = [
                          "Boutique",
                          "Calendrier",
                          "Historique",
                          "Scan QR"
                        ];
                        List<String> imagePaths = [
                          "images/shop.png",
                          "images/calendar.png",
                          "images/hitorique.jpeg",
                          "images/Qr.png",
                        ];

                        return GestureDetector(
                          onTap: () {
                            print("Tu as cliqué sur : ${labels[index]}");
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.orange, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  imagePaths[index],
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  labels[index],
                                  style:
                                  TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
