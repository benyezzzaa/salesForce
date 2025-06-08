import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/app_services.dart';

class DocumentsValidesPage extends StatefulWidget {
  const DocumentsValidesPage({super.key});

  @override
  State<DocumentsValidesPage> createState() => _DocumentsValidesPageState();
}

class _DocumentsValidesPageState extends State<DocumentsValidesPage> {
  final ApiService api = ApiService();
  List<dynamic> documents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    try {
      final response = await api.get("${AppApi.getCommandeUrl}/validees");
      documents = response.data;
    } catch (e) {
      print("Erreur chargement documents : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Documents Validés")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
  itemCount: documents.length,
  itemBuilder: (context, index) {
    final doc = documents[index];
    final totalTtc = double.tryParse(doc['prix_total_ttc'].toString()) ?? 0;

    return Card(
      child: ListTile(
        title: Text('Commande : ${doc['numero_commande']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Client : ${doc['client']['nom']}'),
            Text('Date : ${doc['date_creation']}'),
            Text('Total TTC : ${totalTtc.toStringAsFixed(2)} TND'),
          ],
        ),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
      ),
    );
  },
)
    );
  }
}
