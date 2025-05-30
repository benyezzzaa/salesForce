// 📁 lib/features/commande/commercial_orders_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animations/animations.dart';
import 'package:pfe/features/commande/controllers/commande_controller.dart';
import '../../../data/models/commande_model.dart';
import 'commande_details_page.dart';

class CommercialOrdersPage extends StatefulWidget {
  const CommercialOrdersPage({super.key});

  @override
  State<CommercialOrdersPage> createState() => _CommercialOrdersPageState();
}

class _CommercialOrdersPageState extends State<CommercialOrdersPage>
    with SingleTickerProviderStateMixin {
  final CommandeController controller = Get.put(CommandeController());
  bool showOnlyValidated = false;
  String searchQuery = '';
  String sortMode = 'date';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
          : [const Color(0xFFF0F4FF), const Color(0xFFE0E7FF)],
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.indigo.shade400,
              title: const Text('Mes Commandes', style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  icon: Icon(
                    showOnlyValidated ? Icons.filter_alt_off : Icons.filter_alt,
                    color: Colors.white,
                  ),
                  tooltip: showOnlyValidated ? 'Afficher tout' : 'Filtrer : Validées',
                  onPressed: () => setState(() => showOnlyValidated = !showOnlyValidated),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => setState(() => sortMode = value),
                  icon: const Icon(Icons.sort, color: Colors.white),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'date', child: Text('Trier par date')),
                    const PopupMenuItem(value: 'montant', child: Text('Trier par montant')),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 28),
                  tooltip: 'Nouvelle commande',
                  onPressed: () => Get.toNamed('/select-products'),
                )
              ],
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une commande ou un client...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? Colors.white10 : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => searchQuery = val),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                var filtered = (showOnlyValidated
                        ? controller.commandes.where((c) => c.statut == 'validée')
                        : controller.commandes)
                    .where((c) =>
                        c.numeroCommande.toLowerCase().contains(searchQuery.toLowerCase()) ||
                        c.clientNom.toLowerCase().contains(searchQuery.toLowerCase()))
                    .toList();

                if (sortMode == 'date') {
                  filtered.sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
                } else if (sortMode == 'montant') {
                  filtered.sort((a, b) => b.prixTotalTTC.compareTo(a.prixTotalTTC));
                }

                if (filtered.isEmpty) {
                  return const Center(child: Text("Aucune commande trouvée"));
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final cmd = filtered[index];
                      final isValid = cmd.statut == 'validée';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.indigo.shade900.withOpacity(0.2) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            "Commande ${cmd.numeroCommande}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Client : ${cmd.clientNom}"),
                              Text("Date : ${cmd.dateCreation}"),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isValid ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isValid ? 'Validée' : 'En attente',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("${cmd.prixTotalTTC.toStringAsFixed(2)} DT",
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommandeDetailsPage(commande: cmd),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
