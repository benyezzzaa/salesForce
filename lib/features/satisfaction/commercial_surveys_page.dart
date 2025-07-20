import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/utils/app_services.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class CommercialSurveysPage extends StatefulWidget {
  const CommercialSurveysPage({Key? key}) : super(key: key);

  @override
  State<CommercialSurveysPage> createState() => _CommercialSurveysPageState();
}

class _CommercialSurveysPageState extends State<CommercialSurveysPage> {
  List surveys = [];
  bool loading = true;
  int? commercialId;

  @override
  void initState() {
    super.initState();
    final user = StorageService.getUser();
    commercialId = user?['id'];
    fetchSurveys();
  }

  Future<void> fetchSurveys() async {
    if (commercialId == null) {
      setState(() => loading = false);
      Get.snackbar('Erreur', 'Impossible de trouver l\'ID du commercial');
      return;
    }
    try {
      final api = ApiService();
      final res = await api.get('/enquetes/affectees?commercialId=$commercialId');
      setState(() {
        surveys = res.data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      Get.snackbar('Erreur', 'Impossible de charger les enquêtes');
    }
  }

  Future<void> downloadSurveyPdf(int surveyId, String nom) async {
    try {
      final api = ApiService();
      final dir = await getApplicationDocumentsDirectory();
      final savePath = "${dir.path}/enquete_${surveyId}_$nom.pdf";
      final token = StorageService.getToken();

      final response = await api.dio.get(
        "/enquetes/$surveyId/pdf",
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data);
      await OpenFile.open(savePath);
      Get.snackbar('Succès', 'PDF téléchargé et ouvert');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de télécharger le PDF');
    }
  }

  void showSurveyDetails(Map s) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Titre + bouton PDF
              Row(
                children: [
                  Icon(Icons.assignment_turned_in, color: Colors.indigo, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s['nom'] ?? '',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                    tooltip: 'Télécharger PDF',
                    onPressed: () => downloadSurveyPdf(s['id'], s['nom'] ?? 'enquete'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 18, color: Colors.indigo),
                  const SizedBox(width: 6),
                  Text('Du ${s['dateDebut']} au ${s['dateFin']}', style: const TextStyle(fontSize: 15)),
                ],
              ),
              if (s['clients'] != null && (s['clients'] as List).isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Clients affectés :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...List.generate(
                  (s['clients'] as List).length,
                  (k) {
                    final cl = s['clients'][k];
                    return Text('- ${cl['nom']} ${cl['prenom']}');
                  },
                ),
              ],
              if (s['questions'] != null && s['questions'].isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Questions :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                ...List.generate(
                  s['questions'].length,
                  (j) {
                    final q = s['questions'][j];
                    String typeLabel;
                    IconData icon;
                    Color color;
                    switch (q['type']) {
                      case 'text':
                        typeLabel = 'Texte libre';
                        icon = Icons.short_text;
                        color = Colors.blue;
                        break;
                      case 'image':
                        typeLabel = 'Image';
                        icon = Icons.image;
                        color = Colors.green;
                        break;
                      case 'select':
                        typeLabel = 'Oui / Non';
                        icon = Icons.check_box;
                        color = Colors.orange;
                        break;
                      default:
                        typeLabel = q['type'];
                        icon = Icons.help_outline;
                        color = Colors.grey;
                    }
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: Icon(icon, color: color, size: 28),
                        title: Text(q['text'], style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                typeLabel,
                                style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ] else
                const Text('Aucune question pour cette enquête.'),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.assignment_turned_in, color: Colors.white, size: 28),
            const SizedBox(width: 10),
            const Text('Enquêtes de satisfaction'),
          ],
        ),
        backgroundColor: colorScheme.primary,
        elevation: 2,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : surveys.isEmpty
              ? const Center(child: Text('Aucune enquête affectée'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: surveys.length,
                  itemBuilder: (context, i) {
                    final s = surveys[i];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => showSurveyDetails(s),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.indigo[50],
                                child: Icon(Icons.assignment_turned_in, color: Colors.indigo[700]),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s['nom'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Du ${s['dateDebut']} au ${s['dateFin']}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.help, size: 16, color: Colors.indigo[400]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(s['questions'] as List?)?.length ?? 0} question(s)',
                                          style: TextStyle(color: Colors.indigo[400], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    if (s['clients'] != null && (s['clients'] as List).isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.people, size: 16, color: Colors.green),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${(s['clients'] as List).length} client(s)',
                                            style: TextStyle(color: Colors.green[700], fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 24),
                                tooltip: 'Télécharger PDF',
                                onPressed: () => downloadSurveyPdf(s['id'], s['nom'] ?? 'enquete'),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.indigo),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 