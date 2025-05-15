import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CommandeDetailsPage extends StatelessWidget {
  final Map<String, dynamic> commande;

  const CommandeDetailsPage({super.key, required this.commande});

  void _downloadPdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Bon de Commande', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 12),
              pw.Text('Commande : ${commande['numeroCommande']}'),
              pw.Text('Client : ${commande['client']}'),
              pw.Text('Date : ${commande['date']}'),
              pw.SizedBox(height: 12),
              pw.Text('Produits :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ...((commande['lignes'] as List).map((p) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 4),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(p['nom']),
                        pw.Text("${p['quantite']} x ${p['prix']} DT"),
                      ],
                    ),
                  ))),
              pw.Divider(),
              pw.Text("Total TTC : ${commande['totalTTC']} DT", style: pw.TextStyle(color: PdfColors.indigo, fontSize: 18)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final produits = commande['lignes'] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.white),
            const SizedBox(width: 8),
            Text('Commande #${commande['numeroCommande']}', style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: () => _downloadPdf(context),
            tooltip: 'Télécharger en PDF',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("👤 Client", commande['client']),
            _buildInfoRow("📅 Date", commande['date']),
            const SizedBox(height: 20),
            const Text("🛍️ Produits Commandés", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: produits.length,
                itemBuilder: (context, index) {
                  final produit = produits[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: Colors.indigo),
                            const SizedBox(width: 10),
                            Text(produit['nom'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Text("${produit['quantite']} x ${produit['prix']} DT",
                            style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text("💰 Total TTC : ${commande['totalTTC']} DT",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text("$label : ", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16))),
        ],
      ),
    );
  }
}
