import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VisitesPage extends StatefulWidget {
  const VisitesPage({super.key});

  @override
  State<VisitesPage> createState() => _VisitesPageState();
}

class _VisitesPageState extends State<VisitesPage> {
  List<dynamic> visites = [];
  bool isLoading = true;

  // À remplacer selon ton projet
  final String token = 'TON_TOKEN_ICI';
  final int commercialId = 1;
  final String apiUrl = 'http://localhost:3000/visites/commercial/1';

  @override
  void initState() {
    super.initState();
    fetchVisites();
  }

  Future<void> fetchVisites() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        setState(() {
          visites = jsonDecode(res.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  void openFormulaireVisite() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F5B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: _FormulaireVisite(onSuccess: () {
          Navigator.pop(context);
          fetchVisites(); // recharger après ajout
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191A49),
      appBar: AppBar(
        title: const Text('Mes Visites'),
        backgroundColor: const Color(0xFF191A49),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : visites.isEmpty
              ? const Center(child: Text("Aucune visite", style: TextStyle(color: Colors.white)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: visites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final v = visites[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Client : ${v['client']['nom']}", style: const TextStyle(color: Colors.white)),
                          Text("Raison : ${v['raison']['libelle']}", style: const TextStyle(color: Colors.white70)),
                          Text("Date : ${v['date']}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: openFormulaireVisite,
      ),
    );
  }
}

class _FormulaireVisite extends StatefulWidget {
  final VoidCallback onSuccess;
  const _FormulaireVisite({required this.onSuccess});

  @override
  State<_FormulaireVisite> createState() => _FormulaireVisiteState();
}

class _FormulaireVisiteState extends State<_FormulaireVisite> {
  final _formKey = GlobalKey<FormState>();

  String? selectedClient;
  String? selectedRaison;
  DateTime? selectedDate;

  final List<String> clients = ['Fatma Ben Ali', 'Ali Messaoudi'];
  final List<String> raisons = ['Réclamation', 'Visite de contrôle'];

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) return;

    final body = {
      "clientId": 1, // à mapper depuis le nom sélectionné
      "raisonId": 2, // idem
      "date": selectedDate!.toIso8601String(),
    };

    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/visites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer TON_TOKEN_ICI',
        },
        body: jsonEncode(body),
      );
      if (res.statusCode == 201) {
        widget.onSuccess();
      } else {
        throw Exception('Erreur de soumission');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
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
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedClient,
            decoration: const InputDecoration(labelText: "Client", filled: true, fillColor: Colors.white),
            items: clients.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => selectedClient = v),
            validator: (v) => v == null ? "Choisissez un client" : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedRaison,
            decoration: const InputDecoration(labelText: "Raison", filled: true, fillColor: Colors.white),
            items: raisons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => selectedRaison = v),
            validator: (v) => v == null ? "Choisissez une raison" : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                selectedDate != null
                    ? selectedDate!.toLocal().toString().split(' ')[0]
                    : "Date non choisie",
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: pickDate,
                child: const Text("Choisir la date"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: submit,
            icon: const Icon(Icons.send),
            label: const Text("Soumettre"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }
}
