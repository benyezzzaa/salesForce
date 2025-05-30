// 📁 lib/features/clients/pages/clients_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/commande/controllers/client_controller.dart';
import '../../../data/models/client_model.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final ClientController clientController = Get.put(ClientController());
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    clientController.fetchClients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Clients"),
        backgroundColor: Colors.indigo.shade400,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un client...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (clientController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final clients = clientController.clients
                  .where((c) => c.nom.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();

              if (clients.isEmpty) {
                return const Center(child: Text("Aucun client trouvé."));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      title: Text(client.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.email),
                          Text(client.adresse ?? 'Adresse inconnue'),
                        ],
                      ),
                      trailing: Switch(
                        value: client.isActive,
                        onChanged: (value) => clientController.toggleClientStatus(client.id, value),
                      ),
                      onTap: () {
                        // Ajouter une action d'édition future si besoin
                      },
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
