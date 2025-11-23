// lib/pages/historique_paniers_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import '../StockageDeToken.dart';

class HistoriquePaniersPage extends StatefulWidget {
  const HistoriquePaniersPage({super.key});

  @override
  State<HistoriquePaniersPage> createState() => _HistoriquePaniersPageState();
}

class _HistoriquePaniersPageState extends State<HistoriquePaniersPage> {
  late Future<List<dynamic>> futurePaniers;

  @override
  void initState() {
    super.initState();
    futurePaniers = fetchHistorique();
  }

  Future<List<dynamic>> fetchHistorique() async {
    final token = Provider.of<StockageDeToken>(context, listen: false).token;
    if (token == null) throw Exception("Non connecté");

    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrls}/api/paniers/historique'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Impossible de charger l'historique");
    }
  }

  // COULEUR SELON LE STATUT
  Color _couleurStatut(String? statut) {
    switch (statut) {
      case 'EN_ATTENTE_VALIDATION':
        return Colors.orange;
      case 'VALIDE':           // CORRIGÉ
        return Colors.green;
      case 'REJETE':           // CORRIGÉ
        return Colors.red;
      case 'ANNULE':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  // TEXTE AFFICHÉ
  String _texteStatut(String? statut) {
    switch (statut) {
      case 'EN_ATTENTE_VALIDATION':
        return 'En attente';
      case 'VALIDE':           // CORRIGÉ
        return 'Validé';
      case 'REJETE':           // CORRIGÉ
        return 'Rejeté';
      case 'ANNULE':
        return 'Annulé';
      default:
        return 'Brouillon';
    }
  }

  // ICÔNE SELON LE STATUT
  IconData _iconeStatut(String? statut) {
    switch (statut) {
      case 'EN_ATTENTE_VALIDATION':
        return Icons.access_time;
      case 'VALIDE':           // CORRIGÉ
        return Icons.check_circle;
      case 'REJETE':           // CORRIGÉ
        return Icons.cancel;
      default:
        return Icons.shopping_cart;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Historique des paniers",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.orange),
            onPressed: () => setState(() => futurePaniers = fetchHistorique()),
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: FutureBuilder<List<dynamic>>(
          future: futurePaniers,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final paniers = snapshot.data!;
              if (paniers.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text("Aucun panier envoyé pour le moment",
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: paniers.length,
                itemBuilder: (context, index) {
                  final panier = paniers[index];
                  final statut = panier['statut'] as String?;
                  final dateStr = panier['dateCreation'] as String?;
                  final date = dateStr != null
                      ? DateTime.parse(dateStr).toLocal()
                      : DateTime.now();

                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => DetailPanierModal(panier: panier),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: _couleurStatut(statut),
                              child: Icon(_iconeStatut(statut), color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Panier #${panier['id']}",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${panier['montantTotal']?.toStringAsFixed(0) ?? '0'} FCFA",
                                    style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                                  ),
                                  Text("${panier['lignes']?.length ?? 0} article(s)"),
                                  Text(
                                    "${DateFormat('dd/MM/yyyy à HH:mm').format(date)}",
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              backgroundColor: _couleurStatut(statut),
                              label: Text(
                                _texteStatut(statut),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("Erreur : ${snapshot.error}"));
            }
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          },
        ),
      ),
    );
  }
}

// MODAL DÉTAIL AU CLIC
class DetailPanierModal extends StatelessWidget {
  final dynamic panier;
  const DetailPanierModal({super.key, required this.panier});

  @override
  Widget build(BuildContext context) {
    final lignes = (panier['lignes'] as List<dynamic>?) ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 60, height: 6, color: Colors.grey[300]),
            ),
            const SizedBox(height: 20),
            Text("Détail du panier #${panier['id']}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: lignes.length,
                itemBuilder: (context, i) {
                  final ligne = lignes[i];
                  final produit = ligne['produit'];
                  return ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.orange),
                    title: Text(produit['nom'] ?? 'Produit inconnu'),
                    subtitle: Text("Qté: ${ligne['quantite']} × ${ligne['prixUnitaire']} FCFA"),
                    trailing: Text("${(ligne['prixUnitaire'] * ligne['quantite']).toStringAsFixed(0)} FCFA",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            const Divider(),
            Text("TOTAL : ${panier['montantTotal']?.toStringAsFixed(0) ?? '0'} FCFA",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}