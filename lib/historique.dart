import 'package:flutter/material.dart';

class HistoriquePage extends StatelessWidget {
  const HistoriquePage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return Historique();
  }
}

class Historique extends StatefulWidget {
  const Historique({super.key});


  @override
  State<Historique> createState()=> _CreateHistoriquePage();
}

class _CreateHistoriquePage extends State<Historique> {
  @override
  Widget build( context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}