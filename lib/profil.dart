import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Profil();
  }
}

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _CreateProfilPage();
}

class _CreateProfilPage extends State<Profil> {
  Uint8List? profileImageBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // Attendre un court délai pour s'assurer que le contexte est disponible
    await Future.delayed(Duration.zero);
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final profilBase64 = stockageToken.userData?["profil"] ?? "";

    if (profilBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(profilBase64);
        if (mounted) {
          setState(() {
            profileImageBytes = bytes;
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Erreur décodage image dans Profil : $e");
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 🔥 MÉTHODE POUR FORMater LA DATE
  String _formatDate(String dateString, {bool includeTime = false}) {
    if (dateString.isEmpty) return "Non spécifiée";
    try {
      final date = DateTime.parse(dateString);
      if (includeTime) {
        return DateFormat('dd/MM/yyyy HH:mm').format(date);
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  // 🔥 MÉTHODE POUR TRADUIRE LE GENRE
  String _getGenreLabel(String genre) {
    switch (genre) {
      case 'HOMME': return 'Homme';
      case 'FEMME': return 'Femme';
      default: return genre;
    }
  }

  // 🔥 MÉTHODE POUR TRADUIRE LE RÔLE
  String _getRoleLabel(String role) {
    switch (role) {
      case 'MEMBRE': return 'Membre';
      case 'ADMIN': return 'Administrateur';
      case 'STAFF': return 'Staff';
      case 'PROPRIETAIRE': return 'Propriétaire';
      default: return role;
    }
  }

  //  Method pour afficher la photo en grand
  void _afficherPhoto(BuildContext context){
    showDialog(
        context: context,
        builder: (_) =>Dialog(
          backgroundColor: Colors.black,
          child: InteractiveViewer(
              child: Image.memory(
                profileImageBytes!,
                fit: BoxFit.contain,
              ),
          ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stockageToken = Provider.of<StockageDeToken>(context);
    final userData = stockageToken.userData ?? {};

    // Récupération des données depuis le StockageDeToken
    String nom = userData["nom"] ?? "";
    String prenom = userData["prenom"] ?? "";
    String email = userData["email"] ?? "";
    String adresse = userData["adresse"] ?? "";
    String telephone = userData["telephone"] ?? "";
    String genre = _getGenreLabel(userData["genre"] ?? "");
    String role = _getRoleLabel(userData["role"] ?? "");
    String dateDeNaissanceRaw = userData["date_de_naissance"] ?? "";
    String dateCreationRaw = userData["date_creation"] ?? "";

    String dateDeNaissance = _formatDate(dateDeNaissanceRaw);
    String dateCreation = _formatDate(dateCreationRaw, includeTime: true);

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
            Text(
              "Mon Profil",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
          : Stack(
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
              child: SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: SizedBox(
                      height: 720,
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
                              // 🔥 SECTION PHOTO DE PROFIL
                              Center(
                                child: Column(
                                  children: [
                                    Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _afficherPhoto(context),
                                          child: CircleAvatar(
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
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[900],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    // 🔥 NOM ET RÔLE
                                    Column(
                                      children: [
                                        Text(
                                          "$prenom $nom",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          role,
                                          style: TextStyle(
                                            color: Colors.orange[900],
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),

                              // 🔥 INFORMATIONS PERSONNELLES
                              _buildInfoRow(
                                icon: Icons.location_on,
                                label: "Adresse",
                                value: adresse.isNotEmpty ? adresse : "Non renseignée",
                              ),
                              _buildInfoRow(
                                icon: Icons.email,
                                label: "Email",
                                value: email.isNotEmpty ? email : "Non renseigné",
                              ),
                              _buildInfoRow(
                                icon: Icons.cake,
                                label: "Date de naissance",
                                value: dateDeNaissance,
                              ),
                              _buildInfoRow(
                                icon: Icons.phone,
                                label: "Téléphone",
                                value: telephone.isNotEmpty ? telephone : "Non renseigné",
                              ),
                              _buildInfoRow(
                                icon: Icons.person_outline,
                                label: "Genre",
                                value: genre.isNotEmpty ? genre : "Non spécifié",
                              ),
                              _buildInfoRow(
                                icon: Icons.calendar_today,
                                label: "Date de création",
                                value: dateCreation,
                              ),

                              const SizedBox(height: 40),

                              // 🔥 BOUTON MODIFIER LE PROFIL
                              // Center(
                              //   child: ElevatedButton(
                              //     onPressed: () {
                              //       // TODO: Implémenter la modification du profil
                              //       ScaffoldMessenger.of(context).showSnackBar(
                              //         SnackBar(
                              //           content: Text('Fonctionnalité à venir'),
                              //           backgroundColor: Colors.orange[900],
                              //         ),
                              //       );
                              //     },
                              //     style: ElevatedButton.styleFrom(
                              //       backgroundColor: Colors.orange[900],
                              //       foregroundColor: Colors.white,
                              //       padding: const EdgeInsets.symmetric(
                              //         horizontal: 30,
                              //         vertical: 12,
                              //       ),
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(20),
                              //       ),
                              //     ),
                              //     child: const Text(
                              //       "Modifier le profil",
                              //       style: TextStyle(
                              //         fontSize: 16,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
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

  // 🔥 WIDGET RÉUTILISABLE PURE LES INFORMATIONS
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.orange[900],
            size: 22,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}