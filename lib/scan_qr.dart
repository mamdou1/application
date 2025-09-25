import 'package:flutter/material.dart';

class ScanQrPage extends StatelessWidget {
  const ScanQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    // On renvoie simplement la page de contenu
    return ScanQr();
  }
}

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});


  @override
  State<ScanQr> createState()=> _CreateScanQrPage();
}

class _CreateScanQrPage extends State<ScanQr> {
  @override
  Widget build( context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}