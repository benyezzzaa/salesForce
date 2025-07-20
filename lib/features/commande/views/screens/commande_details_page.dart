import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../models/commande_model.dart';

class CommandeDetailsPage extends StatelessWidget {
  final CommandeModel commande;
  const CommandeDetailsPage({super.key, required this.commande});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        title: Text('Commande ${commande.numeroCommande}', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pdfFile = await _generatePdfAndSave();
          await _sendEmailWithPdf(pdfFile, context);
        },
        label: const Text("Envoyer PDF"),
        icon: const Icon(Icons.email),
        backgroundColor: color.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(isDark),
            const SizedBox(height: 24),
            const Text("🛒 Produits commandés :", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (commande.lignes.isEmpty)
              const Text("Aucun produit trouvé.")
            else
              ListView.builder(
                itemCount: commande.lignes.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final ligne = commande.lignes[index];
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.indigo.shade900.withOpacity(0.2) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ligne.produitNom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              if (ligne.produitDescription.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  ligne.produitDescription,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text("Quantité : ${ligne.quantite}", style: const TextStyle(fontSize: 14)),
                              Text("Prix unitaire : ${ligne.prixUnitaire.toStringAsFixed(2)} €", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("${ligne.total.toStringAsFixed(2)} €", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text("Total", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.blueGrey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("🧍 Client", commande.clientNom),
          _infoRow("📍 Adresse", commande.clientAdresse ?? 'Non spécifiée'),
          _infoRow("📅 Date", commande.dateCreation),
          _infoRow("📦 Statut", commande.statut),
          _infoRow("💰 Total TTC", "${commande.prixTotalTTC.toStringAsFixed(2)} €"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text("$label : ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Future<File> _generatePdfAndSave() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Commande #${commande.numeroCommande}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Text('Client : ${commande.clientNom}'),
            pw.Text('Adresse : ${commande.clientAdresse ?? "Non spécifiée"}'),
            pw.Text('Date : ${commande.dateCreation}'),
            pw.Text('Statut : ${commande.statut}'),
            pw.Text('Total TTC : ${commande.prixTotalTTC.toStringAsFixed(2)} €'),
            pw.SizedBox(height: 20),
            pw.Text('Produits commandés :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            ...commande.lignes.map((ligne) =>
                pw.Text("- ${ligne.produitNom} x${ligne.quantite} : ${ligne.total.toStringAsFixed(2)} €")),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/commande_${commande.numeroCommande}.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> _sendEmailWithPdf(File pdfFile, BuildContext context) async {
    const String username = 'tonemail@gmail.com'; // 🔐 Remplace par ton email
    const String password = 'mot_de_passe_application'; // 🔐 Mot de passe application Gmail

    final destinataire = commande.clientEmail ?? 'fallback@client.com';
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Digital Process')
      ..recipients.add(destinataire)
      ..subject = 'Commande #${commande.numeroCommande}'
      ..text = '''
Bonjour ${commande.clientNom},

Merci pour votre commande. Vous trouverez ci-joint le récapitulatif PDF.

Cordialement,
Digital Process.
'''.trim()
      ..attachments = [
        FileAttachment(pdfFile)..location = Location.inline,
      ];

    try {
      final sendReport = await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Email envoyé à $destinataire"), backgroundColor: Colors.green),
      );
    } catch (e) {
      print("Erreur SMTP : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Échec de l'envoi de l'email"), backgroundColor: Colors.red),
      );
    }
  }
}
