import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/clients/controllers/client_controller.dart';
import 'package:pfe/features/clients/views/ClientsMapPage.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final ClientController clientController = Get.put(ClientController());
  final _formKey = GlobalKey<FormState>();
final nomController = TextEditingController();
final prenomController = TextEditingController(); // AJOUTÉ
final emailController = TextEditingController();
final telephoneController = TextEditingController();
final adresseController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    clientController.fetchMesClients();
  }
 @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose(); // AJOUTÉ
    emailController.dispose();
    telephoneController.dispose();
    adresseController.dispose();
    super.dispose();
  }
 void _openAddClientForm() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 16,
          children: [
            Text("🧾 Ajouter un Client", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: nomController,
              decoration: const InputDecoration(labelText: 'Nom *'),
              validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
            ),
            TextFormField(
              controller: prenomController,
              decoration: const InputDecoration(labelText: 'Prénom *'),
              validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: telephoneController,
              decoration: const InputDecoration(labelText: 'Téléphone'),
            ),
            TextFormField(
              controller: adresseController,
              decoration: const InputDecoration(labelText: 'Adresse'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final success = await clientController.addClient(
                    nom: nomController.text,
                    prenom: prenomController.text,
                    email: emailController.text,
                    telephone: telephoneController.text,
                    adresse: adresseController.text,
                  );

                  if (success != null) {
                    nomController.clear();
                    prenomController.clear();
                    emailController.clear();
                    telephoneController.clear();
                    adresseController.clear();

                    Get.back(); // Fermer le BottomSheet

                    // Afficher la boîte de dialogue
                    showDialog(
                      context: context,
                      builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        return AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: colorScheme.surface,
                          title: Text("✅ Client ajouté", style: TextStyle(color: colorScheme.onSurface)),
                          content: Text("Le client a été ajouté avec succès.", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text("Fermer", style: TextStyle(color: colorScheme.primary)),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: const Text("✅ Ajouter le client"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("👥 Mes Clients", style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        actions: [
  IconButton(
    icon: const Icon(Icons.map),  
    onPressed: () {
      Get.to(() => ClientsMapPage());
    },
  ),
],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "🔍 Rechercher un client...",
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              ),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (clientController.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: colorScheme.primary));
              }

              final clients = clientController.clients
                  .where((c) => c.nom.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();

              if (clients.isEmpty) {
                return Center(child: Text("Aucun client trouvé.", style: TextStyle(color: colorScheme.onSurfaceVariant)));
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: clients.length,
                itemBuilder: (context, index) {
                  final client = clients[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
                      ),
                      title: Text(client.nom, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(client.email),
                          Text(client.adresse ?? 'Adresse inconnue'),
                        ],
                      ),
                      trailing: Switch(
                        value: client.isActive,
                        activeColor: colorScheme.primary,
                        inactiveThumbColor: colorScheme.outline,
                        inactiveTrackColor: colorScheme.surfaceVariant,
                        onChanged: (value) {
                          clientController.toggleClientStatus(client.id, value);
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddClientForm,
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
