import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/circuit_model.dart';

class MapCircuitPage extends StatefulWidget {
  const MapCircuitPage({super.key});

  @override
  State<MapCircuitPage> createState() => _MapCircuitPageState();
}

class _MapCircuitPageState extends State<MapCircuitPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Position? currentPosition;
  String? _error;

  // Récupérer les arguments de manière sûre
  final CircuitModel? circuit = Get.arguments as CircuitModel?; 

  @override
  void initState() {
    super.initState();
    // Vérifier la présence du circuit et des clients avant de tenter d'ajouter le marqueur et d'obtenir la position
    if (circuit == null || circuit!.clients.isEmpty) {
       setState(() {
         _error = 'Aucune donnée client valide trouvée pour afficher le circuit.';
       });
    } else {
      _determinePosition(); // Obtenir la position de l'utilisateur
      _addClientMarker(); // Ajouter le marqueur du client
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _error = 'Les services de localisation sont désactivés.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _error = 'La permission de localisation est refusée.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _error = 'La permission de localisation est refusée de manière permanente.';
      });
      return;
    }

    try {
      currentPosition = await Geolocator.getCurrentPosition();
       setState(() { // Mettre à jour l'interface après avoir obtenu la position
         // Optionally add a marker for the user's position
        markers.add(Marker(
          markerId: const MarkerId('userLocation'),
          position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: const InfoWindow(title: 'Votre Position'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure), // Marqueur bleu pour l'utilisateur
        ));

        // Move camera to user's location after getting it, or keep it centered on client
        // mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(currentPosition!.latitude, currentPosition!.longitude)));
      });
    } catch (e) {
       setState(() {
        _error = 'Erreur lors de l\'obtention de la position: ${e.toString()}';
      });
    }
  }

  void _addClientMarker() {
     // Ces vérifications sont déjà faites dans initState, mais on les garde pour plus de sécurité
     if (circuit == null || circuit!.clients.isEmpty) {
       setState(() {
         _error = 'Aucune donnée client dans le circuit.';
       });
       return;
     }
    // Prenons le premier client du circuit pour l'afficher de manière sûre
    final client = circuit!.clients.first;
    final clientLocation = LatLng(client.latitude, client.longitude);

    markers.add(Marker(
      markerId: MarkerId(client.id.toString()),
      position: clientLocation,
      infoWindow: InfoWindow(title: client.fullName, snippet: client.adresse),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Marqueur rouge pour le client
    ));
     setState(() {}); // Mettre à jour l'interface pour afficher le marqueur
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
     // Center map on client location initially only if valid client data is available
     if (circuit != null && circuit!.clients.isNotEmpty) {
       final client = circuit!.clients.first;
       mapController?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(client.latitude, client.longitude), 14.0));
     }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher l'erreur si elle existe
     if (_error != null) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Circuit sur la carte'),
           backgroundColor: Colors.indigo.shade600,
         ),
         body: Center(
           child: Text('Erreur: $_error', style: const TextStyle(color: Colors.red)),
         ),
       );
     }

    // Si pas d'erreur mais pas de circuit non plus (devrait être géré par le bloc d'erreur ci-dessus, mais double vérification)
     if (circuit == null || circuit!.clients.isEmpty) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Circuit sur la carte'),
            backgroundColor: Colors.indigo.shade600,
          ),
          body: const Center(
            child: Text('Aucune donnée de circuit disponible'),
          ),
        );
     }

    // Utiliser les coordonnées du premier client pour la position initiale si disponibles
    final initialCameraPosition = (circuit!.clients.isNotEmpty)
        ? CameraPosition(
            target: LatLng(circuit!.clients.first.latitude, circuit!.clients.first.longitude),
            zoom: 14.0,
          )
        : const CameraPosition(
            target: LatLng(0, 0), // Default to origin if no client
            zoom: 2.0,
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit sur la carte'),
        backgroundColor: Colors.indigo.shade600,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        myLocationEnabled: true, // Active le point bleu de la position de l'utilisateur
        myLocationButtonEnabled: true, // Active le bouton de recentrage sur l'utilisateur
      ),
    );
  }
} 