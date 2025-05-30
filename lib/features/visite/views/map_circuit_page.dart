import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/circuit_model.dart';

class MapCircuitPage extends StatelessWidget {
  const MapCircuitPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CircuitModel? circuit = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circuit sur la carte'),
        backgroundColor: Colors.indigo.shade600,
      ),
      body: Center(
        child: circuit == null
            ? const Text('Aucune donnée de circuit disponible')
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Circuit créé avec succès !',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Date du circuit: ${circuit.date.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Clients inclus dans le circuit :',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: circuit.clients.map((client) => Text('- ${client.fullName}')).toList(),
                    ),
                    // TODO: Ajouter ici l'implémentation de la carte et de l'itinéraire
                  ],
                ),
              ),
      ),
    );
  }
} 