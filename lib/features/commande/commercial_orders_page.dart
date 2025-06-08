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
    if (controller.commandes.isEmpty) {
      controller.fetchCommandes();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        color: colorScheme.background,
        child: Column(
          children: [
            AppBar(
              backgroundColor: colorScheme.primary,
              title: Text('Mes Commandes', style: TextStyle(color: colorScheme.onPrimary)),
              actions: [
                IconButton(
                  icon: Icon(
                    showOnlyValidated ? Icons.filter_alt_off : Icons.filter_alt,
                    color: colorScheme.onPrimary,
                  ),
                  tooltip: showOnlyValidated ? 'Afficher tout' : 'Filtrer : Validées',
                  onPressed: () => setState(() => showOnlyValidated = !showOnlyValidated),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => setState(() => sortMode = value),
                  icon: Icon(Icons.sort, color: colorScheme.onPrimary),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'date', child: Text('Trier par date', style: TextStyle(color: colorScheme.onSurface))),
                    PopupMenuItem(value: 'montant', child: Text('Trier par montant', style: TextStyle(color: colorScheme.onSurface))),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 28, color: colorScheme.onPrimary),
                  tooltip: 'Nouvelle commande',
                  onPressed: () => Get.toNamed('/select-products'),
                )
              ],
              iconTheme: IconThemeData(color: colorScheme.onPrimary),
              elevation: 2,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher une commande ou un client...',
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (val) => setState(() => searchQuery = val),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator(color: colorScheme.primary));
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
                  return Center(child: Text("Aucune commande trouvée", style: TextStyle(color: colorScheme.onSurfaceVariant)));
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final cmd = filtered[index];
                      final isValid = cmd.statut == 'validée';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: colorScheme.surface,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            "Commande ${cmd.numeroCommande}",
                            style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Client : ${cmd.clientNom}", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                              Text("Date : ${cmd.dateCreation}", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isValid ? colorScheme.tertiaryContainer : colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  isValid ? 'Validée' : 'En attente',
                                  style: TextStyle(color: isValid ? colorScheme.onTertiaryContainer : colorScheme.onSecondaryContainer, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text("${cmd.prixTotalTTC.toStringAsFixed(2)} DT",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
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
