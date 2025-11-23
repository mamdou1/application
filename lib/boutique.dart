import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'panier.dart';
import 'detail_produit.dart';
import 'utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';

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
  final List<Map<String, dynamic>> _panier = [];
  late SharedPreferences _prefs;

  List<dynamic> produits = [];
  bool isLoading = true;
  String? errorMessage;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPanier();
    _setupScrollListener();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchProduits());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreProduits();
      }
    });
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = Provider.of<StockageDeToken>(context, listen: false).token;
    if (token == null || token.isEmpty) throw Exception("Token manquant");
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchProduits() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
      _currentPage = 0;
      produits.clear();
    });

    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(ApiEndpoints.listeProduits), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          produits = data is List ? data : [];
          _hasMore = produits.length >= _pageSize;
          isLoading = false;
        });
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Impossible de charger les produits";
      });
    }
  }

  Future<void> _loadMoreProduits() async {
    if (!_hasMore || isLoading || !mounted) return;
    setState(() => isLoading = true);
    final nextPage = _currentPage + 1;

    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse('${ApiEndpoints.listeProduits}?page=$nextPage&size=$_pageSize'), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      if (response.statusCode == 200) {
        final newData = jsonDecode(response.body);
        if (newData is List && newData.isNotEmpty) {
          setState(() {
            produits.addAll(newData);
            _currentPage = nextPage;
            _hasMore = newData.length >= _pageSize;
          });
        } else {
          setState(() => _hasMore = false);
        }
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadPanier() async {
    _prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = _prefs.getStringList('panier') ?? [];
    setState(() {
      _panier.clear();
      for (var s in jsonList) {
        try {
          _panier.add(jsonDecode(s) as Map<String, dynamic>);
        } catch (_) {}
      }
    });
  }

  Future<void> _savePanier() async {
    final jsonList = _panier.map((p) => jsonEncode(p)).toList();
    await _prefs.setStringList('panier', jsonList);
  }

  void _ajouterAuPanier(Map<String, dynamic> produit) {
    double prix = 0.0;
    final prixRaw = produit['prixUnitaire'];
    if (prixRaw is num) prix = prixRaw.toDouble();
    else if (prixRaw is String) prix = double.tryParse(prixRaw) ?? 0.0;

    final Map<String, dynamic> produitNet = {
      'id': produit['id'],
      'nom': produit['nom']?.toString() ?? 'Produit',
      'prix': prix,
      'imageUrl': produit['imageUrl'] != null ? ApiEndpoints.baseUrl + produit['imageUrl'] : null,
      'quantiteStock': produit['quantiteEnStock'] is num
          ? produit['quantiteEnStock']
          : int.tryParse(produit['quantiteEnStock'].toString()) ?? 0,
    };

    final id = produit['id'];
    final i = _panier.indexWhere((p) => p['id'] == id);
    setState(() {
      if (i != -1) {
        _panier[i]['quantite'] = (_panier[i]['quantite'] ?? 0) + 1;
      } else {
        _panier.add({...produitNet, 'quantite': 1});
      }
    });
    _savePanier();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${produit['nom'] ?? 'Produit'} ajouté !"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Annuler',
          textColor: Colors.white,
          onPressed: () => _retirerDernierProduit(id),
        ),
      ),
    );
  }

  void _retirerDernierProduit(dynamic id) {
    final i = _panier.indexWhere((p) => p['id'] == id);
    if (i == -1) return;
    setState(() {
      if ((_panier[i]['quantite'] ?? 0) > 1) {
        _panier[i]['quantite']--;
      } else {
        _panier.removeAt(i);
      }
    });
    _savePanier();
  }

  void _allerVersDetails(Map<String, dynamic> p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailProduitPage(
          produit: p,
          onAjouterAuPanier: _ajouterAuPanier,
        ),
      ),
    );
  }

  void _ouvrirPanier() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PanierPage(
          panierLocal: List.from(_panier),

          // NOUVELLE MÉTHODE : suppression par ID du produit → INCASSABLE
          onRemoveById: (int produitId) {
            setState(() {
              _panier.removeWhere((item) => item['id'] == produitId);
              _savePanier();
            });
          },

          onPanierVide: () {
            setState(() {
              _panier.clear();
              _savePanier();
            });
          },
        ),
      ),
    ).then((_) {
      // Optionnel : rafraîchir le badge quand on revient du panier
      setState(() {});
    });
  }

  void _showRecherche() {
    showSearch(
      context: context,
      delegate: ProduitRechercheDelegate(produits: produits, onProduitSelect: _allerVersDetails),
    );
  }

  int _calculerTotalItems() => _panier.fold<int>(0, (s, p) => s + (p['quantite'] as int? ?? 0));

  Widget _buildProductCard(Map<String, dynamic> p) {
    final String nom = p['nom']?.toString() ?? 'Produit sans nom';

    double prix = 0.0;
    final prixRaw = p['prixUnitaire'];
    if (prixRaw != null) {
      if (prixRaw is num) prix = prixRaw.toDouble();
      else if (prixRaw is String) prix = double.tryParse(prixRaw) ?? 0.0;
    }

    int stock = 0;
    final stockRaw = p['quantiteEnStock'];
    if (stockRaw != null) {
      if (stockRaw is num) stock = stockRaw.toInt();
      else if (stockRaw is String) stock = int.tryParse(stockRaw) ?? 0;
    }

    String? fullImageUrl;
    final relative = p['imageUrl']?.toString();
    if (relative != null && relative.isNotEmpty && relative != 'null') {
      fullImageUrl = ApiEndpoints.baseUrl + relative;
    }

    final bool enStock = stock > 0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _allerVersDetails(p),
        child: Container(
          // Contrainte de hauteur fixe pour éviter l'overflow
          constraints: const BoxConstraints(
            minHeight: 200,
            maxHeight: 260,
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image avec hauteur réduite
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    fullImageUrl != null
                        ? Image.network(
                      fullImageUrl,
                      height: 90, // Réduit de 120 à 90
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImageParDefaut(90),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                          height: 90,
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator(color: Colors.orange))),
                    )
                        : _buildImageParDefaut(90),
                    if (!enStock)
                      const Positioned(
                        top: 6,
                        left: 6,
                        child: ColoredBox(
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            child: Text(
                                "Rupture",
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8), // Réduit de 10 à 8

              // Nom du produit
              Text(
                nom,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), // Réduit de 14 à 13
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4), // Réduit de 6 à 4

              // Prix
              Text(
                "${prix.toStringAsFixed(0)} FCFA",
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14), // Réduit de 16 à 14
              ),

              // Stock
              if (stock > 0) ...[
                const SizedBox(height: 2), // Réduit de 4 à 2
                Text(
                  "Stock: $stock",
                  style: TextStyle(
                      color: stock > 10 ? Colors.grey : Colors.orange,
                      fontSize: 11 // Réduit de 12 à 11
                  ),
                ),
              ],

              const Spacer(),

              // Bouton avec hauteur réduite
              Padding(
                padding: const EdgeInsets.only(top: 6), // Réduit de 12 à 6
                child: SizedBox(
                  width: double.infinity,
                  height: 36, // Réduit de 44 à 36
                  child: ElevatedButton(
                    onPressed: enStock ? () => _ajouterAuPanier(p) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: enStock ? Colors.orange : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Réduit de 12 à 10
                      padding: const EdgeInsets.symmetric(vertical: 4), // Ajouté pour réduire l'espace interne
                    ),
                    child: Text(
                      enStock ? "Ajouter" : "Rupture",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Réduit la taille du texte
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageParDefaut(double height) => Container(
    height: height,
    color: Colors.grey[200],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_bag, size: 30, color: Colors.grey), // Réduit de 40 à 30
        const SizedBox(height: 2), // Réduit de 4 à 2
        Text(
          "Image non disponible",
          style: TextStyle(fontSize: 9, color: Colors.grey), // Réduit de 10 à 9
        ),
      ],
    ),
  );

  Widget _buildNavButton(IconData icon, String label, bool active) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: active ? Colors.orange : Colors.grey, size: 24),
      const SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(color: active ? Colors.orange : Colors.grey, fontSize: 12),
      ),
    ],
  );

  Widget _buildProduitsList() {
    if (isLoading && produits.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (errorMessage != null && produits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchProduits,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Réessayer", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    if (produits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "Aucun produit disponible",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchProduits,
      color: Colors.orange,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80), // Espace pour la bottom navigation
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68, // Ajusté pour les cartes plus compactes
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildProductCard(produits[index]),
                childCount: produits.length,
              ),
            ),
          ),
          if (isLoading && _hasMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              ),
            ),
        ],
      ),
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
              icon: const Icon(Icons.arrow_back, color: Colors.orange, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 10),
            const Text(
              "Boutique",
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.orange, size: 28),
              onPressed: _showRecherche,
            ),
            const SizedBox(width: 8),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.orange, size: 28),
                  onPressed: _ouvrirPanier,
                ),
                if (_panier.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        _calculerTotalItems().toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: _buildProduitsList(),
            ),
          ),
          // Bottom Navigation Bar
          Container(
            height: 70,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavButton(Icons.store, "Boutique", true),
                _buildNavButton(Icons.notifications, "Alertes", false),
                _buildNavButton(Icons.calendar_today, "Planning", false),
                _buildNavButton(Icons.history, "Historique", false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProduitRechercheDelegate extends SearchDelegate {
  final List<dynamic> produits;
  final Function(Map<String, dynamic>) onProduitSelect;

  ProduitRechercheDelegate({required this.produits, required this.onProduitSelect});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final results = produits
        .where((p) => (p['nom']?.toString() ?? '').toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final p = results[index];
        final String? imageUrl = p['imageUrl'] != null
            ? ApiEndpoints.baseUrl + p['imageUrl']
            : null;

        return ListTile(
          leading: imageUrl != null
              ? Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.shopping_bag),
          )
              : const Icon(Icons.shopping_bag),
          title: Text(p['nom']?.toString() ?? 'Produit'),
          subtitle: Text("${p['prixUnitaire'] ?? '0'} FCFA"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            onProduitSelect(p);
            close(context, null);
          },
        );
      },
    );
  }
}