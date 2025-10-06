import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';
import 'package:intl/intl.dart';

class ListePaiementPage extends StatelessWidget {
  const ListePaiementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListePaiement();
  }
}

class ListePaiement extends StatefulWidget {
  const ListePaiement({super.key});

  @override
  State<ListePaiement> createState() => _CreateListePaiementPage();
}

class _CreateListePaiementPage extends State<ListePaiement> {
  List<dynamic> paiements = [];
  bool _isLoading = true;
  String? errorMessage;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredPaiements = [];

  // Pagination
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Filtres
  String _selectedType = 'TOUS';
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  final List<String> _typesPaiement = [
    'TOUS',
    'ABONNEMENT',
    'VENTE',
    'USER',
    'CASIER'
  ];

  @override
  void initState() {
    super.initState();
    _fetchPaiements();
  }

  Future<void> _fetchPaiements({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _currentPage = 0;
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'Token manquant. Veuillez vous reconnecter';
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    try {
      String url;

      // Construire l'URL en fonction des filtres
      if (_selectedType != 'TOUS') {
        url = ApiEndpoints.listePaiementType(_selectedType);
      } else if (_selectedStartDate != null && _selectedEndDate != null) {
        final startStr = DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
        final endStr = DateFormat('yyyy-MM-dd').format(_selectedEndDate!);
        url = '${ApiEndpoints.listePaiementPeriode}?dateDebut=$startStr&dateFin=$endStr';
      } else {
        url = ApiEndpoints.listePaiement;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // 🔥 CORRECTION : Récupérer les informations des acheteurs
        final paiementsAvecAcheteurs = await _enrichirPaiementsAvecAcheteurs(data, token);

        if (loadMore) {
          setState(() {
            paiements.addAll(paiementsAvecAcheteurs);
            filteredPaiements = List.from(paiements);
            _hasMore = data.length == _pageSize;
            _isLoadingMore = false;
          });
        } else {
          setState(() {
            paiements = paiementsAvecAcheteurs;
            filteredPaiements = paiementsAvecAcheteurs;
            _hasMore = data.length == _pageSize;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Erreur lors du chargement des paiements: ${response.statusCode}';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  // 🔥 NOUVELLE MÉTHODE : Récupérer les informations des acheteurs
  Future<List<dynamic>> _enrichirPaiementsAvecAcheteurs(List<dynamic> paiements, String token) async {
    final List<dynamic> paiementsEnrichis = [];

    for (var paiement in paiements) {
      try {
        // Vérifier si l'acheteur existe et a un ID
        final acheteur = paiement['acheteur'];
        if (acheteur != null && acheteur['id'] != null) {
          final acheteurId = acheteur['id'];

          // Récupérer les informations complètes de l'acheteur
          final response = await http.get(
            Uri.parse(ApiEndpoints.profil(acheteurId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            final userData = jsonDecode(response.body);

            // Créer une copie du paiement avec les informations enrichies
            final paiementEnrichi = Map<String, dynamic>.from(paiement);
            paiementEnrichi['acheteurNom'] = userData['nom'] ?? 'Non spécifié';
            paiementEnrichi['acheteurPrenom'] = userData['prenom'] ?? '';
            paiementEnrichi['acheteurTelephone'] = userData['telephone'] ?? '';
            paiementEnrichi['acheteurEmail'] = userData['email'] ?? '';

            paiementsEnrichis.add(paiementEnrichi);
          } else {
            // Si erreur, utiliser les données de base
            final paiementEnrichi = Map<String, dynamic>.from(paiement);
            paiementEnrichi['acheteurNom'] = acheteur['nom'] ?? 'Non spécifié';
            paiementEnrichi['acheteurPrenom'] = acheteur['prenom'] ?? '';
            paiementsEnrichis.add(paiementEnrichi);
          }
        } else {
          // Pas d'acheteur (cas des ventes anonymes)
          final paiementEnrichi = Map<String, dynamic>.from(paiement);
          paiementEnrichi['acheteurNom'] = 'Client';
          paiementEnrichi['acheteurPrenom'] = 'Anonyme';
          paiementsEnrichis.add(paiementEnrichi);
        }
      } catch (e) {
        // En cas d'erreur, utiliser les données de base
        print('Erreur récupération acheteur: $e');
        final paiementEnrichi = Map<String, dynamic>.from(paiement);
        final acheteur = paiement['acheteur'];
        paiementEnrichi['acheteurNom'] = acheteur?['nom'] ?? 'Non spécifié';
        paiementEnrichi['acheteurPrenom'] = acheteur?['prenom'] ?? '';
        paiementsEnrichis.add(paiementEnrichi);
      }
    }

    return paiementsEnrichis;
  }

  void _filterPaiements(String query) {
    final results = paiements.where((paiement) {
      final acheteurNom = paiement['acheteurNom']?.toLowerCase() ?? '';
      final acheteurPrenom = paiement['acheteurPrenom']?.toLowerCase() ?? '';
      final type = paiement['typePaiement']?.toLowerCase() ?? '';
      final details = paiement['details']?.toLowerCase() ?? '';
      final montant = paiement['montant']?.toString() ?? '';

      return acheteurNom.contains(query.toLowerCase()) ||
          acheteurPrenom.contains(query.toLowerCase()) ||
          type.contains(query.toLowerCase()) ||
          details.contains(query.toLowerCase()) ||
          montant.contains(query);
    }).toList();

    setState(() {
      filteredPaiements = results;
    });
  }

  void _loadMorePaiements() {
    if (!_isLoadingMore && _hasMore) {
      _currentPage++;
      _fetchPaiements(loadMore: true);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Filtrer les paiements',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Filtre par type
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      dropdownColor: Colors.grey[800],
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Type de paiement',
                        labelStyle: TextStyle(color: Colors.orange),
                        border: OutlineInputBorder(),
                      ),
                      items: _typesPaiement.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            _getTypeLabel(type),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Filtre par date de début
                    ListTile(
                      title: const Text(
                        'Date de début',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        _selectedStartDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedStartDate!)
                            : 'Non sélectionnée',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: Colors.orange),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedStartDate = picked;
                          });
                        }
                      },
                    ),

                    // Filtre par date de fin
                    ListTile(
                      title: const Text(
                        'Date de fin',
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        _selectedEndDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedEndDate!)
                            : 'Non sélectionnée',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: Colors.orange),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedEndDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[900],
                  ),
                  child: const Text('Appliquer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _applyFilters() {
    _fetchPaiements();
  }

  void _clearFilters() {
    setState(() {
      _selectedType = 'TOUS';
      _selectedStartDate = null;
      _selectedEndDate = null;
      _searchController.clear();
    });
    _fetchPaiements();
  }

  void _showPaiementDetails(Map<String, dynamic> paiement) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _PaiementDetailsDialog(paiement: paiement);
      },
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'TOUS': return 'Tous les types';
      case 'ABONNEMENT': return 'Abonnement';
      case 'VENTE': return 'Vente';
      case 'USER': return 'Utilisateur';
      case 'CASIER': return 'Casier';
      default: return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ABONNEMENT': return Colors.blue;
      case 'VENTE': return Colors.green;
      case 'USER': return Colors.purple;
      case 'CASIER': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'ABONNEMENT': return Icons.subscriptions;
      case 'VENTE': return Icons.shopping_cart;
      case 'USER': return Icons.person;
      case 'CASIER': return Icons.lock;
      default: return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = _selectedType != 'TOUS' ||
        _selectedStartDate != null ||
        _selectedEndDate != null;

    return Scaffold(
      appBar: AppBar(
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
            const Text(
              "Liste des Paiements",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off, color: Colors.red),
              onPressed: _clearFilters,
              tooltip: 'Effacer les filtres',
            ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.orange),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrer',
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterPaiements,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Rechercher un paiement...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.orange[900]!),
                  ),
                ),
              ),
            ),

            // Indicateurs de filtres actifs
            if (hasActiveFilters)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (_selectedType != 'TOUS')
                      Chip(
                        label: Text('Type: ${_getTypeLabel(_selectedType)}'),
                        backgroundColor: Colors.orange[900],
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedType = 'TOUS';
                          });
                          _fetchPaiements();
                        },
                      ),
                    if (_selectedStartDate != null)
                      Chip(
                        label: Text('Début: ${DateFormat('dd/MM/yyyy').format(_selectedStartDate!)}'),
                        backgroundColor: Colors.blue,
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedStartDate = null;
                          });
                          _fetchPaiements();
                        },
                      ),
                    if (_selectedEndDate != null)
                      Chip(
                        label: Text('Fin: ${DateFormat('dd/MM/yyyy').format(_selectedEndDate!)}'),
                        backgroundColor: Colors.green,
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() {
                            _selectedEndDate = null;
                          });
                          _fetchPaiements();
                        },
                      ),
                  ],
                ),
              ),

            // Statistiques rapides
            _buildStatsHeader(),

            // Liste des paiements
            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchPaiements,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
                    : errorMessage != null
                    ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
                    : filteredPaiements.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun paiement trouvé',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ajustez vos filtres ou réessayez',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                )
                    : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                        !_isLoadingMore &&
                        _hasMore) {
                      _loadMorePaiements();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    itemCount: filteredPaiements.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredPaiements.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: Colors.orange[900]),
                          ),
                        );
                      }

                      final paiement = filteredPaiements[index];
                      final String type = paiement['typePaiement'] ?? '';
                      final String acheteurNom = paiement['acheteurNom'] ?? 'Non spécifié';
                      final String acheteurPrenom = paiement['acheteurPrenom'] ?? '';
                      final double montant = (paiement['montant'] ?? 0).toDouble();
                      final String datePaiement = paiement['datePaiement'] ?? '';
                      final String details = paiement['details'] ?? '';
                      final String modeDePaiement = paiement['modeDePaiement'] ?? '';

                      return GestureDetector(
                        onTap: () {
                          _showPaiementDetails(paiement);
                        },
                        child: SizedBox(
                          height: 100,
                          child: Card(
                            color: Colors.grey[300],
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(type).withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getTypeIcon(type),
                                  color: _getTypeColor(type),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                '$acheteurPrenom $acheteurNom',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    details,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatDate(datePaiement)} • ${_getTypeLabel(type)}',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${montant.toStringAsFixed(0)} FCFA',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Chip(
                                    label: Text(
                                      modeDePaiement,
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                    backgroundColor: Colors.grey[600],
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final totalPaiements = paiements.length;
    final totalMontant = paiements.fold<double>(0, (sum, p) => sum + (p['montant'] ?? 0).toDouble());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatItem('Total', totalPaiements.toString(), Icons.payment, Colors.blue),
          const SizedBox(width: 8),
          _buildStatItem('Montant', '${totalMontant.toStringAsFixed(0)} FCFA', Icons.attach_money, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
}

// 🔥 DIALOGUE DES DÉTAILS DE PAIEMENT
class _PaiementDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> paiement;

  const _PaiementDetailsDialog({required this.paiement});

  @override
  Widget build(BuildContext context) {
    final String type = paiement['typePaiement'] ?? '';
    final String acheteurNom = paiement['acheteurNom'] ?? 'Non spécifié';
    final String acheteurPrenom = paiement['acheteurPrenom'] ?? '';
    final String acheteurTelephone = paiement['acheteurTelephone'] ?? '';
    final String acheteurEmail = paiement['acheteurEmail'] ?? '';
    final double montant = (paiement['montant'] ?? 0).toDouble();
    final String datePaiement = paiement['datePaiement'] ?? '';
    final String details = paiement['details'] ?? '';
    final String modeDePaiement = paiement['modeDePaiement'] ?? '';
    final String referenceId = paiement['referenceId']?.toString() ?? '';
    final String gymNom = paiement['gymNom'] ?? '';
    final String staffNom = paiement['staffNom'] ?? '';
    final String staffPrenom = paiement['staffPrenom'] ?? '';

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getTypeColor(type).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getTypeIcon(type), color: _getTypeColor(type), size: 32),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      _getTypeLabel(type),
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _getTypeColor(type),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Montant
            Center(
              child: Text(
                '${montant.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Détails
            _buildDetailRow('Client', '$acheteurPrenom $acheteurNom'),
            if (acheteurTelephone.isNotEmpty) _buildDetailRow('Téléphone', acheteurTelephone),
            if (acheteurEmail.isNotEmpty) _buildDetailRow('Email', acheteurEmail),
            _buildDetailRow('Détails', details),
            _buildDetailRow('Mode de paiement', modeDePaiement),
            _buildDetailRow('Date', _formatDetailedDate(datePaiement)),
            if (referenceId.isNotEmpty) _buildDetailRow('Référence', referenceId),
            if (gymNom.isNotEmpty) _buildDetailRow('Gym', gymNom),
            if (staffNom.isNotEmpty) _buildDetailRow('Staff', '$staffPrenom $staffNom'),

            const SizedBox(height: 25),

            // Bouton Fermer
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[900],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ABONNEMENT': return Colors.blue;
      case 'VENTE': return Colors.green;
      case 'USER': return Colors.purple;
      case 'CASIER': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'ABONNEMENT': return Icons.subscriptions;
      case 'VENTE': return Icons.shopping_cart;
      case 'USER': return Icons.person;
      case 'CASIER': return Icons.lock;
      default: return Icons.payment;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'ABONNEMENT': return 'Abonnement';
      case 'VENTE': return 'Vente';
      case 'USER': return 'Utilisateur';
      case 'CASIER': return 'Casier';
      default: return type;
    }
  }

  String _formatDetailedDate(String dateString) {
    if (dateString.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }
}