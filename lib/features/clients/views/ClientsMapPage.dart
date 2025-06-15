import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:pfe/features/clients/controllers/client_controller.dart';

class ClientsMapPage extends StatelessWidget {
  final ClientController controller = Get.find<ClientController>();

  ClientsMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final markers = controller.clients.map((client) {
      return Marker(
        markerId: MarkerId(client.id.toString()),
        position: LatLng(client.latitude!, client.longitude!),
        infoWindow: InfoWindow(
          title: client.fullName,
          snippet: client.adresse,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(title: const Text("Carte des clients")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(
              controller.clients!.first.latitude!,
              controller.clients!.first.longitude!),
          zoom: 12,
        ),
        markers: markers,
        myLocationEnabled: true,
      ),
    );
  }
}
