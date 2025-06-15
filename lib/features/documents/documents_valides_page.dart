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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("📄 Documents Validés"),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : documents.isEmpty
              ? const Center(child: Text("Aucun document validé trouvé."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    final totalTtc = double.tryParse(doc['prix_total_ttc'].toString()) ?? 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.receipt_long, color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Text(
                                  "Commande #${doc['numero_commande']}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Spacer(),
                                const Icon(Icons.check_circle, color: Colors.green, size: 22),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Client : ${doc['client']['nom']}",
                                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "Date : ${doc['date_creation']}",
                                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  "Total TTC : ${totalTtc.toStringAsFixed(2)} TND",
                                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () async {
                                  final id = doc['id'];
                                  try {
                                    await api.downloadPdf(id);
                                    Get.snackbar("Téléchargement", "Commande PDF téléchargée avec succès",
                                        snackPosition: SnackPosition.BOTTOM);
                                  } catch (e) {
                                    Get.snackbar("Erreur", "Échec du téléchargement du PDF",
                                        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
                                  }
                                },
                                icon: const Icon(Icons.download),
                                label: const Text("Télécharger PDF"),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
