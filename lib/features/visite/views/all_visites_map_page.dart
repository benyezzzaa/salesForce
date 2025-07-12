import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../controllers/all_visites_map_controller.dart';
import '../models/visite_model.dart';
import '../models/circuit_model.dart';
import 'create_visite_page.dart';
import 'create_visite_multi_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AllVisitesMapPage extends StatefulWidget {
  final DateTime? initialDate;
  const AllVisitesMapPage({Key? key, this.initialDate}) : super(key: key);

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
    if (widget.initialDate != null) {
      controller.setSelectedDate(widget.initialDate!);
    }
    _initializeMap();
    
    // Rafraîchir les marqueurs après l'initialisation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers();
    });
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

    print('🗺️ Mise à jour des marqueurs...');
    print('📅 Date sélectionnée: ${controller.formatDate(controller.selectedDate.value)}');
    print('📍 Position actuelle: ${currentPosition != null ? "disponible" : "non disponible"}');

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
      print('📍 Marqueur position actuelle ajouté: (${currentPosition!.latitude}, ${currentPosition!.longitude})');
    } else {
      print('⚠️ Position actuelle non disponible');
    }

    // Ajouter les marqueurs pour les visites et tracer les polylines
    final visitesForDate = controller.getVisitesByDate(controller.selectedDate.value);
    print('📍 Ajout de ${visitesForDate.length} visites pour la date ${controller.formatDate(controller.selectedDate.value)}');
    
    for (int i = 0; i < visitesForDate.length; i++) {
      final visite = visitesForDate[i];
      print('   🔍 Vérification visite ${i + 1}: ${visite.client.fullName}');
      print('      Coordonnées: lat=${visite.client.latitude}, lng=${visite.client.longitude}');
      
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
        print('   ✅ Visite ${i + 1}: ${visite.client.fullName} (${visite.client.latitude}, ${visite.client.longitude})');

        // Tracer une polyline entre la position actuelle et le client
        if (currentPosition != null) {
          polylines.add(Polyline(
            polylineId: PolylineId('route_user_client_${visite.id}'),
            points: [
              LatLng(currentPosition!.latitude, currentPosition!.longitude),
              LatLng(visite.client.latitude!, visite.client.longitude!),
            ],
            color: Colors.blueAccent,
            width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ));
        }
      } else {
        print('   ❌ Visite ${i + 1}: ${visite.client.fullName} - Pas de coordonnées');
      }
    }

    print('🗺️ Total marqueurs: ${markers.length}');
    print('🛣️ Total polylines: ${polylines.length}');
    
    // Si aucun marqueur n'est affiché pour la date sélectionnée, proposer d'afficher toutes les visites
    if (visitesForDate.isEmpty) {
      print('⚠️ Aucune donnée pour la date sélectionnée');
      _showNoDataMessage();
    }
  }

  // Méthode pour afficher un message quand il n'y a pas de données
  void _showNoDataMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              const Text('Aucune donnée'),
            ],
          ),
          content: Text(
            'Aucune visite trouvée pour le ${controller.formatDate(controller.selectedDate.value)}.\n\n'
            'Voulez-vous afficher toutes les visites disponibles ?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton.icon(
              icon: Icon(Icons.cancel, color: Colors.white),
              label: Text('Annuler'),
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 4,
              ),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.map, color: Colors.white),
              label: Text('Afficher toutes'),
              onPressed: () {
                Navigator.of(context).pop();
                _showAllMarkers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Affichage de toutes les visites disponibles'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 4,
              ),
            ),
          ],
        ),
      );
    });
  }

  // Méthode pour afficher tous les marqueurs sans filtrage par date
  void _showAllMarkers() {
    markers.clear();
    polylines.clear();

    print('🗺️ AFFICHAGE DE TOUS LES MARQUEURS (sans filtrage par date)...');

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

    // Ajouter TOUTES les visites
    print('📍 Ajout de TOUTES les visites: ${controller.allVisites.length}');
    for (int i = 0; i < controller.allVisites.length; i++) {
      final visite = controller.allVisites[i];
      if (visite.client.latitude != null && visite.client.longitude != null) {
        markers.add(Marker(
          markerId: MarkerId('visite_all_${visite.id}'),
          position: LatLng(visite.client.latitude!, visite.client.longitude!),
          infoWindow: InfoWindow(
            title: 'Visite: ${visite.client.fullName}',
            snippet: '${controller.formatDate(visite.date)} - ${visite.client.adresse}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
        print('   ✅ Visite ${i + 1}: ${visite.client.fullName} (${visite.client.latitude}, ${visite.client.longitude})');
      }
    }

    // Ajouter TOUS les circuits
    print('🛣️ Ajout de TOUS les circuits: ${controller.allCircuits.length}');
    for (int i = 0; i < controller.allCircuits.length; i++) {
      final circuit = controller.allCircuits[i];
      for (int j = 0; j < circuit.clients.length; j++) {
        final client = circuit.clients[j];
        if (client.latitude != null && client.longitude != null) {
          markers.add(Marker(
            markerId: MarkerId('circuit_all_${circuit.id}_client_${client.id}'),
            position: LatLng(client.latitude!, client.longitude!),
            infoWindow: InfoWindow(
              title: 'Circuit ${circuit.id} - Client: ${client.fullName}',
              snippet: '${controller.formatDate(circuit.date)} - ${client.adresse}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ));
          print('   ✅ Circuit ${i + 1} - Client ${j + 1}: ${client.fullName} (${client.latitude}, ${client.longitude})');
        }
      }
    }

    print('🗺️ Total marqueurs (tous): ${markers.length}');
  }

  // Méthode pour afficher les visites de la semaine actuelle
  void _showWeekVisites() {
    markers.clear();
    polylines.clear();

    print('🗺️ AFFICHAGE DES VISITES DE LA SEMAINE...');

    // Calculer le début et la fin de la semaine
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    print('📅 Semaine: ${controller.formatDate(startOfWeek)} - ${controller.formatDate(endOfWeek)}');

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

    // Filtrer les visites de la semaine
    final weekVisites = controller.allVisites.where((visite) {
      return visite.date.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
             visite.date.isBefore(endOfWeek.add(Duration(days: 1)));
    }).toList();

    print('📍 Visites de la semaine: ${weekVisites.length}');

    for (int i = 0; i < weekVisites.length; i++) {
      final visite = weekVisites[i];
      if (visite.client.latitude != null && visite.client.longitude != null) {
        markers.add(Marker(
          markerId: MarkerId('visite_week_${visite.id}'),
          position: LatLng(visite.client.latitude!, visite.client.longitude!),
          infoWindow: InfoWindow(
            title: 'Visite: ${visite.client.fullName}',
            snippet: '${controller.formatDate(visite.date)} - ${visite.client.adresse}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
        print('   ✅ Visite ${i + 1}: ${visite.client.fullName} (${controller.formatDate(visite.date)})');
      }
    }

    // Filtrer les circuits de la semaine
    final weekCircuits = controller.allCircuits.where((circuit) {
      return circuit.date.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
             circuit.date.isBefore(endOfWeek.add(Duration(days: 1)));
    }).toList();

    print('🛣️ Circuits de la semaine: ${weekCircuits.length}');

    for (int i = 0; i < weekCircuits.length; i++) {
      final circuit = weekCircuits[i];
      for (int j = 0; j < circuit.clients.length; j++) {
        final client = circuit.clients[j];
        if (client.latitude != null && client.longitude != null) {
          markers.add(Marker(
            markerId: MarkerId('circuit_week_${circuit.id}_client_${client.id}'),
            position: LatLng(client.latitude!, client.longitude!),
            infoWindow: InfoWindow(
              title: 'Circuit ${circuit.id} - Client: ${client.fullName}',
              snippet: '${controller.formatDate(circuit.date)} - ${client.adresse}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ));
          print('   ✅ Circuit ${i + 1} - Client ${j + 1}: ${client.fullName} (${controller.formatDate(circuit.date)})');
        }
      }
    }

    print('🗺️ Total marqueurs (semaine): ${markers.length}');
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
    // Ajouter tous les points des clients (hors commercial)
    for (final marker in markers) {
      if (marker.markerId.value != 'userLocation' && marker.markerId.value != 'commercial') {
        allPoints.add(marker.position);
      }
    }
    if (allPoints.isEmpty) return;
    var sw = LatLng(
      allPoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b),
      allPoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b),
    );
    var ne = LatLng(
      allPoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b),
      allPoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b),
    );
    mapController?.moveCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: sw, northeast: ne),
        80,
      ),
    );
  }

  void _openInGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Retour',
          ),
          title: const Text('Carte des Visites et Circuits'),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.error.isNotEmpty || _error != null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Retour',
          ),
          title: const Text('Carte des Visites et Circuits'),
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
        ),
      );
    }

    // Mettre à jour les marqueurs quand les données changent
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMarkers();
    });
    
    // Écouter les changements de date pour rafraîchir les marqueurs
    controller.selectedDate.listen((_) {
      if (mounted) {
        _updateMarkers();
      }
    });

    // Calculer la position initiale
    LatLng initialPosition;
    if (currentPosition != null) {
      initialPosition = LatLng(currentPosition!.latitude, currentPosition!.longitude);
    } else {
      initialPosition = const LatLng(48.8566, 2.3522); // Paris par défaut
    }

    // Obtenir les statistiques pour la date sélectionnée
    final visitesForDate = controller.getVisitesByDate(controller.selectedDate.value);
    final clientsWithCoords = controller.getClientsWithCoordinatesForDate(controller.selectedDate.value);

    return Scaffold(
              appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Retour',
          ),
          title: const Text('Carte des Visites', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF3F51B5),
          foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: visitesForDate.isNotEmpty
                ? () => _showClientOrderDialog(visitesForDate)
                : null,
            tooltip: 'Voir les clients de la date',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await controller.loadAllData();
              _updateMarkers();
              setState(() {});
            },
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              _updateMarkers();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Marqueurs rafraîchis: ${markers.length} markers'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Rafraîchir marqueurs',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_visite',
            onPressed: () async {
              // Naviguer vers la page d'ajout de visite
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateVisitePage(initialDate: controller.selectedDate.value),
                ),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(Icons.add, color: Colors.white, size: 32),
            elevation: 6,
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'validate_visite',
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green, size: 28),
                      const SizedBox(width: 12),
                      const Text('Succès'),
                    ],
                  ),
                  content: const Text(
                    'Visite validée avec succès',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.home, color: Colors.white),
                      label: Text('OK'),
                      onPressed: () {
                        Get.back();
                        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 4,
                      ),
                    ),
                  ],
                ),
                barrierDismissible: false,
              );
            },
            backgroundColor: Colors.green,
            child: Icon(Icons.check, color: Colors.white, size: 32),
            elevation: 6,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Header stylé
          Positioned(
            top: 24,
            left: 24,
            right: 24,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white.withOpacity(0.95),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                        SizedBox(width: 8),
                        Text(
                          'Date : '
                          '${controller.formatDate(controller.selectedDate.value)}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Spacer(),
                        Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                        SizedBox(width: 4),
                        Text(
                          '${markers.where((m) => m.markerId.value != 'userLocation' && m.markerId.value != 'commercial').length} clients',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: currentPosition != null
                  ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
                  : const LatLng(48.8566, 2.3522),
              zoom: 12.0,
            ),
            markers: markers.map((marker) {
              if (marker.markerId.value != 'userLocation' && marker.markerId.value != 'commercial') {
                // Marqueur client avec InfoWindow custom
                return marker.copyWith(
                  infoWindowParam: InfoWindow(
                    title: marker.infoWindow.title,
                    snippet: 'Ouvrir dans Google Maps',
                    onTap: () => _openInGoogleMaps(marker.position.latitude, marker.position.longitude),
                  ),
                );
              }
              return marker;
            }).toSet(),
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
          ),
          // Panneau d'informations principales (beau design, responsive)
          Positioned(
            top: 16,
            left: 8,
            right: 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Card(
                  elevation: 8,
                  color: colorScheme.surface.withOpacity(0.98),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête avec date
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: colorScheme.primary, size: 26),
                            const SizedBox(width: 10),
                            Text(
                              'Date: ${controller.formatDate(controller.selectedDate.value)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                              tooltip: 'Changer la date',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Sous-titre explicatif
                        Text(
                          'Visites planifiées (futures) pour cette date',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Statistiques principales (beau design, responsive)
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            _buildStatCard(
                              icon: Icons.visibility,
                              label: 'Visites',
                              value: '${visitesForDate.length}',
                              color: Colors.green.shade700,
                            ),
                            _buildStatCard(
                              icon: Icons.location_on,
                              label: 'Clients',
                              value: '${clientsWithCoords.length}',
                              color: Colors.blue.shade700,
                            ),
                          ],
                        ),
                        if (visitesForDate.isEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  'Aucune visite planifiée (future) pour cette date. Utilisez les boutons ci-dessous pour voir d\'autres données.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        // Statistiques globales (beau design)
                        Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.storage, color: colorScheme.primary, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Total: ${controller.allVisites.length} visites',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Légende responsive et moderne
          Positioned(
            bottom: 16,
            left: 8,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Card(
                  elevation: 6,
                  color: colorScheme.surface.withOpacity(0.97),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: colorScheme.primary, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Légende',
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _buildLegendItem(
                              icon: Icons.location_on,
                              color: Colors.blue,
                              label: 'Votre position',
                            ),
                            _buildLegendItem(
                              icon: Icons.location_on,
                              color: Colors.green,
                              label: 'Visites individuelles',
                            ),
                            _buildLegendItem(
                              icon: Icons.linear_scale,
                              color: Colors.blueAccent,
                              label: 'Trajet vers client',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != controller.selectedDate.value) {
      controller.setSelectedDate(picked);
      setState(() {}); // Forcer la reconstruction du widget
      _updateMarkers();
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
        initialChildSize: 0.7,
        minChildSize: 0.4,
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
              Flexible(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Détails du ${controller.formatDate(controller.selectedDate.value)}',
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

  void _showClientOrderDialog(List<VisiteModel> visites) {
    if (visites.isEmpty) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text('Aucune visite trouvée pour cette date.')),
      );
      return;
    }

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('Clients pour la date ${controller.formatDate(controller.selectedDate.value)}'),
        content: ListView.builder(
          shrinkWrap: true,
          itemCount: visites.length,
          itemBuilder: (context, index) {
            final visite = visites[index];
            return ListTile(
              title: Text('${visite.client.fullName} - ${visite.client.adresse}'),
              subtitle: Text('${controller.formatDate(visite.date)}'),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }
} 