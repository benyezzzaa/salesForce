import 'package:pfe/features/clients/models/client_model.dart';

class CircuitModel {
  final int id;
  final DateTime date;
  final Map<String, dynamic> commercial;
  final List<ClientModel> clients;

  CircuitModel({
    required this.id,
    required this.date,
    required this.commercial,
    required this.clients,
  });

  factory CircuitModel.fromJson(Map<String, dynamic> json) {
    return CircuitModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      commercial: json['commercial'],
      clients: List<ClientModel>.from(json['clients'].map((x) => ClientModel.fromJson(x))),
    );
  }
} 