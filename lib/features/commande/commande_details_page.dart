import 'package:flutter/material.dart';
import '../../../data/models/commande_model.dart';

class CommandeDetailsPage extends StatelessWidget {
  final CommandeModel commande;
  const CommandeDetailsPage({super.key, required this.commande});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF1F5F9);
    final tileColor = isDark ? Colors.indigo.shade900.withOpacity(0.2) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade500,
        elevation: 0,
        title: Text('Commande #${commande.numeroCommande}', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
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
                    _infoRow("💰 Total TTC", "${commande.prixTotalTTC.toStringAsFixed(2)} DT"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "🛒 Produits commandés :",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                        color: tileColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.indigo.shade100),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ligne.produit, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text("Quantité : ${ligne.quantite}", style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          Text("${ligne.prix.toStringAsFixed(2)} DT", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))
                        ],
                      ),
                    );
                  },
                )
            ],
          ),
        ),
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
}
