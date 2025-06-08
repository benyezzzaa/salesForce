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
    final colorScheme = Theme.of(context).colorScheme; // Get color scheme

    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Clients", style: TextStyle(color: colorScheme.onPrimary)), // Use onPrimary for title color
        backgroundColor: colorScheme.primary, // Use primary color for AppBar background
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Use onPrimary for back button color
        elevation: 2, // Add a slight elevation
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0), // Increased padding
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un client...",
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant for icon
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Consistent border radius
                  borderSide: BorderSide.none, // No border line
                ),
                filled: true, // Add fill color
                fillColor: colorScheme.surfaceContainerLow, // Use a subtle surface color
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12), // Adjust padding
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (clientController.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Use primary color for indicator
              }

              final clients = clientController.clients
                  .where((c) => c.nom.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();

              if (clients.isEmpty) {
                return Center(child: Text("Aucun client trouvé.", style: TextStyle(color: colorScheme.onSurfaceVariant))); // Use onSurfaceVariant for empty text
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjusted padding
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6), // Adjusted margin
                    elevation: 4, // Increased elevation for shadow
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
                    color: colorScheme.surface, // Use surface color for card background
                    child: ListTile(
                      leading: CircleAvatar(
                         backgroundColor: colorScheme.primaryContainer, // Use primaryContainer for avatar background
                         child: Icon(Icons.person, color: colorScheme.onPrimaryContainer), // Use onPrimaryContainer for avatar icon
                      ),
                      title: Text(client.nom, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)), // Use onSurface for title
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.email, style: TextStyle(color: colorScheme.onSurfaceVariant)), // Use onSurfaceVariant for subtitle
                          Text(client.adresse ?? 'Adresse inconnue', style: TextStyle(color: colorScheme.onSurfaceVariant)), // Use onSurfaceVariant for subtitle
                        ],
                      ),
                      trailing: Switch(
                        value: client.isActive,
                         activeColor: colorScheme.primary, // Use primary color for active switch
                         inactiveThumbColor: colorScheme.outline, // Use outline color for inactive thumb
                         inactiveTrackColor: colorScheme.surfaceVariant, // Use surfaceVariant for inactive track
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
