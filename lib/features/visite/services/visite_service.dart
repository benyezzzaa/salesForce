import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pfe/core/utils/app_api.dart';
import '../models/client_model.dart';
import '../models/raison_model.dart';
import '../models/visite_model.dart';
import '../models/circuit_model.dart';

class Result<T> {
  final T? data;
  final String? error;

  Result.success(this.data) : error = null;
  Result.error(this.error) : data = null;

  bool get isSuccess => error == null;
}

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

  Future<Result<VisiteModel>> createVisite({
    required String token,
    required DateTime date,
    required int clientId,
    required int raisonId,
  }) async {
    try {
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
        return Result.success(VisiteModel.fromJson(json.decode(response.body)));
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to create visite';
        print('Failed to create visite - Status Code: ${response.statusCode}');
        print('Error Message: $errorMessage');
        return Result.error(errorMessage);
      }
    } catch (e) {
      print('Exception during visite creation: $e');
      return Result.error('Une erreur est survenue lors de la création de la visite');
    }
  }

  Future<Result<CircuitModel>> createCircuit({
    required String token,
    required DateTime date,
    required int clientId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppApi.baseUrl}/circuits'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'date': date.toIso8601String().split('T').first,
          'clientIds': [clientId],
        }),
      );

      if (response.statusCode == 201) {
        return Result.success(CircuitModel.fromJson(json.decode(response.body)));
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ?? 'Failed to create circuit';
        print('Failed to create circuit - Status Code: ${response.statusCode}');
        print('Error Message: $errorMessage');
        return Result.error(errorMessage);
      }
    } catch (e) {
      print('Exception during circuit creation: $e');
      return Result.error('Une erreur est survenue lors de la création du circuit');
    }
  }
} 