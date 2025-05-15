import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pfe/features/models/objectif_model.dart';

class ObjectifService {
  final String apiUrl = 'http://localhost:4000/objectifs'; // remplace par ton IP si tu testes sur téléphone

  Future<List<ObjectifModel>> fetchObjectifs() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ObjectifModel.fromJson(e)).toList();
    } else {
      throw Exception("Erreur lors du chargement des objectifs");
    }
  }
}
