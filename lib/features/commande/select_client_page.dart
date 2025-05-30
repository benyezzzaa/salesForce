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
    clientController.fetchClients();
  }

  void _showAddClientDialog(Map<int, int> cart) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Ajouter un client"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nom complet"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Adresse"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Téléphone"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                final newClient = await clientController.addClient(
                  nom: nameController.text,
                  email: emailController.text,
                  adresse: addressController.text,
                  telephone: phoneController.text,
                );

                nameController.clear();
                emailController.clear();
                addressController.clear();
                phoneController.clear();

                if (newClient != null) {
                  await commandeController.createCommande(newClient.id, cart);

                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Commande créée ✅"),
                      content: const Text("La commande a été ajoutée avec succès en attente."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/commandes')),
                          child: const Text("Voir mes commandes"),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final cart = arguments['cart'] as Map<int, int>? ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionner un client"),
        backgroundColor: Colors.indigo.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Ajouter un client',
            onPressed: () => _showAddClientDialog(cart),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Rechercher un client...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (clientController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredClients = clientController.clients
                  .where((c) => c.nom.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();

              if (filteredClients.isEmpty) {
                return const Center(child: Text("Aucun client trouvé"));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return Card(
                    child: ListTile(
                      title: Text(client.nom),
                      subtitle: Text(client.email),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        await commandeController.createCommande(client.id, cart);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Commande créée ✅"),
                            content: const Text("La commande a été ajoutée avec succès en attente."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/commandes')),
                                child: const Text("Voir mes commandes"),
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
