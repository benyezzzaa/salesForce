import 'client_model.dart';

class VisiteModel {
  final int id;
  final DateTime date;
  final ClientModel client;
  final Map<String, dynamic> user;

  VisiteModel({
    required this.id,
    required this.date,
    required this.client,
    required this.user,
  });

  factory VisiteModel.fromJson(Map<String, dynamic> json) {
    return VisiteModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      client: ClientModel.fromJson(json['client']),
      user: json['user'],
    );
  }
} 