import 'package:flutter/material.dart';
import 'connexion.dart';
import 'inscription.dart';
import 'evennement.dart';
import 'acceuille.dart';
import 'a_propos.dart';
import 'changer_password.dart';
import 'detaille_gym.dart';
import 'historique.dart';
import 'liste_gym.dart';
import 'scan_qr.dart';
import 'soumettre_demande.dart';
import 'profil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/connexion',
      routes: {
        '/connexion': (context) => ConnexionPage(),
        '/inscription': (context) => InscriptionPage(),
        '/evennement':(context)=> EventPage(),
        '/acceuille':(context)=> AcceuillePage(),
        '/a_propos': (context) => AProposPage(),
        '/changer_password': (context) => ChangerPasswordPage(),
        '/detaille_gym':(context)=> DetailleGymPage(),
        '/historique':(context)=> HistoriquePage(),
        '/liste_gym': (context) => ListeGymPage(),
        '/scan_qr': (context) => ScanQrPage(),
        '/soumettre_demande':(context)=> SoumettreDemandePage(),
        '/profil': (context) => ProfilPage(),
      },
    );
  }
}
