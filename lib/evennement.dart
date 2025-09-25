import 'package:flutter/material.dart';

class EventPage extends StatelessWidget {
  const EventPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return Event();
  }
}

class Event extends StatefulWidget {
  const Event({super.key});


  @override
  State<Event> createState()=> _CreateEventPage();
}

class _CreateEventPage extends State<Event> {
  @override
  Widget build( context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}