import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'StockageDeToken.dart';
import 'liste_gym/choix_gym.dart';
import 'liste_gym/ma_gym.dart';
import 'profil.dart';

class ListeGymPage extends StatelessWidget {
  const ListeGymPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return ListeGym();
  }
}

class ListeGym extends StatefulWidget {
  const ListeGym({super.key});


  @override
  State<ListeGym> createState()=> _CreateListeGymPage();
}

class _CreateListeGymPage extends State<ListeGym> {
  int pagesIndex = 1; // Commence par "Ma gym" par défaut
  late List<Widget> pages; // 🔥 Déclarer comme late pour l'initialiser dans initState

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  // 🔥 MÉTHODE POUR INITIALISER LES PAGES AVEC LES DONNÉES
  void _initializePages() {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final userData = stockageToken.userData;

    pages = [
      // Page ChoixGym avec données utilisateur
      ChoixGymPage(),

      // Page MaGym avec données utilisateur
      MaGymPage(userData: userData),

      // Page Profil avec données utilisateur
      // ProfilPage(userData: userData),
      ProfilPage(),
    ];
  }

  @override
  Widget build( context) {
    return Scaffold(
      body: pages[pagesIndex],
      backgroundColor: Colors.black,
      bottomNavigationBar: NavigationBar(
        selectedIndex: pagesIndex, // 🔥 indique l’onglet actif
        onDestinationSelected: (int index){
          setState(() {
            pagesIndex = index; // 🔁 met à jour la page affichée
          });
        },
        backgroundColor: Colors.grey[900],
          destinations: [
            NavigationDestination(
                icon: Icon(Icons.home_work_outlined, color: Colors.orange[900]),
                label: "Liste des gym",
            ),
            NavigationDestination(
              icon: Icon(Icons.fitness_center, color: Colors.orange[900]),
              label: "Ma gym",
            ),
            NavigationDestination(
              icon: Icon(Icons.person, color: Colors.orange[900]),
              label: "Profil",
            ),
          ]),
    );
  }
}

