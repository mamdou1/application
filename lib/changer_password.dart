import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'StockageDeToken.dart';
import 'utils/api_endpoints.dart';


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
  bool _isLoading = false; // Indicateur de chargement

  // URL du backend
  static const String baseUrl = 'http://10.0.2.2:8080'; // Pour émulateur Android 192.168.137.1
  static const String baseUrls = 'http://192.168.137.1:8080';

  // Contrôleurs pour les champs de texte
  final _ancienMotDePasseController = TextEditingController();
  final _nouveauMotDePasseController = TextEditingController();
  final _confirmerMotDePasseController = TextEditingController();


  Future<void> _changePassword() async {
    if (_nouveauMotDePasseController.text != _confirmerMotDePasseController.text) {
      _showError('Les nouveaux mots de passe ne correspondent pas.');
      return;
    }

    // 🔥 RÉCUPÉRER LE TOKEN DEPUIS LE STOCKAGE GLOBAL
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.changerMotDePasse),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 🔥 Utiliser le token
        },
        body: jsonEncode({
          'ancienMotDePasse': _ancienMotDePasseController.text,
          'nouveauMotDePasse': _nouveauMotDePasseController.text,
          'confirmerMotDePasse': _confirmerMotDePasseController.text,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccess('Mot de passe changé avec succès!');
        // Optionnel : Rediriger vers une autre page ou vider les champs
        _ancienMotDePasseController.clear();
        _nouveauMotDePasseController.clear();
        _confirmerMotDePasseController.clear();
      } else {
        final data = jsonDecode(response.body);
        _showError(data['message'] ?? 'Erreur lors du changement de mot de passe.');
      }
    } catch (e) {
      _showError('Erreur de connexion : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: Colors.green))),
    );
  }

  @override
  void dispose() {
    _ancienMotDePasseController.dispose();
    _nouveauMotDePasseController.dispose();
    _confirmerMotDePasseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false, // Active le bouton de retour par défaut
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.orange[900], size: 25),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 10), // Ajustement pour aligner le titre
            Text(
              "Changer le mot de passe",
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
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 650,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
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
                          const SizedBox(height: 60),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: TextField(
                              controller: _ancienMotDePasseController,
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
                                  "Ancien mot de passe",
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
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: TextField(
                              controller: _nouveauMotDePasseController,
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
                                  "Nouveau mot de passe",
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
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: TextField(
                              controller: _confirmerMotDePasseController,
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
                              width: double.infinity,
                              child: _isLoading
                                  ? CircularProgressIndicator(color: Colors.white)
                                  : ElevatedButton(
                                onPressed: _changePassword,
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

