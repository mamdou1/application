import 'package:flutter/material.dart';

import 'evennement/calendrier_details.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.orange[900], size: 25),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 10),
          Text(
            "Création de compte",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ],
      ),
    ),
    body: CalendrierDetails(),
  );
}
