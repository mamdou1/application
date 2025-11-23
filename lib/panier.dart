import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';

// Page historique (assure-toi que le fichier existe)
import 'historique_panier.dart';

class PanierPage extends StatefulWidget {
  final List<Map<String, dynamic>> panierLocal;
  final Function(int) onRemoveById;
  final Function() onPanierVide;

  const PanierPage({
    super.key,
    required this.panierLocal,
    required this.onRemoveById,
    required this.onPanierVide,
  });

  @override
  State<PanierPage> createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  bool _isSending = false;

  Future<void> _envoyerLePanier() async {
    if (widget.panierLocal.isEmpty) return;
    setState(() => _isSending = true);

    try {
      final token = Provider.of<StockageDeToken>(context, listen: false).token;
      if (token == null) throw Exception("Non connecté");

      // 1. Créer le panier
      final createResponse = await http.post(
        Uri.parse('${ApiEndpoints.baseUrls}/api/paniers/creer_panier'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (createResponse.statusCode != 201) {
        throw Exception("Échec création panier");
      }

      final panierId = int.tryParse(createResponse.body);
      if (panierId == null) throw Exception("ID panier invalide");

      // 2. Ajouter les produits
      for (final produit in widget.panierLocal) {
        final produitId = produit['id'];
        final quantite = produit['quantite'] ?? 1;

        await http.post(
          Uri.parse('${ApiEndpoints.baseUrls}/api/paniers/ajout_produit/$panierId/$produitId?quantite=$quantite'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 10));
      }

      // 3. Envoyer le panier
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrls}/api/paniers/envoie_panier/$panierId'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Panier envoyé ! La réception vous contactera bientôt"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        widget.onPanierVide();
        Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
      } else {
        throw Exception("Erreur envoi");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  double _calculerTotal() {
    return widget.panierLocal.fold(0.0, (total, item) {
      final prix = (item['prix'] is num) ? item['prix'].toDouble() : double.tryParse(item['prix'].toString()) ?? 0.0;
      final qty = item['quantite'] ?? 1;
      return total + (prix * qty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Mon Panier", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // SEUL BOUTON QUI RESTE : L'HISTORIQUE
          IconButton(
            icon: const Icon(Icons.history, color: Colors.orange, size: 30),
            tooltip: "Historique des paniers",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoriquePaniersPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: widget.panierLocal.isEmpty ? _buildPanierVide() : _buildListeProduits(),
          ),

          // BARRE DU BAS
          if (widget.panierLocal.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                color: Colors.black,
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Total : ${_calculerTotal().toStringAsFixed(0)} FCFA",
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${widget.panierLocal.length} article${widget.panierLocal.length > 1 ? 's' : ''}",
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _isSending ? null : _envoyerLePanier,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _isSending
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Envoyer le panier", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // PANIER VIDE → BOUTON HISTORIQUE
  Widget _buildPanierVide() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey[400]),
        const SizedBox(height: 20),
        const Text("Votre panier est vide", style: TextStyle(fontSize: 20, color: Colors.grey)),
        const SizedBox(height: 10),
        const Text("Ajoutez des produits depuis la boutique !", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          icon: const Icon(Icons.history, color: Colors.white),
          label: const Text("Voir mes anciens paniers"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriquePaniersPage())),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          child: const Text("Retour à la boutique", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );

  Widget _buildListeProduits() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 140),
      itemCount: widget.panierLocal.length,
      itemBuilder: (context, index) {
        final produit = widget.panierLocal[index];
        final int produitId = produit['id'] as int;
        final nom = produit['nom']?.toString() ?? 'Produit';
        final prix = (produit['prix'] is num) ? produit['prix'].toDouble() : double.tryParse(produit['prix'].toString()) ?? 0.0;
        final quantite = produit['quantite'] ?? 1;

        String imageUrl = '';
        if (produit['imageUrl'] != null) {
          final url = produit['imageUrl'].toString();
          imageUrl = url.startsWith('http') ? url : '${ApiEndpoints.baseUrls}$url';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, width: 80, height: 80, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.shopping_bag, color: Colors.grey)))
                      : Container(width: 80, height: 80, color: Colors.grey[300], child: const Icon(Icons.shopping_bag)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nom, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text("${prix.toStringAsFixed(0)} FCFA", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text("Qté: ", style: TextStyle(fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.shade50, border: Border.all(color: Colors.orange), borderRadius: BorderRadius.circular(6)),
                            child: Text("$quantite", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Text("${(prix * quantite).toStringAsFixed(0)} FCFA", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => widget.onRemoveById(produitId),
                      child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}