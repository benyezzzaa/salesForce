import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/utils/storage_services.dart';
import '../services/visite_service.dart';
import '../models/circuit_model.dart';

class CircuitViewerPage extends StatefulWidget {
  const CircuitViewerPage({super.key});

  @override
  State<CircuitViewerPage> createState() => _CircuitViewerPageState();
}

class _CircuitViewerPageState extends State<CircuitViewerPage> {
  final VisiteService _service = VisiteService();
  List<CircuitModel> circuits = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadCircuits();
  }

  Future<void> loadCircuits() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final token = StorageService.getToken();
      if (token == null) {
        setState(() {
          error = 'Token non trouvé. Veuillez vous reconnecter.';
          isLoading = false;
        });
        return;
      }

      final circuitsData = await _service.getAllCircuits(token);
      setState(() {
        circuits = circuitsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erreur lors du chargement des circuits: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Circuits', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadCircuits,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/visite/create'),
            tooltip: 'Créer une visite',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Chargement des circuits...',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ],
              ),
            )
          : error.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          error,
                          style: TextStyle(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: loadCircuits,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : circuits.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.route_outlined, size: 80, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 24),
                            Text(
                              'Aucun circuit disponible',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Créez votre première visite pour générer un circuit',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () => Get.toNamed('/visite/create'),
                              icon: const Icon(Icons.add),
                              label: const Text('Créer ma première visite'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // En-tête avec statistiques
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          child: Row(
                            children: [
                              Icon(Icons.route, color: colorScheme.primary, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                '${circuits.length} circuit${circuits.length > 1 ? 's' : ''} disponible${circuits.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => Get.toNamed('/all-visites-map'),
                                icon: const Icon(Icons.map),
                                label: const Text('Voir toutes les visites'),
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Liste des circuits
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: circuits.length,
                            itemBuilder: (context, index) {
                              final circuit = circuits[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor: colorScheme.primary.withOpacity(0.2),
                                    child: Icon(
                                      Icons.route,
                                      color: colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  title: Text(
                                    'Circuit du ${formatDate(circuit.date)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Text(
                                        '${circuit.clients.length} client${circuit.clients.length > 1 ? 's' : ''} à visiter',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Commercial: ${circuit.commercial['nom'] ?? 'Non spécifié'}',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 16,
                                  ),
                                  onTap: () {
                                    Get.toNamed('/map-circuit', arguments: circuit);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: circuits.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed('/visite/create'),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle visite'),
            )
          : null,
    );
  }
} 