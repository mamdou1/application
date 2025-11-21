import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Notifications();
  }
}

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _CreateNotificationsPage();
}

class _CreateNotificationsPage extends State<Notifications> {
  List<dynamic> notifications = [];
  bool _isLoading = true;
  String? errorMessage;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredNotifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;
    final String? role = stockageToken.role;

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'Token manquant. Veuillez vous reconnecter';
        _isLoading = false;
      });
      return;
    }

    try {

      // Sélection automatique de la route selon le role
      final String apiUrl = (role == 'ROLE_ADMIN')
      ?ApiEndpoints.notificationGym
          :ApiEndpoints.notificationUser;

      print("➡️ Route utilisés : $apiUrl (role: $role)");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Réponse API Notifications: Status ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          notifications = data;
          filteredNotifications = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erreur lors du chargement des notifications: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  void _filterNotifications(String query) {
    final results = notifications.where((notification) {
      final titre = notification['titre']?.toLowerCase() ?? '';
      final contenu = notification['contenu']?.toLowerCase() ?? '';
      final contexte = notification['contexte']?.toLowerCase() ?? '';
      final type = notification['typeNotification']?.toLowerCase() ?? '';
      return titre.contains(query.toLowerCase()) ||
          contenu.contains(query.toLowerCase()) ||
          contexte.contains(query.toLowerCase()) ||
          type.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredNotifications = results;
    });
  }

  Future<void> _marquerCommeLu(int notificationId) async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    try {
      final response = await http.put(
        Uri.parse('${ApiEndpoints.notificationUser}/$notificationId/lu'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Mettre à jour localement l'état de la notification
        setState(() {
          final index = notifications.indexWhere((n) => n['id'] == notificationId);
          if (index != -1) {
            notifications[index]['estLu'] = true;
            filteredNotifications = List.from(notifications);
          }
        });
      }
    } catch (e) {
      print('Erreur marquer comme lu: $e');
    }
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _NotificationDetailsDialog(notification: notification);
      },
    );
  }

  void _marquerToutesCommeLues() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    try {
      final response = await http.put(
        Uri.parse('${ApiEndpoints.notificationUser}/marquer-toutes-lues'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Mettre à jour toutes les notifications comme lues
        setState(() {
          for (var notification in notifications) {
            notification['estLu'] = true;
          }
          filteredNotifications = List.from(notifications);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Toutes les notifications ont été marquées comme lues'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Erreur marquer toutes comme lues: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nonLuesCount = notifications.where((n) => n['estLu'] == false).length;

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
            Text(
              "Mes Notifications",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          // Bouton pour marquer toutes comme lues
          if (nonLuesCount > 0)
            IconButton(
              icon: const Icon(Icons.mark_email_read, color: Colors.green),
              onPressed: _marquerToutesCommeLues,
              tooltip: 'Marquer toutes comme lues',
            ),
          // Badge avec le nombre de notifications non lues
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Badge(
              backgroundColor: nonLuesCount > 0 ? Colors.red : Colors.grey,
              label: Text(
                nonLuesCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              child: Icon(Icons.notifications, color: Colors.orange[900]),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: RefreshIndicator(
          onRefresh: _fetchNotifications,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
              : errorMessage != null
              ? Center(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          )
              : notifications.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Aucune notification',
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Vous serez notifié des nouvelles activités',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          )
              : Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterNotifications,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Rechercher dans les notifications...',
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
              // Statistiques rapides
              _buildStatsHeader(),
              // Filtres rapides par type
              _buildTypeFilters(),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredNotifications.length,
                  itemBuilder: (context, index) {
                    final notification = filteredNotifications[index];
                    final String titre = notification['titre'] ?? '';
                    final String contenu = notification['contenu'] ?? '';
                    final String contexte = notification['contexte'] ?? '';
                    final String dateEnvoi = notification['dateEnvoi'] ?? '';
                    final bool estLu = notification['estLu'] ?? false;
                    final String type = notification['typeNotification'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        if (!estLu) {
                          _marquerCommeLu(notification['id']);
                        }
                        _showNotificationDetails(notification);
                      },
                      onLongPress: () {
                        _showNotificationDetails(notification);
                      },
                      child: SizedBox(
                        height: 110,
                        child: Card(
                          color: estLu ? Colors.grey[400] : Colors.grey[300],
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: _buildTypeIcon(type),
                            title: Text(
                              titre,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: estLu ? FontWeight.normal : FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contenu,
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: estLu ? FontWeight.normal : FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _formatDate(dateEnvoi),
                                        style: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _buildTypeChip(type),
                                    // if (contexte.isNotEmpty) ...[
                                    //   const SizedBox(width: 4),
                                    //   _buildContexteChip(contexte),
                                    // ],
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!estLu)
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.orange[900],
                                  size: 20,
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
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 HEADER AVEC STATISTIQUES
  Widget _buildStatsHeader() {
    final nonLues = notifications.where((n) => n['estLu'] == false).length;
    final total = notifications.length;
    final tauxLecture = total > 0 ? ((total - nonLues) / total * 100).toStringAsFixed(0) : '0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildStatItem('Total', total.toString(), Icons.notifications, Colors.blue),
          const SizedBox(width: 8),
          _buildStatItem('Non lues', nonLues.toString(), Icons.mark_email_unread, Colors.red),
          const SizedBox(width: 8),
         // _buildStatItem('Taux', '$tauxLecture%', Icons.bar_chart, Colors.green),
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
                fontSize: 16,
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

  // 🔥 FILTRES RAPIDES PAR TYPE
  Widget _buildTypeFilters() {
    final types = {
      'ABONNEMENT': notifications.where((n) => n['typeNotification'] == 'ABONNEMENT').length,
      'VENTE': notifications.where((n) => n['typeNotification'] == 'VENTE').length,
      'INSCRIPTION': notifications.where((n) => n['typeNotification'] == 'INSCRIPTION').length,
      'PRODUIT': notifications.where((n) => n['typeNotification'] == 'PRODUIT').length,
      'EVENEMENT': notifications.where((n) => n['typeNotification'] == 'EVENEMENT').length,
    };

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: types.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text('${entry.key} (${entry.value})'),
              selected: false,
              onSelected: (_) {
                _searchController.text = entry.key.toLowerCase();
                _filterNotifications(entry.key.toLowerCase());
              },
              backgroundColor: Colors.grey[800],
              labelStyle: const TextStyle(color: Colors.white),
              checkmarkColor: Colors.white,
              selectedColor: Colors.orange[900],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🔥 ICÔNE SELON LE TYPE DE NOTIFICATION
  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'ABONNEMENT':
        icon = Icons.subscriptions;
        color = Colors.blue;
        break;
      case 'VENTE':
        icon = Icons.shopping_cart;
        color = Colors.green;
        break;
      case 'STOCK':
        icon = Icons.inventory;
        color = Colors.orange;
        break;
      case 'PRODUIT':
        icon = Icons.shopping_bag;
        color = Colors.purple;
        break;
      case 'PROMOTION':
        icon = Icons.local_offer;
        color = Colors.red;
        break;
      case 'EVENEMENT':
        icon = Icons.event;
        color = Colors.teal;
        break;
      case 'COACHING':
        icon = Icons.fitness_center;
        color = Colors.deepOrange;
        break;
      case 'INSCRIPTION':
        icon = Icons.person_add;
        color = Colors.indigo;
        break;
      case 'VERIFICATION':
        icon = Icons.verified;
        color = Colors.green;
        break;
      case 'VALIDATION_PANIER':
        icon = Icons.shopping_cart_checkout;
        color = Colors.lightGreen;
        break;
      case 'VALIDATION_INSCRIPTION':
        icon = Icons.how_to_reg;
        color = Colors.blueAccent;
        break;
      default:
        icon = Icons.notifications;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  // 🔥 CHIP POUR LE TYPE
  Widget _buildTypeChip(String type) {
    Color chipColor;
    String typeText;

    switch (type) {
      case 'ABONNEMENT':
        chipColor = Colors.blue;
        typeText = 'Abonnement';
        break;
      case 'VENTE':
        chipColor = Colors.green;
        typeText = 'Vente';
        break;
      case 'STOCK':
        chipColor = Colors.orange;
        typeText = 'Stock';
        break;
      case 'PRODUIT':
        chipColor = Colors.purple;
        typeText = 'Produit';
        break;
      case 'PROMOTION':
        chipColor = Colors.red;
        typeText = 'Promotion';
        break;
      case 'EVENEMENT':
        chipColor = Colors.teal;
        typeText = 'Événement';
        break;
      case 'COACHING':
        chipColor = Colors.deepOrange;
        typeText = 'Coaching';
        break;
      case 'INSCRIPTION':
        chipColor = Colors.indigo;
        typeText = 'Inscription';
        break;
      case 'VERIFICATION':
        chipColor = Colors.green;
        typeText = 'Vérification';
        break;
      case 'VALIDATION_PANIER':
        chipColor = Colors.lightGreen;
        typeText = 'Panier';
        break;
      case 'VALIDATION_INSCRIPTION':
        chipColor = Colors.blueAccent;
        typeText = 'Validation';
        break;
      default:
        chipColor = Colors.grey;
        typeText = type;
    }

    return Chip(
      label: Text(
        typeText,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  // 🔥 CHIP POUR LE CONTEXTE
  Widget _buildContexteChip(String contexte) {
    return Chip(
      label: Text(
        contexte,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: Colors.grey[600],
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  // 🔥 FORMATAGE DE LA DATE
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'À l\'instant';
      if (difference.inMinutes < 60) return 'Il y a ${difference.inMinutes} min';
      if (difference.inHours < 24) return 'Il y a ${difference.inHours} h';
      if (difference.inDays < 7) return 'Il y a ${difference.inDays} j';

      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

// 🔥 DIALOGUE DES DÉTAILS DE NOTIFICATION
class _NotificationDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> notification;

  const _NotificationDetailsDialog({required this.notification});

  @override
  Widget build(BuildContext context) {
    final String titre = notification['titre'] ?? '';
    final String contenu = notification['contenu'] ?? '';
    final String contexte = notification['contexte'] ?? '';
    final String dateEnvoi = notification['dateEnvoi'] ?? '';
    final String type = notification['typeNotification'] ?? '';
    final bool estLu = notification['estLu'] ?? false;

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
                  _buildTypeChip(type),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Titre
            Center(
              child: Text(
                titre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Contenu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                contenu,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Métadonnées
            _buildDetailRow('Type', _getTypeLabel(type)),
            if (contexte.isNotEmpty) _buildDetailRow('Contexte', contexte),
            _buildDetailRow('Date', _formatDetailedDate(dateEnvoi)),
            _buildDetailRow('Statut', estLu ? '✅ Lu' : '🔴 Non lu'),

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

  Widget _buildTypeChip(String type) {
    Color chipColor;
    String typeText;

    switch (type) {
      case 'ABONNEMENT':
        chipColor = Colors.blue;
        typeText = 'Abonnement';
        break;
      case 'VENTE':
        chipColor = Colors.green;
        typeText = 'Vente';
        break;
      case 'STOCK':
        chipColor = Colors.orange;
        typeText = 'Stock';
        break;
      case 'PRODUIT':
        chipColor = Colors.purple;
        typeText = 'Produit';
        break;
      case 'PROMOTION':
        chipColor = Colors.red;
        typeText = 'Promotion';
        break;
      case 'EVENEMENT':
        chipColor = Colors.teal;
        typeText = 'Événement';
        break;
      case 'COACHING':
        chipColor = Colors.deepOrange;
        typeText = 'Coaching';
        break;
      case 'INSCRIPTION':
        chipColor = Colors.indigo;
        typeText = 'Inscription';
        break;
      case 'VERIFICATION':
        chipColor = Colors.green;
        typeText = 'Vérification';
        break;
      case 'VALIDATION_PANIER':
        chipColor = Colors.lightGreen;
        typeText = 'Validation Panier';
        break;
      case 'VALIDATION_INSCRIPTION':
        chipColor = Colors.blueAccent;
        typeText = 'Validation Inscription';
        break;
      default:
        chipColor = Colors.grey;
        typeText = type;
    }

    return Chip(
      label: Text(
        typeText,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'ABONNEMENT': return Icons.subscriptions;
      case 'VENTE': return Icons.shopping_cart;
      case 'STOCK': return Icons.inventory;
      case 'PRODUIT': return Icons.shopping_bag;
      case 'PROMOTION': return Icons.local_offer;
      case 'EVENEMENT': return Icons.event;
      case 'COACHING': return Icons.fitness_center;
      case 'INSCRIPTION': return Icons.person_add;
      case 'VERIFICATION': return Icons.verified;
      case 'VALIDATION_PANIER': return Icons.shopping_cart_checkout;
      case 'VALIDATION_INSCRIPTION': return Icons.how_to_reg;
      default: return Icons.notifications;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'ABONNEMENT': return Colors.blue;
      case 'VENTE': return Colors.green;
      case 'STOCK': return Colors.orange;
      case 'PRODUIT': return Colors.purple;
      case 'PROMOTION': return Colors.red;
      case 'EVENEMENT': return Colors.teal;
      case 'COACHING': return Colors.deepOrange;
      case 'INSCRIPTION': return Colors.indigo;
      case 'VERIFICATION': return Colors.green;
      case 'VALIDATION_PANIER': return Colors.lightGreen;
      case 'VALIDATION_INSCRIPTION': return Colors.blueAccent;
      default: return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'ABONNEMENT': return 'Abonnement';
      case 'VENTE': return 'Vente';
      case 'STOCK': return 'Stock';
      case 'PRODUIT': return 'Produit';
      case 'PROMOTION': return 'Promotion';
      case 'EVENEMENT': return 'Événement';
      case 'COACHING': return 'Coaching';
      case 'INSCRIPTION': return 'Inscription';
      case 'VERIFICATION': return 'Vérification';
      case 'VALIDATION_PANIER': return 'Validation Panier';
      case 'VALIDATION_INSCRIPTION': return 'Validation Inscription';
      default: return type;
    }
  }

  String _formatDetailedDate(String dateString) {
    if (dateString.isEmpty) return 'Date inconnue';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}