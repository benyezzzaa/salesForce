import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../models/client_model.dart';

class PositionsMapPage extends StatefulWidget {
  const PositionsMapPage({super.key});

  @override
  State<PositionsMapPage> createState() => _PositionsMapPageState();
}

class _PositionsMapPageState extends State<PositionsMapPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Position? currentPosition;
  String _error = '';
  bool _isLoading = true;

  Map<String, dynamic>? commercial;
  ClientModel? client;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      commercial = arguments['commercial'];
      client = arguments['client'];
    }

    await _getCurrentLocation();
    _addMarkers();
    _createRoute();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permission de localisation refusée.';
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

      currentPosition = await Geolocator.getCurrentPosition();
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'obtention de la position: ${e.toString()}';
      });
    }
  }

  void _addMarkers() {
    // Marqueur pour le commercial connecté
    if (commercial != null && commercial!['latitude'] != null && commercial!['longitude'] != null) {
      markers.add(Marker(
        markerId: const MarkerId('commercial'),
        position: LatLng(
          (commercial!['latitude'] as num).toDouble(),
          (commercial!['longitude'] as num).toDouble(),
        ),
        infoWindow: InfoWindow(
          title: 'Commercial: ${commercial!['nom']} ${commercial!['prenom']}',
          snippet: 'Position actuelle',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    }

    // Marqueur pour le client sélectionné
    if (client != null && client!.latitude != null && client!.longitude != null) {
      markers.add(Marker(
        markerId: const MarkerId('client'),
        position: LatLng(client!.latitude!, client!.longitude!),
        infoWindow: InfoWindow(
          title: 'Client: ${client!.fullName}',
          snippet: client!.adresse,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    // Marqueur pour la position actuelle (si différente du commercial)
    if (currentPosition != null) {
      bool isDifferentFromCommercial = true;
      if (commercial != null && commercial!['latitude'] != null && commercial!['longitude'] != null) {
        final commercialLat = (commercial!['latitude'] as num).toDouble();
        final commercialLng = (commercial!['longitude'] as num).toDouble();
        final distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          commercialLat,
          commercialLng,
        );
        // Si la distance est inférieure à 100m, considérer que c'est la même position
        isDifferentFromCommercial = distance > 100;
      }

      if (isDifferentFromCommercial) {
        markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
          infoWindow: const InfoWindow(
            title: 'Votre Position Actuelle',
            snippet: 'Position GPS',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
      }
    }
  }

  void _createRoute() {
    List<LatLng> routePoints = [];

    // Ajouter la position du commercial
    if (commercial != null && commercial!['latitude'] != null && commercial!['longitude'] != null) {
      routePoints.add(LatLng(
        (commercial!['latitude'] as num).toDouble(),
        (commercial!['longitude'] as num).toDouble(),
      ));
    }

    // Ajouter la position du client
    if (client != null && client!.latitude != null && client!.longitude != null) {
      routePoints.add(LatLng(client!.latitude!, client!.longitude!));
    }

    // Créer la route si on a au moins 2 points
    if (routePoints.length >= 2) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        color: Colors.blue,
        width: 4,
        geodesic: true,
      ));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitBounds();
  }

  void _fitBounds() {
    List<LatLng> allPoints = [];

    // Ajouter la position du commercial
    if (commercial != null && commercial!['latitude'] != null && commercial!['longitude'] != null) {
      allPoints.add(LatLng(
        (commercial!['latitude'] as num).toDouble(),
        (commercial!['longitude'] as num).toDouble(),
      ));
    }

    // Ajouter la position du client
    if (client != null && client!.latitude != null && client!.longitude != null) {
      allPoints.add(LatLng(client!.latitude!, client!.longitude!));
    }

    // Ajouter la position actuelle si différente
    if (currentPosition != null) {
      bool isDifferentFromCommercial = true;
      if (commercial != null && commercial!['latitude'] != null && commercial!['longitude'] != null) {
        final commercialLat = (commercial!['latitude'] as num).toDouble();
        final commercialLng = (commercial!['longitude'] as num).toDouble();
        final distance = Geolocator.distanceBetween(
          currentPosition!.latitude,
          currentPosition!.longitude,
          commercialLat,
          commercialLng,
        );
        isDifferentFromCommercial = distance > 100;
      }

      if (isDifferentFromCommercial) {
        allPoints.add(LatLng(currentPosition!.latitude, currentPosition!.longitude));
      }
    }

    if (allPoints.isNotEmpty) {
      if (allPoints.length == 1) {
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(allPoints.first, 15.0),
        );
      } else {
        double minLat = allPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
        double maxLat = allPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
        double minLng = allPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
        double maxLng = allPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

        mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            50.0,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Positions sur la carte'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Positions sur la carte'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                _error,
                style: TextStyle(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Calculer la position initiale de la carte
    LatLng initialPosition;
    if (commercial != null && commercial!['latitude'] != null && commercial!['longitude'] != null) {
      initialPosition = LatLng(
        (commercial!['latitude'] as num).toDouble(),
        (commercial!['longitude'] as num).toDouble(),
      );
    } else if (client != null && client!.latitude != null && client!.longitude != null) {
      initialPosition = LatLng(client!.latitude!, client!.longitude!);
    } else {
      // Position par défaut (Paris)
      initialPosition = const LatLng(48.8566, 2.3522);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Positions sur la carte'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Get.offAllNamed('/home');
          },
          tooltip: 'Retour à l\'accueil',
        ),
        actions: [
          // Bouton pour créer une nouvelle visite
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.offAllNamed('/visite/create');
            },
            tooltip: 'Nouvelle visite',
          ),
          // Bouton pour voir le circuit complet
          IconButton(
            icon: const Icon(Icons.route),
            onPressed: () {
              Get.offAllNamed('/all-visites-map');
            },
            tooltip: 'Voir le circuit',
          ),
        ],
      ),
      body: Column(
        children: [
          // Informations en haut
          Container(
            padding: const EdgeInsets.all(16),
            color: colorScheme.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message de succès
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Visite créée avec succès !',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (commercial != null) ...[
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Commercial: ${commercial!['nom']} ${commercial!['prenom']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (client != null) ...[
                  Row(
                    children: [
                      Icon(Icons.business, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Client: ${client!.fullName}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adresse: ${client!.adresse}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Carte
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: initialPosition,
                zoom: 12.0,
              ),
              markers: markers,
              polylines: polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
} 