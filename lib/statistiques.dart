import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import 'package:provider/provider.dart';
import 'StockageDeToken.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatistiquesPage extends StatelessWidget {
  const StatistiquesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Statistiques();
  }
}

class Statistiques extends StatefulWidget {
  const Statistiques({super.key});

  @override
  State<Statistiques> createState() => _CreateStatistiquesPage();
}

class _CreateStatistiquesPage extends State<Statistiques> {
  // Données des statistiques
  Map<String, dynamic> statsData = {};
  bool _isLoading = true;
  String? errorMessage;

  // Données pour les graphiques
  List<ChartData> abonnementData = [];
  List<ChartData> venteData = [];
  List<ChartData> membreData = [];

  @override
  void initState() {
    super.initState();
    _fetchAllStatistics();
  }

  Future<void> _fetchAllStatistics() async {
    final stockageToken = Provider.of<StockageDeToken>(context, listen: false);
    final String? token = stockageToken.token;

    if (token == null || token.isEmpty) {
      setState(() {
        errorMessage = 'Token manquant. Veuillez vous reconnecter';
        _isLoading = false;
      });
      return;
    }

    try {
      // Récupérer toutes les statistiques en parallèle
      await Future.wait([
        _fetchMembreStats(token),
        _fetchAbonnementStats(token),
        _fetchVenteStats(token),
        _fetchPaiements(token),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMembreStats(String token) async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(ApiEndpoints.nombreMembreActifs), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.nombreMembreExpirer), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.nombreMembreBientotExpirer), headers: _buildHeaders(token)),
      ]);

      setState(() {
        statsData['membresActifs'] = _extractNumber(responses[0]);
        statsData['membresExpires'] = _extractNumber(responses[1]);
        statsData['membresBientotExpires'] = _extractNumber(responses[2]);

        // Préparer les données pour le graphique des membres
        membreData = [
          ChartData('Actifs', statsData['membresActifs'] ?? 0, Colors.green),
          ChartData('Expirés', statsData['membresExpires'] ?? 0, Colors.red),
          ChartData('Bientôt expirés', statsData['membresBientotExpires'] ?? 0, Colors.orange),
        ];
      });
    } catch (e) {
      print('Erreur stats membres: $e');
    }
  }

  Future<void> _fetchAbonnementStats(String token) async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(ApiEndpoints.nombreabonnementJour), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.montantabonnementJour), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.nombreabonnementHebdomadaire), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.montantabonnementHebdomadaire), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.nombreabonnementMensuel), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.montantabonnementMensuel), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.nombreabonnementAnuuel), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.montantabonnementAnnuel), headers: _buildHeaders(token)),
      ]);

      setState(() {
        // Abonnements journaliers
        statsData['abonnementsJourNombre'] = _extractNumber(responses[0]);
        statsData['abonnementsJourMontant'] = _extractNumber(responses[1]);

        // Abonnements hebdomadaires
        statsData['abonnementsHebdoNombre'] = _extractNumber(responses[2]);
        statsData['abonnementsHebdoMontant'] = _extractNumber(responses[3]);

        // Abonnements mensuels
        statsData['abonnementsMensuelNombre'] = _extractNumber(responses[4]);
        statsData['abonnementsMensuelMontant'] = _extractNumber(responses[5]);

        // Abonnements annuels
        statsData['abonnementsAnnuelNombre'] = _extractNumber(responses[6]);
        statsData['abonnementsAnnuelMontant'] = _extractNumber(responses[7]);

        // Préparer les données pour le graphique des abonnements
        abonnementData = [
          ChartData('Journalier', statsData['abonnementsJourNombre'] ?? 0, Colors.blue),
          ChartData('Hebdomadaire', statsData['abonnementsHebdoNombre'] ?? 0, Colors.green),
          ChartData('Mensuel', statsData['abonnementsMensuelNombre'] ?? 0, Colors.orange),
          ChartData('Annuel', statsData['abonnementsAnnuelNombre'] ?? 0, Colors.purple),
        ];
      });
    } catch (e) {
      print('Erreur stats abonnements: $e');
    }
  }

  Future<void> _fetchVenteStats(String token) async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(ApiEndpoints.nombreVenteJour), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.montantVenteJour), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.nombreVenteHebdomadaire), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.montantVenteHebdomadaire), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.nombreVenteMensuel), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.montantVenteMensuel), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.nombreVenteAnuuel), headers: _buildHeaders(token)),
        http.get(Uri.parse(ApiEndpoints.montantVenteAnnuel), headers: _buildHeaders(token)),
      ]);

      setState(() {
        // Ventes journalières
        statsData['ventesJourNombre'] = _extractNumber(responses[0]);
        statsData['ventesJourMontant'] = _extractNumber(responses[1]);

        // Ventes hebdomadaires
        statsData['ventesHebdoNombre'] = _extractNumber(responses[2]);
        statsData['ventesHebdoMontant'] = _extractNumber(responses[3]);

        // Ventes mensuelles
        statsData['ventesMensuelNombre'] = _extractNumber(responses[4]);
        statsData['ventesMensuelMontant'] = _extractNumber(responses[5]);

        // Ventes annuelles
        statsData['ventesAnnuelNombre'] = _extractNumber(responses[6]);
        statsData['ventesAnnuelMontant'] = _extractNumber(responses[7]);

        // Préparer les données pour le graphique des ventes
        venteData = [
          ChartData('Journalier', statsData['ventesJourNombre'] ?? 0, Colors.blue),
          ChartData('Hebdomadaire', statsData['ventesHebdoNombre'] ?? 0, Colors.green),
          ChartData('Mensuel', statsData['ventesMensuelNombre'] ?? 0, Colors.orange),
          ChartData('Annuel', statsData['ventesAnnuelNombre'] ?? 0, Colors.purple),
        ];
      });
    } catch (e) {
      print('Erreur stats ventes: $e');
    }
  }

  Future<void> _fetchPaiements(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.listePaiement),
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          statsData['paiements'] = data;
          statsData['totalPaiements'] = data.length;
        });
      }
    } catch (e) {
      print('Erreur récupération paiements: $e');
    }
  }

  Map<String, String> _buildHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _extractNumber(http.Response response) {
    if (response.statusCode == 200) {
      final body = response.body;
      try {
        // Essayer de parser comme JSON
        final data = jsonDecode(body);
        if (data is num) return data.toDouble();
        if (data is Map) return data['count']?.toDouble() ?? data['montant']?.toDouble() ?? 0.0;
        if (data is List) return data.length.toDouble();
        return 0.0;
      } catch (e) {
        // Si ce n'est pas du JSON, essayer de parser comme nombre direct
        try {
          return double.tryParse(body) ?? 0.0;
        } catch (e) {
          return 0.0;
        }
      }
    }
    return 0.0;
  }

  String _formatMontant(dynamic montant) {
    if (montant == null) return '0 FCFA';
    final numValue = montant is String ? double.tryParse(montant) ?? 0.0 : montant.toDouble();
    return '${numValue.toStringAsFixed(0)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
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
              "Tableau de Bord",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchAllStatistics,
            tooltip: 'Actualiser les statistiques',
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: RefreshIndicator(
          onRefresh: _fetchAllStatistics,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.orange[900]))
              : errorMessage != null
              ? Center(
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec titre
                const Text(
                  'Statistiques Générales',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // SECTION MEMBRES
                _buildSectionTitle('📊 Membres'),
                _buildMembreStats(),
                const SizedBox(height: 20),

                // GRAPHIQUE MEMBRES
                if (membreData.isNotEmpty)
                  _buildPieChart(
                    'Répartition des Membres',
                    membreData,
                  ),
                const SizedBox(height: 20),

                // SECTION ABONNEMENTS
                _buildSectionTitle('💰 Abonnements'),
                _buildAbonnementStats(),
                const SizedBox(height: 20),

                // GRAPHIQUE ABONNEMENTS
                if (abonnementData.isNotEmpty)
                  _buildBarChart(
                    'Abonnements par Période',
                    abonnementData,
                  ),
                const SizedBox(height: 20),

                // SECTION VENTES
                _buildSectionTitle('🛒 Ventes'),
                _buildVenteStats(),
                const SizedBox(height: 20),

                // GRAPHIQUE VENTES
                if (venteData.isNotEmpty)
                  _buildBarChart(
                    'Ventes par Période',
                    venteData,
                  ),
                const SizedBox(height: 20),

                // RÉSUMÉ FINANCIER
                _buildSectionTitle('💵 Résumé Financier'),
                _buildFinancialSummary(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.orange,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMembreStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Actifs',
                '${statsData['membresActifs']?.toInt() ?? 0}',
                Icons.people,
                Colors.green,
              ),
              _buildStatCard(
                'Expirés',
                '${statsData['membresExpires']?.toInt() ?? 0}',
                Icons.person_off,
                Colors.red,
              ),
              _buildStatCard(
                'Bientôt expirés',
                '${statsData['membresBientotExpires']?.toInt() ?? 0}',
                Icons.timer,
                Colors.orange,
              ),
            ],
          ),
    );
  }

  Widget _buildAbonnementStats() {
    return Column(
      children: [
        // Cartes horizontales pour les nombres
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildStatCard(
                'Abonnements Aujourd\'hui',
                '${statsData['abonnementsJourNombre']?.toInt() ?? 0}',
                Icons.today,
                Colors.blue,
                montant: _formatMontant(statsData['abonnementsJourMontant']),
              ),
              _buildStatCard(
                'Cette Semaine',
                '${statsData['abonnementsHebdoNombre']?.toInt() ?? 0}',
                Icons.weekend,
                Colors.green,
                montant: _formatMontant(statsData['abonnementsHebdoMontant']),
              ),
              _buildStatCard(
                'Ce Mois',
                '${statsData['abonnementsMensuelNombre']?.toInt() ?? 0}',
                Icons.calendar_month,
                Colors.orange,
                montant: _formatMontant(statsData['abonnementsMensuelMontant']),
              ),
              _buildStatCard(
                'Cette Année',
                '${statsData['abonnementsAnnuelNombre']?.toInt() ?? 0}',
                Icons.celebration,
                Colors.purple,
                montant: _formatMontant(statsData['abonnementsAnnuelMontant']),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVenteStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard(
            'Ventes Aujourd\'hui',
            '${statsData['ventesJourNombre']?.toInt() ?? 0}',
            Icons.shopping_cart,
            Colors.blue,
            montant: _formatMontant(statsData['ventesJourMontant']),
          ),
          _buildStatCard(
            'Cette Semaine',
            '${statsData['ventesHebdoNombre']?.toInt() ?? 0}',
            Icons.weekend,
            Colors.green,
            montant: _formatMontant(statsData['ventesHebdoMontant']),
          ),
          _buildStatCard(
            'Ce Mois',
            '${statsData['ventesMensuelNombre']?.toInt() ?? 0}',
            Icons.calendar_month,
            Colors.orange,
            montant: _formatMontant(statsData['ventesMensuelMontant']),
          ),
          _buildStatCard(
            'Cette Année',
            '${statsData['ventesAnnuelNombre']?.toInt() ?? 0}',
            Icons.celebration,
            Colors.purple,
            montant: _formatMontant(statsData['ventesAnnuelMontant']),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    final totalAbonnements = (statsData['abonnementsJourMontant'] ?? 0) +
        (statsData['abonnementsHebdoMontant'] ?? 0) +
        (statsData['abonnementsMensuelMontant'] ?? 0) +
        (statsData['abonnementsAnnuelMontant'] ?? 0);

    final totalVentes = (statsData['ventesJourMontant'] ?? 0) +
        (statsData['ventesHebdoMontant'] ?? 0) +
        (statsData['ventesMensuelMontant'] ?? 0) +
        (statsData['ventesAnnuelMontant'] ?? 0);

    final chiffreAffaireTotal = totalAbonnements + totalVentes;

    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildFinancialItem('Chiffre d\'affaire Total', _formatMontant(chiffreAffaireTotal), Icons.attach_money, Colors.green),
            const SizedBox(height: 10),
            _buildFinancialItem('Total Abonnements', _formatMontant(totalAbonnements), Icons.subscriptions, Colors.blue),
            const SizedBox(height: 10),
            _buildFinancialItem('Total Ventes', _formatMontant(totalVentes), Icons.shopping_cart, Colors.orange),
            const SizedBox(height: 10),
            _buildFinancialItem('Total Paiements', '${statsData['totalPaiements'] ?? 0}', Icons.payment, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {String? montant}) {
    return Container(
      width: 150,
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          if (montant != null) ...[
            const SizedBox(height: 4),
            Text(
              montant,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(String title, List<ChartData> data) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                palette: data.map((e) => e.color).toList(),
                series: <CircularSeries>[
                  PieSeries<ChartData, String>(
                    dataSource: data,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    dataLabelMapper: (ChartData data, _) => '${data.x}: ${data.y.toInt()}',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(String title, List<ChartData> data) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                ),
                series: <CartesianSeries>[ // CORRECTION ICI : Utiliser CartesianSeries au lieu de ChartSeries
                  ColumnSeries<ChartData, String>(
                    dataSource: data,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Colors.orange,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      textStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Classe pour les données des graphiques
class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}