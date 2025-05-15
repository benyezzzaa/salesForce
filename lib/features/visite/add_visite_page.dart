import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddVisitePage extends StatefulWidget {
  const AddVisitePage({super.key});

  @override
  State<AddVisitePage> createState() => _AddVisitePageState();
}

class _AddVisitePageState extends State<AddVisitePage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedClient;
  String? selectedRaison;
  DateTime? selectedDate;

  // 🔐 À adapter avec ton vrai token + URL
  final String token = 'TON_TOKEN_ICI';
  final String apiUrl = 'http://localhost:3000/visites';

  final List<String> clients = ['Fatma Ben Ali', 'Ali Messaoudi', 'Khaled Zid'];
  final List<String> raisons = ['Visite de contrôle', 'Réclamation', 'Nouveau client'];

  Future<void> submitVisite() async {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      final body = {
        "clientId": 1, // à adapter selon le client choisi
        "raisonId": 2, // à adapter selon la raison choisie
        "date": selectedDate!.toIso8601String()
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Visite ajoutée avec succès")),
          );
          Navigator.pop(context);
        } else {
          throw Exception("Erreur de création");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.toString()}")),
        );
      }
    }
  }

  void pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191A49),
      appBar: AppBar(
        title: const Text("Ajouter une visite"),
        backgroundColor: const Color(0xFF191A49),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔽 Client
              DropdownButtonFormField<String>(
                value: selectedClient,
                decoration: const InputDecoration(
                  labelText: 'Client',
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: clients.map((client) {
                  return DropdownMenuItem(
                    value: client,
                    child: Text(client),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedClient = value),
                validator: (value) => value == null ? "Veuillez choisir un client" : null,
              ),
              const SizedBox(height: 16),

              // 🔽 Raison
              DropdownButtonFormField<String>(
                value: selectedRaison,
                decoration: const InputDecoration(
                  labelText: 'Raison de visite',
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: raisons.map((raison) {
                  return DropdownMenuItem(
                    value: raison,
                    child: Text(raison),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedRaison = value),
                validator: (value) => value == null ? "Veuillez choisir une raison" : null,
              ),
              const SizedBox(height: 16),

              // 📅 Date
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    selectedDate != null
                        ? selectedDate!.toLocal().toString().split(' ')[0]
                        : "Aucune date sélectionnée",
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: pickDate,
                    child: const Text("Choisir la date"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: submitVisite,
                icon: const Icon(Icons.add),
                label: const Text("Soumettre"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
