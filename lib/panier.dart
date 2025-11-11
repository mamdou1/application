import 'package:flutter/material.dart';

class PanierPage extends StatelessWidget {
  final List<Map<String, String>> panier;
  final Function(int) onRemove;

  const PanierPage({super.key, required this.panier, required this.onRemove});

  double _calculerTotal() {
    return panier.fold(0, (total, produit) {
      final price = double.tryParse(produit["price"]!.replaceAll('€', '').trim()) ?? 0;
      return total + price;
    });
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
              "Panier",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
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
              child: panier.isEmpty
                  ? const Center(
                child: Text(
                  "Votre panier est vide.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: panier.length,
                      itemBuilder: (context, index) {
                        final produit = panier[index];
                        return Card(
                          color: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              produit["image"]!,
                              height: 50,
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(produit["name"]!),
                            subtitle: Text(produit["price"]!),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () => onRemove(index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Total : ${_calculerTotal().toStringAsFixed(2)} €",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}