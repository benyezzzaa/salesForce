import 'package:flutter/material.dart';
// TODO: Importer les modèles Client, Visite, etc.
// TODO: Importer le widget de carte (ex: google_maps_flutter)
import 'package:get/get.dart';
import 'package:pfe/features/visite/services/visite_service.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'all_visites_map_page.dart';
import 'package:pfe/features/clients/models/client_model.dart';
import 'package:pfe/features/visite/models/raison_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pfe/core/utils/app_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CreateVisiteMultiPage extends StatefulWidget {
  @override
  _CreateVisiteMultiPageState createState() => _CreateVisiteMultiPageState();
}

class _CreateVisiteMultiPageState extends State<CreateVisiteMultiPage> {
  DateTime? selectedDate;
  ClientModel? selectedClient;
  RaisonModel? selectedRaison;

  List<ClientModel> clients = [];
  List<RaisonModel> raisons = [];
  bool isLoading = false;
  bool isLoadingLists = true;
  String? errorMsg;

  // Liste temporaire des visites à ajouter
  List<Map<String, dynamic>> visites = [];

  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    _loadClientsAndRaisons();
    _determinePosition();
  }

  Future<void> _loadClientsAndRaisons() async {
    setState(() { isLoadingLists = true; errorMsg = null; });
    final token = StorageService.getToken();
    if (token == null) {
      setState(() { errorMsg = 'Token non trouvé.'; isLoadingLists = false; });
      return;
    }
    final service = VisiteService();
    try {
      // Récupérer les clients du commercial connecté
      final response = await http.get(
        Uri.parse('${AppApi.baseUrl}/client/mes-clients'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        clients = data.map((json) => ClientModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur lors du chargement des clients');
      }
      // Récupérer les raisons actives
      raisons = await service.getRaisons(token);
    } catch (e) {
      setState(() { errorMsg = e.toString(); });
    } finally {
      setState(() { isLoadingLists = false; });
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    try {
      currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
      _updateMarkers();
    } catch (e) {}
  }

  void _updateMarkers() {
    markers.clear();
    polylines.clear();
    // Marqueur position commerciale
    if (currentPosition != null) {
      markers.add(Marker(
        markerId: MarkerId('commercial'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        infoWindow: InfoWindow(title: 'Votre position'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }
    // Marqueurs clients
    for (int i = 0; i < visites.length; i++) {
      final client = visites[i]['client'] as ClientModel;
      if (client.latitude != null && client.longitude != null) {
        markers.add(Marker(
          markerId: MarkerId('client_${client.id}_$i'),
          position: LatLng(client.latitude!, client.longitude!),
          infoWindow: InfoWindow(title: client.fullName),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
        // Polyline entre commercial et client
        if (currentPosition != null) {
          polylines.add(Polyline(
            polylineId: PolylineId('route_$i'),
            points: [
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
              LatLng(client.latitude!, client.longitude!),
            ],
            color: Colors.blueAccent,
            width: 4,
          ));
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter des visites', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulaire d'ajout de visite
            _buildVisiteForm(),
            SizedBox(height: 16),
            // Liste des visites ajoutées
            Expanded(child: _buildVisiteList()),
            SizedBox(height: 16),
            // Carte avec positions
            SizedBox(
              height: 200,
              child: _buildMap(),
            ),
            SizedBox(height: 16),
            // Bouton de validation
            ElevatedButton(
              onPressed: visites.isNotEmpty && !isLoading ? _onValider : null,
              child: isLoading ? CircularProgressIndicator() : Text('Valider toutes les visites'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisiteForm() {
    if (isLoadingLists) {
      return Center(child: CircularProgressIndicator());
    }
    if (errorMsg != null) {
      return Center(child: Text(errorMsg!, style: TextStyle(color: Colors.red)));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur de date
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      selectedDate == null
                          ? 'Choisir une date'
                          : selectedDate!.toLocal().toString().split(' ')[0],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.calendar_today),
                ],
              ),
              onTap: _pickDate,
            ),
            // Dropdown client
            DropdownButtonFormField<ClientModel>(
              value: selectedClient,
              items: clients.map((client) => DropdownMenuItem(
                value: client,
                child: Text(client.fullName),
              )).toList(),
              onChanged: (client) => setState(() => selectedClient = client),
              decoration: InputDecoration(
                labelText: 'Client',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            // Dropdown raison
            DropdownButtonFormField<RaisonModel>(
              value: selectedRaison,
              items: raisons.map((raison) => DropdownMenuItem(
                value: raison,
                child: Text(raison.nom),
              )).toList(),
              onChanged: (raison) => setState(() => selectedRaison = raison),
              decoration: InputDecoration(
                labelText: 'Raison',
                border: OutlineInputBorder(),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.add_circle, color: Colors.green, size: 32),
                onPressed: _onAddVisite,
                tooltip: 'Ajouter à la liste',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisiteList() {
    if (visites.isEmpty) {
      return Center(child: Text('Aucune visite ajoutée.'));
    }
    return ListView.builder(
      itemCount: visites.length,
      itemBuilder: (context, index) {
        final visite = visites[index];
        return ListTile(
          leading: Icon(Icons.location_on),
          title: Text('Client:  ${visite['client']}'),
          subtitle: Text('Raison: ${visite['raison']}'),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: () => _onRemoveVisite(index),
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    if (currentPosition == null) {
      return Center(child: Text('Position du commercial non disponible'));
    }
    return GoogleMap(
      onMapCreated: (controller) => mapController = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        zoom: 12.0,
      ),
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
    );
  }

  void _onAddVisite() {
    if (selectedDate != null && selectedClient != null && selectedRaison != null) {
      setState(() {
        visites.add({
          'date': selectedDate,
          'client': selectedClient!,
          'raison': selectedRaison!,
        });
        // Réinitialiser le formulaire sauf la date
        selectedClient = null;
        selectedRaison = null;
      });
      _updateMarkers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
    }
  }

  void _onRemoveVisite(int index) {
    setState(() {
      visites.removeAt(index);
    });
    _updateMarkers();
  }

  void _onValider() async {
    if (visites.isEmpty) return;
    setState(() { isLoading = true; });
    final token = StorageService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token non trouvé. Veuillez vous reconnecter.')),
      );
      setState(() { isLoading = false; });
      return;
    }
    final service = VisiteService();
    int successCount = 0;
    String? errorMsg;
    for (final v in visites) {
      final res = await service.createVisite(
        token: token,
        date: v['date'],
        clientId: v['client'].id,
        raisonId: v['raison'].id,
      );
      if (res.isSuccess) {
        successCount++;
      } else {
        errorMsg = res.error;
        break;
      }
    }
    setState(() { isLoading = false; });
    if (successCount == visites.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toutes les visites ont été enregistrées !')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AllVisitesMapPage(initialDate: visites.first['date']),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement : ${errorMsg ?? "Erreur inconnue"}')),
      );
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> _pickClient() async {
    // TODO: Afficher un sélecteur de client (dialogue ou nouvelle page)
  }

  Future<void> _pickRaison() async {
    // TODO: Afficher un sélecteur de raison (dialogue ou nouvelle page)
  }
} 