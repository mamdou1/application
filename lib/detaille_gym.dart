import 'package:flutter/material.dart';

class DetailleGymPage extends StatelessWidget {
  const DetailleGymPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return DetailleGym();
  }
}

class DetailleGym extends StatefulWidget {
  const DetailleGym({super.key});


  @override
  State<DetailleGym> createState()=> _CreateDetailleGymPage();
}

class _CreateDetailleGymPage extends State<DetailleGym> {
  @override
  Widget build( context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}