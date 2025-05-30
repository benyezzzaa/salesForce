import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pfe/core/utils/app_api.dart';
import '../models/client_model.dart';
import '../models/raison_model.dart';
import '../models/visite_model.dart';
import '../models/circuit_model.dart';

class VisiteService {


  Future<List<ClientModel>> getClients(String token) async {
    final response = await http.get(
      Uri.parse('${AppApi.baseUrl}/client'),
      headers: {
        'Authorization': 'Bearer $token',
         'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ClientModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<List<RaisonModel>> getRaisons(String token) async {
    final response = await http.get(
      Uri.parse('${AppApi.baseUrl}/raisons/actives'),
      headers: {
        'Authorization': 'Bearer $token',
         'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RaisonModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load raisons');
    }
  }

  Future<VisiteModel> createVisite({
    required String token,
    required DateTime date,
    required int clientId,
    required int raisonId,
  }) async {
    final response = await http.post(
      Uri.parse('${AppApi.baseUrl}/visites'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'date': date.toIso8601String(),
        'clientId': clientId,
        'raisonId': raisonId,
      }),
    );

    if (response.statusCode == 201) {
      return VisiteModel.fromJson(json.decode(response.body));
    } else {
      print('Failed to create visite - Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to create visite');
    }
  }

  Future<CircuitModel> createCircuit({
    required String token,
    required DateTime date,
    required int clientId,
  }) async {
    final response = await http.post(
      Uri.parse('${AppApi.baseUrl}/circuits'),
      headers: {
        'Authorization': 'Bearer $token',
         'Content-Type': 'application/json',
      },
      body: json.encode({
        'date': date.toIso8601String().split('T').first, // Format YYYY-MM-DD
        'clientIds': [clientId],
      }),
    );

    if (response.statusCode == 201) {
      return CircuitModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create circuit');
    }
  }
} 