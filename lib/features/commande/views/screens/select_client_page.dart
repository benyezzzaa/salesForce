import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pfe/features/clients/controllers/client_controller.dart';
import 'package:pfe/features/clients/views/add_client_page.dart';
import 'package:pfe/features/commande/controllers/commande_controller.dart';

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
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  GoogleMapController? mapController;
  LatLng? selectedLocation;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    if (clientController.clients.isEmpty) {
      clientController.fetchMesClients();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    nameController.dispose();
    prenomController.dispose();
    emailController.dispose();
    addressController.dispose();
    phoneController.dispose();
    mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTap(LatLng location) {
    setState(() {
      selectedLocation = location;
      markers = {
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: location,
          infoWindow: const InfoWindow(title: 'Position sélectionnée'),
        ),
      };
    });
  }

  void _showAddClientDialog(BuildContext context, Map<int, int> cart) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("Ajouter un nouveau client", style: TextStyle(color: colorScheme.onSurface)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Nom",
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: prenomController,
                  decoration: InputDecoration(
                    labelText: "Prénom",
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                const Text(
                  'Sélectionnez la position sur la carte *',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GoogleMap(
                      onMapCreated: _onMapCreated,
                      onTap: _onMapTap,
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(36.8065, 10.1815), // Tunis
                        zoom: 12,
                      ),
                      markers: markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                    ),
                  ),
                ),
                if (selectedLocation != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Position sélectionnée: ${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
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
                if (nameController.text.isNotEmpty && prenomController.text.isNotEmpty && selectedLocation != null) {
                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                    barrierDismissible: false,
                  );

                  final newClient = await clientController.addClient(
                    nom: nameController.text,
                    prenom: prenomController.text,
                    email: emailController.text,
                    adresse: addressController.text,
                    telephone: phoneController.text,
                    latitude: selectedLocation!.latitude,
                    longitude: selectedLocation!.longitude,
                  );

                  Get.back();

                  if (newClient != null) {
                    nameController.clear();
                    prenomController.clear();
                    emailController.clear();
                    addressController.clear();
                    phoneController.clear();
                    setState(() {
                      selectedLocation = null;
                      markers = {};
                    });

                    Navigator.pop(context);
                    commandeController.setSelectedClient(newClient);
                    Get.back(result: true);
                  }
                } else {
                  Get.snackbar(
                    'Erreur',
                    'Veuillez remplir tous les champs obligatoires et sélectionner une position',
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              child: Text("Ajouter", style: TextStyle(color: colorScheme.onPrimary)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionner un client"),
        backgroundColor: colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un client",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (clientController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final filteredClients = clientController.clients.where((client) {
                final fullName = "${client.prenom} ${client.nom}".toLowerCase();
                final searchLower = searchQuery.toLowerCase();
                return fullName.contains(searchLower);
              }).toList();

              if (filteredClients.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Aucun client trouvé"),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _showAddClientDialog(context, {}),
                        child: const Text("Ajouter un nouveau client"),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredClients.length,
                itemBuilder: (context, index) {
                  final client = filteredClients[index];
                  return ListTile(
                    title: Text("${client.prenom} ${client.nom}"),
                    subtitle: Text(client.email),
                    onTap: () {
                      commandeController.setSelectedClient(client);
                      Get.back(result: true);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){ Get.to(() => const AddClientPage())?.then((added) {
      if (added == true) {
        clientController.fetchMesClients();
      }
    });},
        //  => _showAddClientDialog(context, {}),
        child: const Icon(Icons.add),
      ),
    );
  }
}
