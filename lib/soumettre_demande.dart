import 'package:flutter/material.dart';

class SoumettreDemandePage extends StatelessWidget {
  const SoumettreDemandePage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return SoumettreDemande();
  }
}

class SoumettreDemande extends StatefulWidget {
  const SoumettreDemande({super.key});


  @override
  State<SoumettreDemande> createState()=> _CreateSoumettreDemandePage();
}

class _CreateSoumettreDemandePage extends State<SoumettreDemande> {
  @override
  Widget build( context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}