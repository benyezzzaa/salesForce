import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/commande/controllers/client_controller.dart';
import 'package:pfe/features/commande/controllers/commande_controller.dart';
import '../../../data/models/client_model.dart';

class SelectClientPage extends StatefulWidget {
  const SelectClientPage({super.key});

  @override
  State<SelectClientPage> createState() => _SelectClientPageState();
}

class _SelectClientPageState extends State<SelectClientPage> {
  final ClientController clientController = Get.put(ClientController());
  final CommandeController commandeController = Get.put(CommandeController());
  final searchController = TextEditingController();
  String searchQuery = '';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (clientController.clients.isEmpty) {
      clientController.fetchClients();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _showAddClientDialog(BuildContext context, Map<int, int> cart) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        title: Text("Ajouter un client", style: TextStyle(color: colorScheme.onSurface)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Nom complet",
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: "Adresse",
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Téléphone",
                  labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                ),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: TextStyle(color: colorScheme.primary)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                Get.dialog(
                  const Center(child: CircularProgressIndicator()),
                  barrierDismissible: false,
                );

                final newClient = await clientController.addClient(
                  nom: nameController.text,
                  email: emailController.text,
                  adresse: addressController.text,
                  telephone: phoneController.text,
                );

                Get.back();

                nameController.clear();
                emailController.clear();
                addressController.clear();
                phoneController.clear();

                if (newClient != null) {
                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                    barrierDismissible: false,
                  );

                  await commandeController.createCommande(newClient.id, cart);

                  Get.back();

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      backgroundColor: colorScheme.surface,
                      title: Text("Commande créée ✅", style: TextStyle(color: colorScheme.onSurface)),
                      content: Text("La commande a été ajoutée avec succès en attente.", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      actions: [
                        TextButton(
                          onPressed: () => Get.until((route) => Get.currentRoute == '/commandes'),
                          child: Text("Voir mes commandes", style: TextStyle(color: colorScheme.primary)),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: Text("Ajouter", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};
    final cart = arguments['cart'] as Map<int, int>? ?? {};

    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Panier vide',
          'Veuillez ajouter des produits avant de sélectionner un client.',
          backgroundColor: colorScheme.error,
          colorText: colorScheme.onError,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.back();
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text("Sélectionner un client", style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: colorScheme.onPrimary),
            tooltip: 'Ajouter un client',
            onPressed: () => _showAddClientDialog(context, cart),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                hintText: "Rechercher un client...",
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              ),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (clientController.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary));
              }

              final filteredClients = clientController.clients
                  .where((c) => c.nom.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();

              if (filteredClients.isEmpty) {
                if (searchQuery.isNotEmpty) {
                  return Center(child: Text("Aucun client trouvé pour cette recherche.", style: TextStyle(color: colorScheme.onSurfaceVariant)));
                } else {
                  return Center(child: Text("Aucun client disponible.", style: TextStyle(color: colorScheme.onSurfaceVariant)));
                }
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: colorScheme.surface,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
                      ),
                      title: Text(client.nom, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.email, style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          Text(client.adresse ?? 'Adresse inconnue', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        ],
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, size: 18, color: colorScheme.onSurfaceVariant),
                      onTap: () async {
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

                        await commandeController.createCommande(client.id, cart);

                        Get.back();

                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            backgroundColor: colorScheme.surface,
                            title: Text("Commande créée ✅", style: TextStyle(color: colorScheme.onSurface)),
                            content: Text("La commande a été ajoutée avec succès en attente.", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                            actions: [
                              TextButton(
                                onPressed: () => Get.until((route) => Get.currentRoute == '/commandes'),
                                child: Text("Voir mes commandes", style: TextStyle(color: colorScheme.primary)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
