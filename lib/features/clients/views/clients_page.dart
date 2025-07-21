import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/clients/controllers/client_controller.dart';
import 'package:pfe/features/clients/views/ClientsMapPage.dart';
import 'package:pfe/features/clients/views/add_client_page.dart';

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
    Get.to(() => const AddClientPage())?.then((added) {
      if (added == true) {
        clientController.fetchMesClients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("👥 Mes Clients", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _openAddClientForm,
            tooltip: 'Ajouter un client',
          ),
          IconButton(
            icon: const Icon(Icons.map),  
            onPressed: () {
              Get.to(() => ClientsMapPage());
            },
            tooltip: 'Voir la carte',
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
                          if (client.categorieNom != null && client.categorieNom!.isNotEmpty)
                            Text('Catégorie :  {client.categorieNom!}', style: TextStyle(color: Colors.indigo)),
                        ],
                      ),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            final labelStyle = TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey[800]);
                            final valueStyle = TextStyle(fontWeight: FontWeight.w400, color: Colors.blueGrey[900]);
                            final initials = (client.prenom.isNotEmpty ? client.prenom[0] : '') + (client.nom.isNotEmpty ? client.nom[0] : '');
                            return Dialog(
                              backgroundColor: Colors.grey[100],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              child: Container(
                                width: 380,
                                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 16,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 36,
                                      backgroundColor: Colors.indigo[100],
                                      child: Text(
                                        initials.toUpperCase(),
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      '${client.prenom} ${client.nom}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.indigo),
                                    ),
                                    const SizedBox(height: 6),
                                    if (client.categorieNom != null && client.categorieNom!.isNotEmpty)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 10),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo[50],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.category, color: Colors.indigo[400], size: 18),
                                            const SizedBox(width: 6),
                                            Text(client.categorieNom!, style: TextStyle(color: Colors.indigo[700], fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    Divider(height: 28, thickness: 1.2),
                                    Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.email, color: Colors.blueGrey[600]),
                                            const SizedBox(width: 10),
                                            Expanded(child: Text(client.email, style: valueStyle)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.phone, color: Colors.blueGrey[600]),
                                            const SizedBox(width: 10),
                                            Expanded(child: Text(client.telephone, style: valueStyle)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(Icons.location_on, color: Colors.blueGrey[600]),
                                            const SizedBox(width: 10),
                                            Expanded(child: Text(client.adresse ?? "Adresse inconnue", style: valueStyle)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Card(
                                      color: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.badge, color: Colors.blueGrey[600]),
                                            const SizedBox(width: 10),
                                            Text('Code fiscal : ', style: labelStyle),
                                            Expanded(child: Text(client.codeFiscale ?? '-', style: valueStyle)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 2,
                                        ),
                                        icon: const Icon(Icons.close),
                                        label: const Text('Fermer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Bouton pour voir la position sur la carte
                          if (client.latitude != null && client.longitude != null)
                            IconButton(
                              icon: Icon(Icons.map, color: colorScheme.primary),
                              onPressed: () {
                                final commercial = clientController.getConnectedCommercial();
                                if (commercial != null) {
                                  Get.toNamed('/positions-map', arguments: {
                                    'commercial': commercial,
                                    'client': client,
                                  });
                                } else {
                                  Get.snackbar(
                                    'Erreur',
                                    'Impossible de récupérer les informations du commercial',
                                    backgroundColor: colorScheme.errorContainer,
                                    colorText: colorScheme.onErrorContainer,
                                  );
                                }
                              },
                              tooltip: 'Voir sur la carte',
                            ),
                          // Switch pour activer/désactiver le client
                          // Switch(
                          //   value: client.isActive,
                          //   activeColor: colorScheme.primary,
                          //   inactiveThumbColor: colorScheme.outline,
                          //   inactiveTrackColor: colorScheme.surfaceVariant,
                          //   onChanged: (value) {
                          //     clientController.toggleClientStatus(client.id, value);
                          //   },
                          // ),
                        ],
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
