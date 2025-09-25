import 'package:flutter/material.dart';

class InscriptionPage extends StatelessWidget {
  const InscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return CreatePage();
  }
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});


  @override
  State<CreatePage> createState()=> _CreateInscriptionPage();
}

class _CreateInscriptionPage extends State<CreatePage> {
  int currentStep = 0;
  String? selectedValue; // ✅ valeur choisie (null au début)
  bool _motDePasseVisible = false;

  @override
  Widget build( context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 25),
            onPressed: () {
              Navigator.pop(context);
            },
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
                const SizedBox(height: 80),

                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Colors.black,
                      colorScheme: ColorScheme.light(
                        primary: Colors.orange[900]!, // ✅ Couleur des cercles/lignes actifs
                        onPrimary: Colors.white, // ✅ Couleur du texte dans les cercles
                        secondary: Colors.orange[900]!,// ✅ couleur de la ligne quand le step est complété
                      ),
                    ),

                  child: Stepper(
                    type: StepperType.horizontal,
                    steps: getSteps(),
                    currentStep: currentStep,

                    stepIconBuilder: (stepIndex, stepState) {
                      final isActive = currentStep == stepIndex;   // étape en cours
                      final isCompleted = stepIndex < currentStep; // ✅ étape déjà terminée

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
                            Icons.check,               // ✅ icône check si terminé
                            color: Colors.white,
                            size: 20,
                          )
                              : Text(
                            '${stepIndex + 1}',        // sinon le numéro
                            style: TextStyle(
                              fontSize: 16,
                              color: (isActive ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                      );
                    },


                    // ✅ Gestion du bouton "Suivant"
                    onStepContinue: () {
                      final isLastStep = currentStep == getSteps().length - 1;
                      if (isLastStep) {
                        print("✅ Inscription terminée");
                      } else {
                        setState(() => currentStep += 1);
                      }
                    },

                    onStepTapped: (step)=> currentStep = step,

                    // ✅ Gestion du bouton "Précédent"
                    onStepCancel: () {
                      if (currentStep > 0) {
                        setState(() => currentStep -= 1);
                      }
                    },

                    /// ✅ Personnalisation des boutons
                    controlsBuilder: (BuildContext context,
                        ControlsDetails details) {
                      final isLastStep = currentStep == getSteps().length - 1;
                      return Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ➡️ Bouton Suivant ou Terminer
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
                              onPressed: details.onStepContinue,
                              child: Text(isLastStep ? "Terminer" : "Suivant"),
                            ),

                            // 🔙 Bouton Précédent
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
      )
    );
  }
  List<Step> getSteps()=> [
    Step(
      //state: currentStep > 0 ? StepState.complete : StepState.indexed,
      isActive: currentStep >= 0,
      title: const Text(""),
      content:  SizedBox(
        width: 300,
        child: Column(
          children: [
            SizedBox(height: 50),
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.person),
                    label: Text(
                      "Nom", style: TextStyle(color: Colors.grey[700]),),
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
            //SizedBox(height: 50),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.person),
                label: Text(
                  "Prénom", style: TextStyle(color: Colors.grey[700]),),
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
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.house),
                label: Text(
                  "Adresse", style: TextStyle(color: Colors.grey[700]),),
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
            //SizedBox(height: 50),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.email),
                label: Text(
                  "Email", style: TextStyle(color: Colors.grey[700]),),
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
      //state: currentStep > 1 ? StepState.complete : StepState.indexed,
      isActive: currentStep>=1,
      title: Text(""),
      content: SizedBox(
        width: 300,
        child: Column(
          children: [

            const SizedBox(height: 30),
            const Image(
              image: AssetImage(
                  'images/camera.png'),
              width: 150,
              height: 150,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 30),
            // 🔘 Radio 1
            Row(
              children: [
                Radio<String>(
                  value: 'HOMME',                 // valeur unique
                  groupValue: selectedValue,      // groupe
                  activeColor: Colors.orange[900],// couleur sélection
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.orange[900]!; // quand coché
                      }
                      return Colors.white; // ✅ couleur par défaut (non coché)
                    },
                  ),
                  onChanged: (value) {
                    setState(() => selectedValue = value);
                  },
                ),
                Text("HOMME", style: TextStyle(color: Colors.white)),
              ],
            ),

            // 🔘 Radio 2
            Row(
              children: [
                Radio<String>(
                  value: 'FEMME',                 // autre valeur unique
                  groupValue: selectedValue,      // même groupe
                  activeColor: Colors.orange[900],
                  fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.orange[900]!; // quand coché
                      }
                      return Colors.white; // ✅ couleur par défaut (non coché)
                    },
                  ),
                  onChanged: (value) {
                    setState(() => selectedValue = value);
                  },
                ),
                Text("FEMME", style: TextStyle(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 30),

            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.calendar_month),
                label: Text("Date de naissance", style: TextStyle(color: Colors.grey[700]),),
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
      //state: currentStep > 2 ? StepState.complete : StepState.indexed,
      isActive: currentStep >=2,
      title: Text(""),
      content: SizedBox(
        width: 300,
        child: Column(
          children: [
            SizedBox(height: 50),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.phone),
                label: Text("Téléphon", style: TextStyle(color: Colors.grey[700]),),
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
            //SizedBox(height: 50),
            SizedBox(
              height: 50,
              width: 380,
              child: TextField(
                obscureText: !_motDePasseVisible, // 👈 cache ou affiche le texte
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
                  prefixIcon: Icon(Icons.key),
                  label: Text(
                    "Mot de passe",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _motDePasseVisible ? Icons.visibility : Icons.visibility_off,
                      color: _motDePasseVisible ? Colors.orange : Colors.grey, // 👈 couleur dynamique
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
            SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: 380,
              child: TextField(
                obscureText: !_motDePasseVisible, // 👈 cache ou affiche le texte
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
                  prefixIcon: Icon(Icons.key),
                  label: Text(
                    "Confirmer le mot de passe",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _motDePasseVisible ? Icons.visibility : Icons.visibility_off,
                      color: _motDePasseVisible ? Colors.orange : Colors.grey, // 👈 couleur dynamique
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
            SizedBox(height: 30),
            //SizedBox(height: 50),
          ],

        ),
      ),

    ),
  ];
}

