import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/circuit_model.dart';
import 'package:pfe/features/clients/models/client_model.dart';

class MapCircuitPage extends StatefulWidget {
  const MapCircuitPage({super.key});

  @override
  State<MapCircuitPage> createState() => _MapCircuitPageState();
}

class _MapCircuitPageState extends State<MapCircuitPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Position? currentPosition;
  String? _error;
  bool _isLoading = true;

  final CircuitModel? circuit = Get.arguments as CircuitModel?;

  @override
  void initState() {
    super.initState();
    if (circuit == null) {
      setState(() {
        _error = 'Aucune donnée de circuit fournie.';
        _isLoading = false;
      });
    } else {
      _initializeMap();
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _determinePosition();
    _addClientMarkers();
    _createRoute();
    setState(() {
      _isLoading = false;
    });
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
          infoWindow: const InfoWindow(
            title: 'Votre Position',
            snippet: 'Point de départ',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ));
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'obtention de la position: ${e.toString()}';
      });
    }
  }

  void _addClientMarkers() {
    if (circuit == null || circuit!.clients.isEmpty) {
      setState(() {
        _error = 'Aucune donnée client dans le circuit.';
      });
      return;
    }

    for (int i = 0; i < circuit!.clients.length; i++) {
      final client = circuit!.clients[i];
      if (client.latitude != null && client.longitude != null) {
        markers.add(Marker(
          markerId: MarkerId('client_${client.id}'),
          position: LatLng(client.latitude!, client.longitude!),
          infoWindow: InfoWindow(
            title: '${i + 1}. ${client.fullName}',
            snippet: client.adresse,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      }
    }
  }

  void _createRoute() {
    if (circuit == null || circuit!.clients.isEmpty) return;

    List<LatLng> routePoints = [];
    
    // Ajouter la position actuelle si disponible
    if (currentPosition != null) {
      routePoints.add(LatLng(currentPosition!.latitude, currentPosition!.longitude));
    }

    // Ajouter tous les clients avec des coordonnées valides
    for (final client in circuit!.clients) {
      if (client.latitude != null && client.longitude != null) {
        routePoints.add(LatLng(client.latitude!, client.longitude!));
      }
    }

    // Créer la route même avec un seul point (pour afficher le marqueur)
    if (routePoints.isNotEmpty) {
      setState(() {
        polylines.add(Polyline(
          polylineId: const PolylineId('circuit_route'),
          points: routePoints,
          color: Colors.blue,
          width: 4,
          geodesic: true,
        ));
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitBounds();
  }

  void _fitBounds() {
    if (circuit == null || circuit!.clients.isEmpty) return;

    List<LatLng> allPoints = [];
    
    // Ajouter la position actuelle si disponible
    if (currentPosition != null) {
      allPoints.add(LatLng(currentPosition!.latitude, currentPosition!.longitude));
    }

    // Ajouter tous les clients avec des coordonnées valides
    for (final client in circuit!.clients) {
      if (client.latitude != null && client.longitude != null) {
        allPoints.add(LatLng(client.latitude!, client.longitude!));
      }
    }

    if (allPoints.isNotEmpty) {
      if (allPoints.length == 1) {
        // Si un seul point, zoomer dessus
        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(allPoints.first, 15.0),
        );
      } else {
        // Si plusieurs points, ajuster les bounds
        double minLat = allPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
        double maxLat = allPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
        double minLng = allPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
        double maxLng = allPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

        mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat - 0.01, minLng - 0.01),
              northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
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
          title: const Text('Circuit sur la carte'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Chargement du circuit...',
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Circuit sur la carte'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Erreur: $_error',
                  style: TextStyle(color: colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (circuit == null || circuit!.clients.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Circuit sur la carte'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 64, color: colorScheme.onSurfaceVariant),
              const SizedBox(height: 16),
              Text(
                'Aucune donnée de circuit disponible',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    // Calculer la position initiale de la carte
    LatLng initialPosition;
    if (currentPosition != null) {
      initialPosition = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    } else if (circuit!.clients.isNotEmpty && circuit!.clients.first.latitude != null) {
      initialPosition = LatLng(
        circuit!.clients.first.latitude!,
        circuit!.clients.first.longitude!,
      );
    } else {
      // Position par défaut (Paris)
      initialPosition = const LatLng(48.8566, 2.3522);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit de visite', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showCircuitInfo(),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialPosition,
              zoom: 12.0,
            ),
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.route, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Circuit du ${_formatDate(circuit!.date)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '${circuit!.clients.length} client(s) à visiter',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.fit_screen),
                      onPressed: _fitBounds,
                      tooltip: 'Ajuster la vue',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCircuitInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Détails du circuit',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Date',
                      value: _formatDate(circuit!.date),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.person,
                      title: 'Commercial',
                      value: circuit!.commercial['nom'] ?? 'Non spécifié',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.people,
                      title: 'Nombre de clients',
                      value: '${circuit!.clients.length}',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Liste des clients',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...circuit!.clients.asMap().entries.map((entry) {
                      final index = entry.key;
                      final client = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(client.fullName),
                          subtitle: Text(client.adresse),
                          trailing: Icon(
                            Icons.location_on,
                            color: (client.latitude != null && client.longitude != null)
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
