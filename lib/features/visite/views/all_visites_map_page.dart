import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/all_visites_map_controller.dart';
import '../models/visite_model.dart';
import '../models/circuit_model.dart';

class AllVisitesMapPage extends StatefulWidget {
  const AllVisitesMapPage({super.key});

  @override
  State<AllVisitesMapPage> createState() => _AllVisitesMapPageState();
}

class _AllVisitesMapPageState extends State<AllVisitesMapPage> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  Position? currentPosition;
  String? _error;
  bool _isLoading = true;

  final controller = Get.put(AllVisitesMapController());

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _initializeMap() async {
    await _determinePosition();
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

  void _updateMarkers() {
    markers.clear();
    polylines.clear();

    // Ajouter la position actuelle
    if (currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('userLocation'),
        position: LatLng(currentPosition!.latitude, currentPosition!.longitude),
        infoWindow: const InfoWindow(
          title: 'Votre Position',
          snippet: 'Point de départ',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ));
    }

    // Ajouter les marqueurs pour les visites
    final visitesForDate = controller.getVisitesByDate(controller.selectedDate.value);
    for (int i = 0; i < visitesForDate.length; i++) {
      final visite = visitesForDate[i];
      if (visite.client.latitude != null && visite.client.longitude != null) {
        markers.add(Marker(
          markerId: MarkerId('visite_${visite.id}'),
          position: LatLng(visite.client.latitude!, visite.client.longitude!),
          infoWindow: InfoWindow(
            title: 'Visite ${i + 1}: ${visite.client.fullName}',
            snippet: '${controller.formatDate(visite.date)} - ${visite.client.adresse}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
      }
    }

    // Ajouter les marqueurs pour les circuits
    final circuitsForDate = controller.getCircuitsByDate(controller.selectedDate.value);
    for (int i = 0; i < circuitsForDate.length; i++) {
      final circuit = circuitsForDate[i];
      for (int j = 0; j < circuit.clients.length; j++) {
        final client = circuit.clients[j];
        if (client.latitude != null && client.longitude != null) {
          markers.add(Marker(
            markerId: MarkerId('circuit_${circuit.id}_client_${client.id}'),
            position: LatLng(client.latitude!, client.longitude!),
            infoWindow: InfoWindow(
              title: 'Circuit ${i + 1} - Client ${j + 1}: ${client.fullName}',
              snippet: '${controller.formatDate(circuit.date)} - ${client.adresse}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ));
        }
      }
    }

    // Créer les trajets pour les circuits
    _createCircuitRoutes(circuitsForDate);
  }

  void _createCircuitRoutes(List<CircuitModel> circuits) {
    for (int i = 0; i < circuits.length; i++) {
      final circuit = circuits[i];
      List<LatLng> routePoints = [];
      
      // Ajouter la position actuelle si disponible
      if (currentPosition != null) {
        routePoints.add(LatLng(currentPosition!.latitude, currentPosition!.longitude));
      }

      // Ajouter tous les clients du circuit
      for (final client in circuit.clients) {
        if (client.latitude != null && client.longitude != null) {
          routePoints.add(LatLng(client.latitude!, client.longitude!));
        }
      }

      if (routePoints.length >= 2) {
        polylines.add(Polyline(
          polylineId: PolylineId('circuit_route_${circuit.id}'),
          points: routePoints,
          color: Colors.blue,
          width: 4,
          geodesic: true,
        ));
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _fitBounds();
  }

  void _fitBounds() {
    List<LatLng> allPoints = [];
    
    // Ajouter la position actuelle si disponible
    if (currentPosition != null) {
      allPoints.add(LatLng(currentPosition!.latitude, currentPosition!.longitude));
    }

    // Ajouter tous les points des visites et circuits
    final visitesForDate = controller.getVisitesByDate(controller.selectedDate.value);
    final circuitsForDate = controller.getCircuitsByDate(controller.selectedDate.value);

    for (final visite in visitesForDate) {
      if (visite.client.latitude != null && visite.client.longitude != null) {
        allPoints.add(LatLng(visite.client.latitude!, visite.client.longitude!));
      }
    }

    for (final circuit in circuitsForDate) {
      for (final client in circuit.clients) {
        if (client.latitude != null && client.longitude != null) {
          allPoints.add(LatLng(client.latitude!, client.longitude!));
        }
      }
    }

    if (allPoints.isNotEmpty) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les visites'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.refreshData();
              _updateMarkers();
            },
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDataInfo(),
            tooltip: 'Informations',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value || _isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  'Chargement des visites...',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ],
            ),
          );
        }

        if (controller.error.isNotEmpty || _error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur: ${controller.error.isNotEmpty ? controller.error.value : _error}',
                    style: TextStyle(color: colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      controller.refreshData();
                      _updateMarkers();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        // Mettre à jour les marqueurs quand les données changent
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateMarkers();
        });

        // Calculer la position initiale
        LatLng initialPosition;
        if (currentPosition != null) {
          initialPosition = LatLng(currentPosition!.latitude, currentPosition!.longitude);
        } else {
          initialPosition = const LatLng(48.8566, 2.3522); // Paris par défaut
        }

        return Stack(
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date sélectionnée',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  controller.formatDate(controller.selectedDate.value),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_month),
                            onPressed: () => _selectDate(context),
                            tooltip: 'Changer la date',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.visibility,
                              label: 'Visites',
                              value: '${controller.getTotalVisitesForDate(controller.selectedDate.value)}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildInfoChip(
                              icon: Icons.people,
                              label: 'Clients',
                              value: '${controller.getTotalClientsForDate(controller.selectedDate.value)}',
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: _fitBounds,
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                child: const Icon(Icons.fit_screen),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      controller.setSelectedDate(date);
    }
  }

  void _showDataInfo() {
    final visitesForDate = controller.getVisitesByDate(controller.selectedDate.value);
    final circuitsForDate = controller.getCircuitsByDate(controller.selectedDate.value);

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
                      'Données du ${controller.formatDate(controller.selectedDate.value)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'Visites individuelles',
                      count: visitesForDate.length,
                      items: visitesForDate.map((visite) => {
                        'title': visite.client.fullName,
                        'subtitle': visite.client.adresse,
                        'icon': Icons.visibility,
                        'color': Colors.green,
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'Circuits',
                      count: circuitsForDate.length,
                      items: circuitsForDate.map((circuit) => {
                        'title': 'Circuit ${circuit.id}',
                        'subtitle': '${circuit.clients.length} client(s)',
                        'icon': Icons.route,
                        'color': Colors.blue,
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required int count,
    required List<Map<String, dynamic>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title ($count)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Text(
            'Aucune donnée pour cette section',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ...items.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item['color'].withOpacity(0.2),
                child: Icon(
                  item['icon'],
                  color: item['color'],
                  size: 20,
                ),
              ),
              title: Text(item['title']),
              subtitle: Text(item['subtitle']),
            ),
          )).toList(),
      ],
    );
  }
} 