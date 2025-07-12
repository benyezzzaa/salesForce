import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  String searchQuery = '';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    setState(() => isLoading = true);
    try {
      final response = await api.get("${AppApi.getCommandeUrl}/validees");
      documents = response.data;
    } catch (e) {
      print("Erreur chargement documents : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<dynamic> get filteredDocuments {
    return documents.where((doc) {
      // Filtrer uniquement les commandes validées
      final isValid = (doc['statut']?.toLowerCase() == 'validee');
      // Filtrer par recherche
      final matchesSearch = doc['numero_commande'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc['client']['nom'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc['client']['prenom'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      // Filtrer par date si sélectionnée
      final matchesDate = selectedDate == null ||
        DateFormat('yyyy-MM-dd').format(DateTime.parse(doc['dateCreation'])) == DateFormat('yyyy-MM-dd').format(selectedDate!);
      return isValid && matchesSearch && matchesDate;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade400,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.blue.shade900,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 1,
        title: const Text(
          "Commandes validées",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche et filtre date
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Rechercher une commande ou un client...',
                        hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                        prefixIcon: Icon(Icons.search, color: Colors.blueGrey.shade300),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
                    label: Text(
                      selectedDate == null
                        ? 'Date'
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade200),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  if (selectedDate != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.red.shade300),
                      tooltip: 'Effacer la date',
                      onPressed: () => setState(() => selectedDate = null),
                    ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.blue.shade400))
                  : filteredDocuments.isEmpty
                      ? Center(
                          child: Text(
                            "Aucune commande validée trouvée",
                            style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredDocuments.length,
                          itemBuilder: (context, index) {
                            final doc = filteredDocuments[index];
                            final totalTtc = double.tryParse(doc['prix_total_ttc'].toString()) ?? 0;
                            return _buildDocumentCard(doc, totalTtc);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(dynamic doc, double totalTtc) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue.shade400, size: 22),
                const SizedBox(width: 8),
                Text(
                  doc['numero_commande'],
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Icon(Icons.verified, color: Colors.green.shade400, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Validée',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blueGrey.shade300, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${doc['client']['prenom']} ${doc['client']['nom']}',
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blueGrey.shade300, size: 16),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(doc['dateCreation'])),
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(Icons.attach_money, color: Colors.blueGrey.shade300, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${totalTtc.toStringAsFixed(2)} DT',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadDocument(doc),
                icon: Icon(Icons.download_rounded, color: Colors.blue.shade900, size: 20),
                label: Text(
                  'Télécharger PDF',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadDocument(dynamic doc) async {
    final id = doc['id'];
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Téléchargement en cours...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      await api.downloadPdf(id);
      Get.back();
      Get.snackbar(
        "✅ Succès",
        "PDF téléchargé avec succès",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        "❌ Erreur",
        "Échec du téléchargement",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }
}
