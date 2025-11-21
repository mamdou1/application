import 'package:flutter/material.dart';
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MotDePasseOublierPage extends StatelessWidget {
  final String email;
  final String? token;
  final String codeVerification;

  const MotDePasseOublierPage({
    super.key,
    required this.email,
    this.token,
    required this.codeVerification,
  });

  @override
  Widget build(BuildContext context) {
    return MotDePasseOublier(
      email: email,
      token: token,
      codeVerification: codeVerification,
    );
  }
}

class MotDePasseOublier extends StatefulWidget {
  final String email;
  final String? token;
  final String codeVerification;

  const MotDePasseOublier({
    super.key,
    required this.email,
    this.token,
    required this.codeVerification,
  });

  @override
  State<MotDePasseOublier> createState() => _CreateMotDePasseOublierPage();
}

class _CreateMotDePasseOublierPage extends State<MotDePasseOublier> {
  bool _isLoading = false;
  bool _motDePasseVisible = false;
  final _nouveauMotDePasseController = TextEditingController();
  final _confirmerMotDePasseController = TextEditingController();

  Future<void> _reinitialiserMotDePasse() async {
    if (_nouveauMotDePasseController.text.isEmpty ||
        _confirmerMotDePasseController.text.isEmpty) {
      _showError('Veuillez remplir tous les champs');
      return;
    }

    if (_nouveauMotDePasseController.text != _confirmerMotDePasseController.text) {
      _showError('Les mots de passe ne correspondent pas');
      return;
    }

    if (_nouveauMotDePasseController.text.length < 6) {
      _showError('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.modifierMotDePasse),
        headers: {
          'Content-Type': 'application/json',
          if (widget.token != null) 'Authorization': 'Bearer ${widget.token}',
        },
        body: jsonEncode({
          'password': _nouveauMotDePasseController.text,
          'verificationCode': widget.codeVerification,
          'email': widget.email,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _showSuccess(data['message'] ?? 'Mot de passe réinitialisé avec succès');

        // Redirection immédiate avec feedback
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/connexion',
              (route) => false,
        );
      } else {
        final data = jsonDecode(response.body);
        _showError(data['error'] ?? 'Erreur lors de la réinitialisation');
      }
    } catch (e) {
      _showError('Erreur de connexion : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.orange[900], size: 25),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            const Text(
              "Nouveau mot de passe",
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
                          const SizedBox(height: 30),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Créez votre nouveau mot de passe",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            height: 60,
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
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange[900]!,
                                    width: 2.5,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.lock, color: Colors.orange[900]),
                                labelText: "Nouveau mot de passe",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _motDePasseVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _motDePasseVisible
                                        ? Colors.orange[900]
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
                          const SizedBox(height: 30),
                          SizedBox(
                            height: 60,
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
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.orange[900]!,
                                    width: 2.5,
                                  ),
                                ),
                                prefixIcon: Icon(Icons.lock_outline, color: Colors.orange[900]),
                                labelText: "Confirmer le mot de passe",
                                labelStyle: TextStyle(color: Colors.grey[700]),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _motDePasseVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: _motDePasseVisible
                                        ? Colors.orange[900]
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
                                  ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
                                  : ElevatedButton(
                                onPressed: _reinitialiserMotDePasse,
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
                                  "Réinitialiser",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
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