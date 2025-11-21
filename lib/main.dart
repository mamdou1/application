import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'connexion.dart';
import 'inscription.dart';
import 'evennement.dart';
import 'acceuille.dart';
import 'a_propos.dart';
import 'changer_password.dart';
import 'historique.dart';
import 'liste_gym.dart';
import 'scan_qr.dart';
import 'soumettre_demande.dart';
import 'profil.dart';
import 'details_gym.dart';
import 'StockageDeToken.dart';
import 'liste_gym/choix_gym.dart';
import 'liste_gym/ma_gym.dart';
import 'notification.dart';
import 'statistiques.dart';
import 'liste_paiement.dart';
import 'mot de passe oublier/code_de_verification.dart';
import 'mot de passe oublier/mot_de_passe_oublier.dart';
import 'mot de passe oublier/verifier_email.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StockageDeToken()),
      ],
      child: MyApp(),
    ),
  );
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
        '/historique':(context)=> HistoriquePage(),
        '/liste_gym': (context) => ListeGymPage(),
        '/scan_qr': (context) => ScanQrPage(),
        '/soumettre_demande':(context)=> SoumettreDemandePage(),
        '/profil': (context) => ProfilPage(),
        '/details_gym': (context) => DetailsGymPage(),
        '/choix_gym': (context) => ChoixGymPage(),
        '/ma_gym': (context) => MaGymPage(),
        "/notifications": (context) => NotificationsPage(),
        "/statistiques": (context) => StatistiquesPage(),
        "/liste-paiements": (context) => ListePaiementPage(),


        // Routes pour le mot de passe oublié
        "/verifier-email": (context) => const VerifierEmailPage(),
        "/code-verification": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return CodeVerificationPage(
            email: args['email'],
            token: args['token'],
          );
        },
        "/nouveau-mot-de-passe": (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return MotDePasseOublierPage(
            email: args['email'],
            token: args['token'],
            codeVerification: args['codeVerification'],
          );
        },

      },
      onGenerateRoute: (settings) {
        // Gestion des routes non définies
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('Page non trouvée: ${settings.name}'),
            ),
          ),
        );
      },
    );
  }
}
