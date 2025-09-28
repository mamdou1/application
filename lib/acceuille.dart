import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';

class AcceuillePage extends StatelessWidget {
  const AcceuillePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Acceuille();
  }
}

class Acceuille extends StatefulWidget {
  const Acceuille({super.key});

  @override
  State<Acceuille> createState() => _CreateAcceuillePage();
}

class _CreateAcceuillePage extends State<Acceuille> {
  Uint8List? profileImageBytes;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final profilBase64 = stockageToken.userData?["profil"] ?? "";
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

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Déconnexion réussie.")),
    );
    Provider.of<StockageDeToken>(context, listen: false).effacerToken();
    Navigator.pushNamedAndRemoveUntil(context, "/connexion", (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final stockageToken = Provider.of<StockageDeToken>(context);
    final userData = stockageToken.userData ?? {};
    final String nom = userData["nom"] ?? "";
    final String prenom = userData["prenom"] ?? "";
    final String role = userData["role"] ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white, size: 25),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 25),
            onSelected: (value) {
              if (value == "profil") {
                Navigator.pushNamed(
                  context,
                  "/profil",
                  arguments: userData,
                );
              } else if (value == "mot de passe") {
                Navigator.pushNamed(
                  context,
                  "/changer_password",
                  arguments: {
                    'token': stockageToken.token,
                  },
                );
              } else if (value == "a propos") {
                Navigator.pushNamed(context, "/a_propos");
              } else if (value == "deconnexion") {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: "profil",
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("Profil"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "mot de passe",
                child: Row(
                  children: [
                    Icon(Icons.key, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("Mot de passe"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "a propos",
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 10),
                    Text("A propos"),
                  ],
                ),
              ),
              const PopupMenuItem(
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[400],
                  child: profileImageBytes != null
                      ? ClipOval(
                    child: Image.memory(
                      profileImageBytes!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    ),
                  )
                      : const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$prenom $nom",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    //const SizedBox(height: 5),
                    Text(
                      role,
                      style: const TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ],
                )
              ],
            ),
          ),
            const Spacer(),
            Container(
              height: 600,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(50),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Color(0xFFE76702),
                  ],
                ),
              ),
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      "Bienvenue, $nom",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 40,
                      padding: const EdgeInsets.all(25),
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
                                const SizedBox(height: 10),
                                Text(
                                  labels[index],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
        ],
      ),
    );
  }
}
