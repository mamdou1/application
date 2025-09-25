import 'package:flutter/material.dart';

class AProposPage extends StatelessWidget {
  const AProposPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return APropos();
  }
}

class APropos extends StatefulWidget {
  const APropos({super.key});


  @override
  State<APropos> createState()=> _CreateAProposPage();
}

class _CreateAProposPage extends State<APropos> {
  @override
  Widget build( context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}