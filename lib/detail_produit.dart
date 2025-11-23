import 'package:flutter/material.dart';

class DetailProduitPage extends StatelessWidget {
  // On accepte maintenant tout le produit (plus flexible)
  final Map<String, dynamic> produit;
  final Function(Map<String, dynamic>) onAjouterAuPanier; // Callback pour ajouter au panier

  const DetailProduitPage({
    super.key,
    required this.produit,
    required this.onAjouterAuPanier,
  });

  @override
  Widget build(BuildContext context) {
    final String imageUrl = produit['imageUrl'] ?? produit['image'] ?? 'images/logo.png';
    final String nom = produit['nom'] ?? produit['name'] ?? 'Produit sans nom';
    final String prixStr = (produit['prix'] ?? produit['price'] ?? 0).toString();
    final String description = produit['description'] ?? "Aucune description disponible.";

    // Nettoie le prix pour l'affichage
    final double prix = double.tryParse(prixStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          nom,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Contenu principal (fond blanc arrondi)
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image du produit (en ligne ou asset)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                        imageUrl,
                        height: 320,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'images/logo.png',
                          height: 320,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Image.asset(imageUrl, height: 320, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 30),

                    // Nom du produit
                    Text(
                      nom,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Prix bien visible
                    Text(
                      "${prix.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Description
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Bouton "Ajouter au panier" fixe en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: () {
                    onAjouterAuPanier(produit);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$nom ajouté au panier !"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Future.delayed(const Duration(milliseconds: 800), () {
                      Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 10,
                  ),
                  child: const Text(
                    "Ajouter au panier",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}