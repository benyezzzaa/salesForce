import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animations/animations.dart';
import 'package:pfe/features/commande/controllers/commande_controller.dart';
import '../../models/commande_model.dart';
import 'commande_details_page.dart';

class CommercialOrdersPage extends StatefulWidget {
  const CommercialOrdersPage({super.key});

  @override
  State<CommercialOrdersPage> createState() => _CommercialOrdersPageState();
}

class _CommercialOrdersPageState extends State<CommercialOrdersPage>
    with SingleTickerProviderStateMixin {
  final CommandeController controller = Get.put(CommandeController());
  String searchQuery = '';
  String sortMode = 'date';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
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

  Color _getStatusColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return colorScheme.secondaryContainer;
      case 'validee':
        return colorScheme.primaryContainer;
      case 'livree':
        return colorScheme.tertiaryContainer;
      case 'annulee':
        return colorScheme.errorContainer;
      default:
        return colorScheme.surfaceVariant;
    }
  }

  Color _getStatusTextColor(String status, ColorScheme colorScheme) {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return colorScheme.onSecondaryContainer;
      case 'validee':
        return colorScheme.onPrimaryContainer;
      case 'livree':
        return colorScheme.onTertiaryContainer;
      case 'annulee':
        return colorScheme.onErrorContainer;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'validee':
        return 'Validée';
      case 'livree':
        return 'Livrée';
      case 'annulee':
        return 'Annulée';
      default:
        return status;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
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
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
                onPressed: () {
                  Get.offAllNamed('/home');
                },
              ),
              title: Text(
                'Mes Commandes',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) => setState(() => sortMode = value),
                  icon: Icon(Icons.sort, color: colorScheme.onPrimary),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'date',
                      child: Text('Trier par date',
                          style: TextStyle(color: colorScheme.onSurface)),
                    ),
                    PopupMenuItem(
                      value: 'montant',
                      child: Text('Trier par montant',
                          style: TextStyle(color: colorScheme.onSurface)),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline,
                      size: 28, color: colorScheme.onPrimary),
                  tooltip: 'Nouvelle commande',
                  onPressed: () {
                    Get.toNamed('/select-products');
                  },
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
                  prefixIcon:
                      Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                ),
                style: TextStyle(color: colorScheme.onSurface),
                onChanged: (val) => setState(() => searchQuery = val),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: colorScheme.primary));
                }

                var filtered = controller.commandes
                    .where((c) =>
                        (c.numeroCommande
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()) ||
                            c.clientNom
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase())))
                    .toList();

                if (sortMode == 'date') {
                  filtered.sort(
                      (a, b) => b.dateCreation.compareTo(a.dateCreation));
                } else if (sortMode == 'montant') {
                  filtered
                      .sort((a, b) => b.prixTotalTTC.compareTo(a.prixTotalTTC));
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.isEmpty 
                              ? "Aucune commande trouvée"
                              : "Aucune commande correspondant à '$searchQuery'",
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        if (searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            "Créez votre première commande !",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.fetchCommandes();
                    },
                    color: colorScheme.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final cmd = filtered[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: colorScheme.surface,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cmd.numeroCommande,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurface),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(cmd.statut, colorScheme),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getStatusText(cmd.statut),
                                    style: TextStyle(
                                      color: _getStatusTextColor(cmd.statut, colorScheme),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        cmd.clientNom,
                                        style: TextStyle(
                                            color: colorScheme.onSurfaceVariant),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(cmd.dateCreation),
                                      style: TextStyle(
                                          color: colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                                if (cmd.clientTelephone != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_outlined,
                                        size: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        cmd.clientTelephone!,
                                        style: TextStyle(
                                            color: colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.shopping_bag_outlined,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${cmd.lignes.length} produit${cmd.lignes.length > 1 ? 's' : ''}",
                                      style: TextStyle(
                                          color: colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${cmd.prixTotalTTC.toStringAsFixed(2)} DT",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: colorScheme.primary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "HT: ${cmd.prixHorsTaxe.toStringAsFixed(2)} DT",
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CommandeDetailsPage(commande: cmd),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
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
