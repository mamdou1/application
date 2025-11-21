import 'package:flutter/material.dart';
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CodeVerificationPage extends StatelessWidget {
  final String email;
  final String? token;

  const CodeVerificationPage({super.key, required this.email, this.token});

  @override
  Widget build(BuildContext context) {
    return CodeVerification(email: email, token: token);
  }
}

class CodeVerification extends StatefulWidget {
  final String email;
  final String? token;

  const CodeVerification({super.key, required this.email, this.token});

  @override
  State<CodeVerification> createState() => _CreateCodeVerificationPage();
}

class _CreateCodeVerificationPage extends State<CodeVerification> {
  bool _isLoading = false;
  final _codeController = TextEditingController();

  Future<void> _verifierCode() async {
    if (_codeController.text.isEmpty) {
      _showError('Veuillez saisir le code de vérification');
      return;
    }

    if (_codeController.text.length != 6) {
      _showError('Le code doit contenir 6 caractères');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Note: Vous devrez peut-être adapter cet endpoint selon votre backend
      final response = await http.post(
        Uri.parse(ApiEndpoints.verifierReinitialiser),
        headers: {
          'Content-Type': 'application/json',
          if (widget.token != null) 'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'verificationCode': _codeController.text,
          // Ajouter d'autres champs si nécessaire selon votre DTO
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSuccess(data['message'] ?? 'Code vérifié avec succès');

        // Naviguer vers la page de nouveau mot de passe
        Navigator.pushNamed(
            context,
            '/nouveau-mot-de-passe',
            arguments: {
              'email': widget.email,
              'token': widget.token,
              'codeVerification': _codeController.text,
            }
        );
      } else {
        final data = jsonDecode(response.body);
        _showError(data['error'] ?? 'Code de vérification invalide');
      }
    } catch (e) {
      _showError('Erreur de connexion : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _renvoyerCode() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.renvoyerCode),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccess('Nouveau code envoyé à votre email');
      } else {
        final data = jsonDecode(response.body);
        _showError(data['error'] ?? 'Erreur lors de l\'envoi du code');
      }
    } catch (e) {
      _showError('Erreur de connexion : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

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
            const Text(
              "Vérification du code",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SizedBox(
                  height: 430,
                  width: 340,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.grey[300],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),
                          // Texte d'information
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                const Text(
                                  "Entrez le code de vérification",
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Envoyé à ${widget.email}",
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "Le code est composé de 6 caractères (chiffres et lettres)",
                                  style: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Champ code de vérification
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: TextField(
                              controller: _codeController,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 6,
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
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange[900]!,
                                    width: 2.5,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.verified_user, color: Colors.orange[900]),
                                label: Text(
                                  "Code de vérification",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                hintText: "ABCD12",
                                counterText: "",
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          // Bouton de vérification
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: _isLoading
                                  ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
                                  : ElevatedButton(
                                onPressed: _verifierCode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[900],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(color: Colors.white),
                                  ),
                                ),
                                child: const Text(
                                  "Vérifier le code",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Lien pour renvoyer le code
                          Center(
                            child: TextButton(
                              onPressed: _isLoading ? null : _renvoyerCode,
                              child: Text(
                                "Renvoyer le code",
                                style: TextStyle(
                                  color: Colors.orange[900],
                                  fontSize: 16,
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

