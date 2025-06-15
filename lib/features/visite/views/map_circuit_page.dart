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

  final CircuitModel? circuit = Get.arguments as CircuitModel?;

  @override
  void initState() {
    super.initState();
    if (circuit == null || circuit!.clients.isEmpty) {
      setState(() {
        _error = 'Aucune donnée client valide trouvée pour afficher le circuit.';
      });
    } else {
      _determinePosition();
      _addClientMarker();
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
        _error = 'Erreur lors de l\'obtention de la position: ${e.toString()}';
      });
    }
  }

  void _addClientMarker() {
    if (circuit == null || circuit!.clients.isEmpty) {
      setState(() {
        _error = 'Aucune donnée client dans le circuit.';
      });
      return;
    }

    final client = circuit!.clients.first;
   final lat = client.latitude!;
final lng = client.longitude!;


    markers.add(Marker(
      markerId: MarkerId(client.id.toString()),
      position: LatLng(lat, lng),
      infoWindow: InfoWindow(title: client.fullName, snippet: client.adresse),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));

    setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (circuit != null && circuit!.clients.isNotEmpty) {
      final client = circuit!.clients.first;
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(client.latitude!, client.longitude!  ),
          14.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

    final client = circuit!.clients.first;
    final CameraPosition initialCameraPosition = CameraPosition(
      target: LatLng(client.latitude!, client.longitude!),
      zoom: 14.0,
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
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
