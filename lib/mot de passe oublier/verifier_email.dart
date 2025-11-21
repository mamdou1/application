import 'package:flutter/material.dart';
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifierEmailPage extends StatelessWidget {
  const VerifierEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const VerifierEmail();
  }
}

class VerifierEmail extends StatefulWidget {
  const VerifierEmail({super.key});

  @override
  State<VerifierEmail> createState() => _CreateVerifierEmailPage();
}

class _CreateVerifierEmailPage extends State<VerifierEmail> {
  bool _isLoading = false;
  final _emailController = TextEditingController();

  Future<void> _envoyerCodeVerification() async {
    if (_emailController.text.isEmpty) {
      _showError('Veuillez saisir votre email');
      return;
    }

    // Validation basique de l'email
    if (!_emailController.text.contains('@')) {
      _showError('Veuillez saisir un email valide');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('🔄 Envoi de la requête pour: ${_emailController.text}');

      // ✅ CORRECTION : Utiliser uniquement les query parameters comme Postman
      final url = Uri.parse(ApiEndpoints.motDePasseOublier).replace(
          queryParameters: {'email': _emailController.text}
      );

      print('📡 URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        // ✅ CORRECTION : Pas de body, seulement query params
      );

      print('📨 Réponse reçue - Status: ${response.statusCode}');
      print('📨 Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? data['message:'] ?? 'Code de vérification envoyé avec succès';

        _showSuccess(message);

        // Naviguer vers la page de vérification du code
        Navigator.pushNamed(
            context,
            '/code-verification',
            arguments: {
              'email': _emailController.text,
              'token': data['token'] ?? data['token:'], // Gérer les deux formats de clé
            }
        );
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['error'] ?? data['error:'] ?? 'Erreur lors de l\'envoi du code';
        _showError(errorMessage);
      }
    } catch (e) {
      print('❌ Erreur: $e');
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
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
              "Mot de passe oublié",
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
              height: 500,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SizedBox(
                  height: 480,
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
                          const SizedBox(height: 40),
                          // Texte d'information
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Saisissez votre adresse email pour recevoir un code de réinitialisation",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Champ email
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
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
                                prefixIcon: Icon(Icons.email, color: Colors.orange[900]),
                                label: Text(
                                  "Adresse email",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                                hintText: "exemple@email.com",
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          // Bouton d'envoi
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 25.0),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: _isLoading
                                  ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
                                  : ElevatedButton(
                                onPressed: _envoyerCodeVerification,
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
                                  "Envoyer le code",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Lien pour retourner à la connexion
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Retour à la connexion",
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