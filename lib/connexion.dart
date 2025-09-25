import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestion_salle_de_sport/user.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ConnexionPage extends StatelessWidget {
  const ConnexionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyHomePage();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _motDePasseVisible = false;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // État de chargement

  // Contrôleurs pour les champs
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // URL du backend
  static const String baseUrl = 'http://10.0.2.2:8080'; // Pour émulateur Android 192.168.137.1
  static const String baseUrls = 'http://192.168.137.1:8080';

  Future<http.Response> _save() async {
    final user = User(_telephoneController.text, _passwordController.text);
    return await http.post(
      Uri.parse('$baseUrl/api/auth/connexion'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
  }

  Future<Map<String, dynamic>> getUserProfil(int id, String token) async{
    final url = Uri.parse('$baseUrl/api/users/profil/$id');
    final response = await http.get(
        url,
      headers: {
          'Content-Type':'application/json',
        'Authorization':'Bearer $token', // Important
      },
    );
    if(response.statusCode == 200){
      return jsonDecode(response.body);
    }else{
      throw Exception('Errerur profil: ${response.statusCode}');
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Démarre le chargement
      try {
        final response = await _save();
        final data = jsonDecode(response.body);

        if (response.statusCode == 200 ) { //&& data['message'] == 'Connexion réussie'
          final String token = data['token'];
          if (token.isNotEmpty) {

            // ✅ Décoder le token pour récupérer l'id
            Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
            print("Profil data: $data"); // Vérifiez la présence des dates

            int id = decodedToken['id']; // ✅

            // 🔥 Récupération du profil complet depuis l’API
            final userProfile = await getUserProfil(id, token);

            // Naviguer vers l'accueil avec les données
            Navigator.pushReplacementNamed(
              context,
              '/acceuille',
              arguments: {
                'id': id,
                'token': token,
                'nom': userProfile['nom'] ?? '',
                'prenom': userProfile['prenom'] ?? '',
                'email': userProfile['email'] ?? '',
                'adresse': userProfile['adresse'] ?? '',
                'telephone': userProfile['telephone'] ?? '',
                'genre': userProfile['genre'] ?? '',
                'role': userProfile['role'] ?? '',
                'date_creation': userProfile['date_creation'] ?? '',
                'date_de_naissance': userProfile['date_de_naissance'] ?? '',
                'profil': userProfile['profil'] ?? '', // ⚡ Ajout base64
              },
            );
          } else {
            _showError('Aucun token reçu du serveur');
          }
        } else {
          _showError(data['message'] ?? 'Erreur de connexion');
        }
      } catch (e) {
        _showError('Erreur : $e');
      } finally {
        setState(() => _isLoading = false); // Arrête le chargement
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.black,
              Colors.orange.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 100),
                    const Image(
                      image: AssetImage('images/logo avec arriere plan supprimer.png'),
                      width: 300,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 170),
                    SizedBox(
                      height: 50,
                      width: 330,
                      child: TextFormField(
                        controller: _telephoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre téléphone';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: const Icon(Icons.phone),
                          label: const Text("Téléphone", style: TextStyle(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.orange,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      height: 50,
                      width: 330,
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_motDePasseVisible,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre mot de passe';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.orange,
                              width: 2.0,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.key),
                          label: const Text("Mot de passe", style: TextStyle(color: Colors.grey)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _motDePasseVisible ? Icons.visibility : Icons.visibility_off,
                              color: _motDePasseVisible ? Colors.orange : Colors.grey,
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
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: SizedBox(
                        height: 50,
                        width: 330,
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : ElevatedButton(
                          onPressed: _login,
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
                            "Se connecter",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                    const SizedBox(height: 30),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/inscription");
                      },
                      child: const Text(
                        "Créer un compte",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
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
    );
  }
}