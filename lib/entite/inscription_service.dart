import 'package:http/http.dart' as http;
import 'inscription_en_ligne_dto.dart';
import 'package:gestion_salle_de_sport/utils/api_endpoints.dart';

class InscriptionService {
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const String baseUrls = 'http://192.168.137.1:8080';

  Future<http.Response> inscriptionEnLigne(
      InscriptionEnLigneDTO dto, {
        List<int>? fichierBytes,
        String? nomFichier,
      }) async {
    try {
      // Créer une requête multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.inscriptionEnLigne),
      );

      // Ajouter les champs texte
      request.fields.addAll({
        'nom': dto.nom,
        'prenom': dto.prenom,
        'adresse': dto.adresse,
        'email': dto.email,
        'telephone': dto.telephone,
        'genre': dto.genre,
        'date_de_naissance': dto.date_de_naissance, // 🔥 CORRIGÉ : dateDeNaissance → date_de_naissance
        'password': dto.password,
      });

      // Ajouter le fichier si présent
      if (fichierBytes != null && nomFichier != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fichierBytes,
            filename: nomFichier,
          ),
        );
      }

      // Envoyer la requête
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return response;
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }
}