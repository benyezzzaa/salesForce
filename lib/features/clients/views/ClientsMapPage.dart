import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pfe/features/clients/controllers/client_controller.dart';

class ClientsMapPage extends StatefulWidget {
  const ClientsMapPage({super.key});

  @override
  State<ClientsMapPage> createState() => _ClientsMapPageState();
}

class _ClientsMapPageState extends State<ClientsMapPage> {
  final ClientController controller = Get.find<ClientController>();
  GoogleMapController? mapController;
  Position? currentPosition;
  Set<Marker> markers = {};
  String? error;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _addClientMarkers();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        error = 'Les services de localisation sont désactivés.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          error = 'La permission de localisation est refusée.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        error = 'La permission de localisation est refusée de manière permanente.';
      });
      return;
    }

    try {
      currentPosition = await Geolocator.getCurrentPosition();
      setState(() {
        markers.add(Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Votre Position'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors de l\'obtention de la position: ${e.toString()}';
      });
    }
  }

  void _addClientMarkers() {
    if (controller.clients.isEmpty) {
      setState(() {
        error = 'Aucun client à afficher sur la carte.';
      });
      return;
    }

    final clientsWithCoords = controller.clients.where((client) => 
      client.latitude != null && client.longitude != null
    ).length;

    if (clientsWithCoords == 0) {
      setState(() {
        error = 'Aucun client n\'a de coordonnées GPS valides.';
      });
      return;
    }

    final clientMarkers = controller.clients.map((client) {
      if (client.latitude == null || client.longitude == null) return null;
      
      return Marker(
        markerId: MarkerId(client.id.toString()),
        position: LatLng(client.latitude!, client.longitude!),
        infoWindow: InfoWindow(
          title: client.fullName,
          snippet: client.adresse,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }).whereType<Marker>().toSet();

    setState(() {
      markers.addAll(clientMarkers);
      if (clientsWithCoords < controller.clients.length) {
        error = '${controller.clients.length - clientsWithCoords} clients n\'ont pas de coordonnées GPS.';
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(currentPosition!.latitude, currentPosition!.longitude),
          12.0,
        ),
      );
    } else if (this.controller.clients.isNotEmpty) {
      final firstClient = this.controller.clients.firstWhere(
        (client) => client.latitude != null && client.longitude != null,
        orElse: () => this.controller.clients.first,
      );
      
      if (firstClient.latitude != null && firstClient.longitude != null) {
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(firstClient.latitude!, firstClient.longitude!),
            12.0,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carte des clients'),
          backgroundColor: Colors.indigo.shade600,
        ),
        body: Column(
          children: [
            Expanded(
              child: Center(
                child: Text('Erreur: $error', 
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (controller.clients.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '${controller.clients.length} clients au total\n'
                  '${controller.clients.where((c) => c.latitude != null && c.longitude != null).length} clients sur la carte',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    }

    if (controller.clients.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carte des clients'),
          backgroundColor: Colors.indigo.shade600,
        ),
        body: const Center(
          child: Text('Aucun client à afficher sur la carte'),
        ),
      );
    }

    final clientsWithCoords = controller.clients.where((c) => 
      c.latitude != null && c.longitude != null
    ).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carte des clients'),
        backgroundColor: Colors.indigo.shade600,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentPosition != null
                  ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
                  : LatLng(
                      controller.clients.first.latitude ?? 0,
                      controller.clients.first.longitude ?? 0,
                    ),
              zoom: 12.0,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            mapToolbarEnabled: true,
          ),
          if (clientsWithCoords < controller.clients.length)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${controller.clients.length - clientsWithCoords} clients n\'ont pas de coordonnées GPS',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
