import 'package:flutter/material.dart';

class ChangerPasswordPage extends StatelessWidget {
  const ChangerPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangerPassword();
  }
}

class ChangerPassword extends StatefulWidget {
  const ChangerPassword({super.key});

  @override
  State<ChangerPassword> createState() => _CreateChangerPasswordPage();
}

class _CreateChangerPasswordPage extends State<ChangerPassword> {
  bool _motDePasseVisible = false;

  @override
  Widget build(BuildContext context) {
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
                          SizedBox(height: 60),

                          SizedBox(
                            height: 50,
                            width: double.infinity, // S'adapter à la largeur de la Card
                            child: TextField(
                              obscureText: !_motDePasseVisible,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange[900]!,
                                    width: 2.0,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.key),
                                label: Text(
                                  "Anciens mot de passe",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _motDePasseVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _motDePasseVisible
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _motDePasseVisible = !_motDePasseVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 50),
                          SizedBox(
                            height: 50,
                            width: double.infinity, // S'adapter à la largeur de la Card
                            child: TextField(
                              obscureText: !_motDePasseVisible,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange[900]!,
                                    width: 2.0,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.key),
                                label: Text(
                                  "Mot de passe",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _motDePasseVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _motDePasseVisible
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _motDePasseVisible = !_motDePasseVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 50),

                          SizedBox(
                            height: 50,
                            width: double.infinity, // S'adapter à la largeur de la Card
                            child: TextField(
                              obscureText: !_motDePasseVisible,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange[900]!,
                                    width: 2.0,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.key),
                                label: Text(
                                  "Confirmer le mot de passe",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _motDePasseVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _motDePasseVisible
                                        ? Colors.orange
                                        : Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _motDePasseVisible = !_motDePasseVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 50),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity, // S'adapter à la largeur de la Card
                              child: ElevatedButton(
                                onPressed: () {
                                  print("Bouton Se connecter cliqué !");
                                  Navigator.pushNamed(context, '/inscription');
                                },
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
                                  "Valider",
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
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


