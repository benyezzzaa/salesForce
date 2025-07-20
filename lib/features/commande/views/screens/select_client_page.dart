import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pfe/features/clients/controllers/client_controller.dart';
import 'package:pfe/features/clients/views/add_client_page.dart';
import 'package:pfe/features/commande/controllers/commande_controller.dart';
import 'package:dio/dio.dart'; // Pour charger les catégories

class SelectClientPage extends StatefulWidget {
  const SelectClientPage({super.key});

  @override
  State<SelectClientPage> createState() => _SelectClientPageState();
}

class _SelectClientPageState extends State<SelectClientPage> {
  final ClientController clientController = Get.put(ClientController());
  final CommandeController commandeController = Get.put(CommandeController());
  final searchController = TextEditingController();

  final nameController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final codeFiscaleController = TextEditingController(); // ✅ nouveau champ

  GoogleMapController? mapController;
  LatLng? selectedLocation;
  Set<Marker> markers = {};
  String searchQuery = '';

  // Ajout pour la catégorie
  List<dynamic> categories = [];
  dynamic selectedCategorie;

  @override
  void initState() {
    super.initState();
    if (clientController.clients.isEmpty) {
      clientController.fetchMesClients();
    }
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    print('fetchCategories appelée');
    try {
      final response = await Dio().get('http://localhost:4000/client/categorie-client');
      print('Réponse catégories: ${response.data}');
      setState(() {
        categories = response.data is List ? response.data : response.data['data'];
      });
    } catch (e) {
      print('Erreur lors du chargement des catégories: ${e}');
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
    codeFiscaleController.dispose(); // ✅ dispose
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

  void _showAddClientDialog(BuildContext context) {
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
                _buildTextField(nameController, "Nom", colorScheme),
                const SizedBox(height: 16),
                _buildTextField(prenomController, "Prénom", colorScheme),
                const SizedBox(height: 16),
                _buildTextField(emailController, "Email", colorScheme),
                const SizedBox(height: 16),
                _buildTextField(addressController, "Adresse", colorScheme),
                const SizedBox(height: 16),
                _buildTextField(phoneController, "Téléphone", colorScheme, inputType: TextInputType.phone),
                const SizedBox(height: 16),
                _buildTextField(codeFiscaleController, "Code fiscal (13 chiffres)", colorScheme, inputType: TextInputType.number, maxLength: 13),
                const SizedBox(height: 16),
                // Champ de sélection de catégorie
                DropdownButtonFormField(
                  value: selectedCategorie,
                  items: categories.map<DropdownMenuItem>((cat) {
                    return DropdownMenuItem(
                      value: cat['id'],
                      child: Text(cat['nom']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategorie = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Catégorie de client *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null ? 'La catégorie est requise' : null,
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
                        target: LatLng(36.8065, 10.1815),
                        zoom: 12,
                      ),
                      markers: markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                    ),
                  ),
                ),
                if (selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Position sélectionnée: ${selectedLocation!.latitude.toStringAsFixed(4)}, ${selectedLocation!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(fontSize: 14),
                    ),
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
                if (nameController.text.isNotEmpty &&
                    prenomController.text.isNotEmpty &&
                    codeFiscaleController.text.length == 13 &&
                    RegExp(r'^\d{13}$').hasMatch(codeFiscaleController.text) &&
                    selectedLocation != null &&
                    selectedCategorie != null) { // Ajoute la vérification
                  Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

                  final newClient = await clientController.addClient(
                    nom: nameController.text,
                    prenom: prenomController.text,
                    email: emailController.text,
                    adresse: addressController.text,
                    telephone: phoneController.text,
                    codeFiscale: codeFiscaleController.text,
                    latitude: selectedLocation!.latitude,
                    longitude: selectedLocation!.longitude,
                    categorieId: selectedCategorie, // Passe la catégorie ici
                  );

                  Get.back();

                  if (newClient != null) {
                    nameController.clear();
                    prenomController.clear();
                    emailController.clear();
                    addressController.clear();
                    phoneController.clear();
                    codeFiscaleController.clear();
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
                    'Veuillez remplir tous les champs, saisir un code fiscal valide (13 chiffres) et choisir une catégorie',
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

  Widget _buildTextField(TextEditingController controller, String label, ColorScheme colorScheme,
      {TextInputType inputType = TextInputType.text, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: colorScheme.primary, width: 2)),
      ),
      style: TextStyle(color: colorScheme.onSurface),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('build SelectClientPage');
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionner un client", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Get.to(() => const AddClientPage())?.then((added) {
                if (added == true) {
                  clientController.fetchMesClients();
                }
              });
            },
            tooltip: 'Ajouter un client',
          ),
        ],
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
                        onPressed: () => _showAddClientDialog(context),
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
        onPressed: () {
          Get.to(() => const AddClientPage())?.then((added) {
            if (added == true) {
              clientController.fetchMesClients();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
