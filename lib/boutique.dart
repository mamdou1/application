import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'panier.dart';
import 'detail_produit.dart'; // Nouveau fichier pour la page de détails

class BoutiquePage extends StatelessWidget {
  const BoutiquePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BoutiqueContent();
  }
}

class BoutiqueContent extends StatefulWidget {
  const BoutiqueContent({super.key});

  @override
  State<BoutiqueContent> createState() => _BoutiqueContentState();
}

class _BoutiqueContentState extends State<BoutiqueContent> {
  final List<Map<String, String>> _panier = [];
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadPanier();
  }

  Future<void> _loadPanier() async {
    _prefs = await SharedPreferences.getInstance();
    final panierJson = _prefs.getStringList('panier') ?? [];
    setState(() {
      _panier.clear();
      _panier.addAll(panierJson.map((json) => Map<String, String>.from(jsonDecode(json))).toList());
    });
  }

  Future<void> _savePanier() async {
    final panierJson = _panier.map((produit) => jsonEncode(produit)).toList();
    await _prefs.setStringList('panier', panierJson);
  }

  void _ajouterAuPanier(Map<String, String> produit) {
    setState(() {
      _panier.add(produit);
    });
    _savePanier();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produit ajouté au panier !")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 25),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 10),
            const Text(
              "Boutique",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.orange),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PanierPage(panier: _panier, onRemove: (index) {
                      setState(() {
                        _panier.removeAt(index);
                      });
                      _savePanier();
                    }),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 650,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Nouveautés",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProductRow(
                        "images/logo.png",
                        "Produit 1",
                        "150 €",
                        "images/camera.png",
                        "Produit 2",
                        "200 €",
                        _ajouterAuPanier,
                      ),
                      const SizedBox(height: 20),
                      _buildProductRow(
                        "images/shop.png",
                        "Produit 3",
                        "120 €",
                        "images/calendar.png",
                        "Produit 4",
                        "80 €",
                        _ajouterAuPanier,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        "Promotions",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildProductRow(
                        "images/hitorique.jpeg",
                        "Produit 5",
                        "50 €",
                        "images/Qr.png",
                        "Produit 6",
                        "40 €",
                        _ajouterAuPanier,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 60,
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.store, color: Colors.orange),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.orange),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.orange),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.orange),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(
      String image1,
      String name1,
      String price1,
      String image2,
      String name2,
      String price2,
      Function(Map<String, String>) ajouterAuPanier,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProductCard(image1, name1, price1, () {
          ajouterAuPanier({"name": name1, "price": price1, "image": image1});
        }, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailProduitPage(
                imagePath: image1,
                name: name1,
                price: price1,
              ),
            ),
          );
        }),
        _buildProductCard(image2, name2, price2, () {
          ajouterAuPanier({"name": name2, "price": price2, "image": image2});
        }, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailProduitPage(
                imagePath: image2,
                name: name2,
                price: price2,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProductCard(String imagePath, String name, String price, VoidCallback onAdd, VoidCallback onTap) {
    return SizedBox(
      width: 150,
      height: 250, // Augmenté pour inclure le bouton
      child: Card(
        color: Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Image.asset(
                imagePath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              price,
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Ajouter au panier"),
            ),
          ],
        ),
      ),
    );
  }
}