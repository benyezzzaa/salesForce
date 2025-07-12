import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pfe/features/clients/controllers/client_controller.dart';
import 'package:pfe/features/clients/controllers/add_client_controller.dart';
import 'package:pfe/features/clients/widgets/fiscal_textfield_with_camera.dart';

class AddClientPage extends StatefulWidget {
  const AddClientPage({super.key});

  @override
  State<AddClientPage> createState() => _AddClientPageState();
}

class _AddClientPageState extends State<AddClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();

  final ClientController clientController = Get.find<ClientController>();
  final AddClientController addClientController = Get.put(AddClientController());

  GoogleMapController? mapController;
  LatLng? selectedLocation;
  Set<Marker> markers = {};

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    mapController?.dispose();
    addClientController.dispose();
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

  Future<void> _submitForm() async {
    print('🔍 Début de la validation du formulaire');
    
    // Valider tous les champs du formulaire
    if (!_formKey.currentState!.validate()) {
      print('❌ Validation du formulaire échouée');
      Get.snackbar(
        'Erreur de validation',
        'Veuillez remplir tous les champs obligatoires correctement',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Validation supplémentaire des champs
    final nom = _nomController.text.trim();
    final prenom = _prenomController.text.trim();
    final email = _emailController.text.trim();
    final telephone = _telephoneController.text.trim();
    final adresse = _adresseController.text.trim();
    final fiscalCode = addClientController.fiscalNumberController.text.trim();

    print('🔍 Validation des champs:');
    print('  Nom: "$nom" (longueur: ${nom.length})');
    print('  Prénom: "$prenom" (longueur: ${prenom.length})');
    print('  Email: "$email" (longueur: ${email.length})');
    print('  Téléphone: "$telephone" (longueur: ${telephone.length})');
    print('  Adresse: "$adresse" (longueur: ${adresse.length})');
    print('  Code Fiscal: "$fiscalCode" (longueur: ${fiscalCode.length})');

    // Vérifications supplémentaires
    if (nom.length < 2) {
      Get.snackbar('Erreur', 'Le nom doit contenir au moins 2 caractères', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (prenom.length < 2) {
      Get.snackbar('Erreur', 'Le prénom doit contenir au moins 2 caractères', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (email.length < 5 || !email.contains('@')) {
      Get.snackbar('Erreur', 'Veuillez saisir un email valide', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Validation et formatage du téléphone français
    final cleanTelephone = telephone.replaceAll(RegExp(r'[^\d+]'), '');
    if (!RegExp(r'^(\+33|0|33)[1-9](\d{8})$').hasMatch(cleanTelephone)) {
      Get.snackbar(
        'Erreur', 
        'Le numéro de téléphone doit être au format français valide (ex: 0612345678, +33612345678 ou 33612345678)', 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }
    
    // Convertir en format international si nécessaire
    String formattedTelephone = cleanTelephone;
    if (cleanTelephone.startsWith('0') && cleanTelephone.length == 10) {
      formattedTelephone = '+33${cleanTelephone.substring(1)}';
    } else if (cleanTelephone.startsWith('33') && cleanTelephone.length == 11) {
      formattedTelephone = '+$cleanTelephone';
    } else if (cleanTelephone.startsWith('+33') && cleanTelephone.length == 12) {
      // Déjà au bon format
      formattedTelephone = cleanTelephone;
    }
    
    print('📞 Téléphone formaté: $formattedTelephone');

    if (adresse.length < 5) {
      Get.snackbar('Erreur', 'L\'adresse doit contenir au moins 5 caractères', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Vérifier que le code fiscal est valide
    if (fiscalCode.isEmpty || !RegExp(r'^\d{13}$').hasMatch(fiscalCode)) {
      Get.snackbar(
        'Erreur',
        'Le code fiscal doit contenir exactement 13 chiffres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    if (selectedLocation == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner une position sur la carte',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    print('✅ Validation réussie, envoi au serveur...');

    try {
      final client = await clientController.addClient(
        nom: _nomController.text,
        prenom: _prenomController.text,
        email: _emailController.text,
        adresse: _adresseController.text,
        telephone: formattedTelephone,
        latitude: selectedLocation!.latitude,
        longitude: selectedLocation!.longitude,
        codeFiscale: addClientController.fiscalNumberController.text,
      );

      if (client != null) {
        Get.back(result: true);
        Get.snackbar(
          'Succès',
          'Client ajouté avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter le client: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un client', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _submitForm,
            tooltip: 'Sauvegarder le client',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Le nom est requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prenomController,
              decoration: const InputDecoration(
                labelText: 'Prénom *',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Le prénom est requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email *',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'L\'email est requis';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Veuillez saisir un email valide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telephoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone * (format: 0612345678)',
                border: OutlineInputBorder(),
                hintText: 'Ex: 0612345678 ou +33612345678',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Le téléphone est requis';
                }
                // Nettoyer le numéro
                final cleanNumber = value!.replaceAll(RegExp(r'[^\d+]'), '');
                
                // Validation plus permissive pour formats français
                if (!RegExp(r'^(\+33|0|33)[1-9](\d{8})$').hasMatch(cleanNumber)) {
                  return 'Format invalide. Utilisez: 0612345678, +33612345678 ou 33612345678';
                }
                return null;
              },
                              onChanged: (value) {
                  // Formatage automatique plus flexible
                  final cleanNumber = value.replaceAll(RegExp(r'[^\d+]'), '');
                  if (cleanNumber.length > 0) {
                    String formatted = cleanNumber;
                    if (cleanNumber.startsWith('0') && cleanNumber.length == 10) {
                      formatted = '+33${cleanNumber.substring(1)}';
                    } else if (cleanNumber.startsWith('33') && cleanNumber.length == 11) {
                      formatted = '+$cleanNumber';
                    } else if (cleanNumber.startsWith('+33') && cleanNumber.length == 12) {
                      // Déjà au bon format
                      formatted = cleanNumber;
                    }
                    if (formatted != value) {
                      _telephoneController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _adresseController,
              decoration: const InputDecoration(
                labelText: 'Adresse *',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) => value?.isEmpty ?? true ? 'L\'adresse est requise' : null,
            ),
            const SizedBox(height: 16),

            /// ✅ OCR Fiscal Scanner
            FiscalTextFieldWithCamera(controller: addClientController),

            const SizedBox(height: 16),
            const Text(
              'Sélectionnez la position sur la carte *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Ajouter le client',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
