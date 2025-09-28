import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'entite/inscription_en_ligne_dto.dart';
import 'entite/inscription_service.dart';

class InscriptionPage extends StatelessWidget {
  const InscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CreatePage();
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreateInscriptionPage();
}

class _CreateInscriptionPage extends State<CreatePage> {
  int currentStep = 0;
  String? selectedValue;
  bool _motDePasseVisible = false;
  bool _isLoading = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final InscriptionService _inscriptionService = InscriptionService();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _date_de_naissanceController = TextEditingController(); // 🔥 CORRIGÉ le nom
  final _passwordController = TextEditingController();
  final _confirmerMotDePasseController = TextEditingController();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      _showError("Erreur lors de la sélection de l'image: $e");
    }
  }

  Future<void> _inscription() async {
    // 🔥 CORRECTION : Validation correcte des mots de passe
    if (_passwordController.text != _confirmerMotDePasseController.text) {
      _showError("Les mots de passe ne correspondent pas.");
      return;
    }

    if (selectedValue == null) {
      _showError("Veuillez sélectionner votre genre.");
      return;
    }

    // Validation des champs obligatoires
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _telephoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Veuillez remplir tous les champs obligatoires.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Créer le DTO
      final dto = InscriptionEnLigneDTO(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        adresse: _adresseController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        genre: selectedValue!,
        date_de_naissance: _date_de_naissanceController.text.trim(), // 🔥 CORRIGÉ
        password: _passwordController.text,
      );

      // 🔥 DEBUG : Afficher les données envoyées
      print("Données envoyées: ${dto.toJson()}");

      // Préparer l'image
      List<int>? imageBytes;
      String? nomFichier;

      if (_imageFile != null) {
        imageBytes = await _imageFile!.readAsBytes();
        nomFichier = _imageFile!.path.split('/').last;
        print("Image sélectionnée: $nomFichier (${imageBytes.length} bytes)");
      }

      // Appeler le service
      final response = await _inscriptionService.inscriptionEnLigne(
        dto,
        fichierBytes: imageBytes,
        nomFichier: nomFichier,
      );

      // 🔥 DEBUG : Afficher la réponse
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 201) {
        _showSuccess("Inscription effectuée avec succès. En attente de validation.");
        _resetForm();
        // Retour à la page précédente après un délai
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['message'] ??
            responseBody['error'] ??
            'Erreur lors de l\'inscription (${response.statusCode})';
        _showError(errorMessage);
      }
    } catch (e) {
      _showError("Erreur lors de l'inscription : $e");
      print("Erreur détaillée: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _nomController.clear();
    _prenomController.clear();
    _adresseController.clear();
    _emailController.clear();
    _telephoneController.clear();
    _date_de_naissanceController.clear(); // 🔥 CORRIGÉ
    _passwordController.clear();
    _confirmerMotDePasseController.clear();
    setState(() {
      selectedValue = null;
      _imageFile = null;
      currentStep = 0;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      // Formater la date au format YYYY-MM-DD attendu par le backend
      String formattedDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _date_de_naissanceController.text = formattedDate;
      });
    }
  }

  // Méthode pour masquer le mot de passe avec des étoiles
  String _masquerMotDePasse(String password) {
    return '*' * password.length;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _adresseController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _date_de_naissanceController.dispose(); // 🔥 CORRIGÉ
    _passwordController.dispose();
    _confirmerMotDePasseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 25),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Création de compte",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
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
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: Colors.black,
                    colorScheme: ColorScheme.light(
                      primary: Colors.orange[900]!,
                      onPrimary: Colors.white,
                      secondary: Colors.orange[900]!,
                    ),
                  ),
                  child: Stepper(
                    type: StepperType.horizontal,
                    steps: getSteps(),
                    currentStep: currentStep,
                    stepIconBuilder: (stepIndex, stepState) {
                      final isActive = currentStep == stepIndex;
                      final isCompleted = stepIndex < currentStep;

                      return Transform.scale(
                        scale: 1.5,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isActive || isCompleted)
                                ? Colors.orange[900]
                                : Colors.white,
                          ),
                          alignment: Alignment.center,
                          child: isCompleted
                              ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                              : Text(
                            '${stepIndex + 1}',
                            style: TextStyle(
                              fontSize: 16,
                              color: (isActive ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      );
                    },
                    onStepContinue: () {
                      final isLastStep = currentStep == getSteps().length - 1;
                      if (isLastStep) {
                        _inscription();
                      } else {
                        setState(() => currentStep += 1);
                      }
                    },
                    onStepTapped: (step) => setState(() => currentStep = step),
                    onStepCancel: () {
                      if (currentStep > 0) {
                        setState(() => currentStep -= 1);
                      }
                    },
                    controlsBuilder: (BuildContext context, ControlsDetails details) {
                      final isLastStep = currentStep == getSteps().length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[900],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _isLoading ? null : details.onStepContinue,
                              child: _isLoading
                                  ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                                  : Text(isLastStep ? "S'inscrire" : "Suivant"),
                            ),
                            if (currentStep > 0)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[800],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: details.onStepCancel,
                                child: const Text("Précédent"),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Step> getSteps() => [
    Step(
      isActive: currentStep >= 0,
      title: const Text(""),
      content: SizedBox(
        width: 300,
        child: Column(
          children: [
            SizedBox(height: 50),
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.person),
                label: Text("Nom", style: TextStyle(color: Colors.grey[700])),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _prenomController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.person),
                label: Text("Prénom", style: TextStyle(color: Colors.grey[700])),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _adresseController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.house),
                label: Text("Adresse", style: TextStyle(color: Colors.grey[700])),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.email),
                label: Text("Email", style: TextStyle(color: Colors.grey[700])),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    ),
    Step(
      isActive: currentStep >= 1,
      title: Text(""),
      content: SizedBox(
        width: 300,
        child: Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(75),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: _imageFile != null
                    ? ClipOval(
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 50, color: Colors.grey[700]),
                    SizedBox(height: 10),
                    Text("Ajouter une photo", style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Radio<String>(
                  value: 'HOMME',
                  groupValue: selectedValue,
                  activeColor: Colors.orange[900],
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                        ? Colors.orange[900]!
                        : Colors.white,
                  ),
                  onChanged: (value) => setState(() => selectedValue = value),
                ),
                Text("HOMME", style: TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              children: [
                Radio<String>(
                  value: 'FEMME',
                  groupValue: selectedValue,
                  activeColor: Colors.orange[900],
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => states.contains(WidgetState.selected)
                        ? Colors.orange[900]!
                        : Colors.white,
                  ),
                  onChanged: (value) => setState(() => selectedValue = value),
                ),
                Text("FEMME", style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _date_de_naissanceController, // 🔥 CORRIGÉ
              readOnly: true, // 🔥 Empêche la saisie manuelle
              onTap: _selectDate, // 🔥 Ouvre le sélecteur de date
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.calendar_month),
                label: Text("Date de naissance (YYYY-MM-DD)",
                    style: TextStyle(color: Colors.grey[700])),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    ),
    Step(
      isActive: currentStep >= 2,
      title: Text(""),
      content: SizedBox(
        width: 300,
        child: Column(
          children: [
            SizedBox(height: 50),
            TextField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.phone),
                label: Text("Téléphone", style: TextStyle(color: Colors.grey[700])),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _passwordController,
              obscureText: !_motDePasseVisible,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.key),
                label: Text("Mot de passe", style: TextStyle(color: Colors.grey[700])),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _motDePasseVisible ? Icons.visibility : Icons.visibility_off,
                    color: _motDePasseVisible ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
                ),
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _confirmerMotDePasseController,
              obscureText: !_motDePasseVisible,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.key),
                label: Text("Confirmer le mot de passe",
                    style: TextStyle(color: Colors.grey[700])),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.orange,
                    width: 2.0,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _motDePasseVisible ? Icons.visibility : Icons.visibility_off,
                    color: _motDePasseVisible ? Colors.orange : Colors.grey,
                  ),
                  onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    ),

    // Étape 4: Récapitulatif
    Step(
      isActive: currentStep >= 3,
      title: Text(""),
      content: SizedBox(
        width: 300,
        child: Column(
          children: [
            //SizedBox(height: 30),
            Text(
              "Vérifiez vos informations",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),

            // Carte de récapitulatif
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo si disponible
                  if (_imageFile != null) ...[
                    Center(
                      child: ClipOval(
                        child: Image.file(
                          _imageFile!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],

                  // Informations personnelles
                  _buildLigneRecap("Nom", _nomController.text),
                  _buildLigneRecap("Prénom", _prenomController.text),
                  _buildLigneRecap("Adresse", _adresseController.text.isNotEmpty ? _adresseController.text : "Non renseignée"),
                  _buildLigneRecap("Email", _emailController.text.isNotEmpty ? _emailController.text : "Non renseigné"),
                  _buildLigneRecap("Téléphone", _telephoneController.text),
                  _buildLigneRecap("Genre", selectedValue ?? "Non sélectionné"),
                  _buildLigneRecap("Date de naissance", _date_de_naissanceController.text.isNotEmpty ? _date_de_naissanceController.text : "Non renseignée"),

                  // Mot de passe masqué
                  _buildLigneRecap("Mot de passe", _masquerMotDePasse(_passwordController.text)),

                  SizedBox(height: 20),
                  Divider(color: Colors.orange),
                  SizedBox(height: 10),

                  // Message de confirmation
                  Text(
                    "Si toutes les informations sont correctes, cliquez sur 'S'inscrire'",
                    style: TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    ),
  ];

  // Widget pour afficher une ligne du récapitulatif
  Widget _buildLigneRecap(String label, String valeur) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label :",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              valeur,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}