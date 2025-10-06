import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';
import '../entite/evenement_model.dart';


class EvenementService {
  static Future<List<EvenementModel>> fetchEvenements(String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.evennement),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => EvenementModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des événements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  static Future<EvenementModel> fetchEvenementDetails(int id, String token) async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.detailEvennement(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return EvenementModel.fromJson(data);
      } else {
        throw Exception('Erreur lors du chargement des détails: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }
}