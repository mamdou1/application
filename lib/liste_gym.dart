import 'package:flutter/material.dart';

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
  @override
  Widget build( context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}