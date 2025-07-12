import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/visite_controller.dart';
import 'package:pfe/features/clients/models/client_model.dart';
import '../models/raison_model.dart';
import '../models/visite_model.dart';
import '../services/visite_service.dart';
import 'package:pfe/core/utils/storage_services.dart';
import 'package:pfe/features/visite/views/all_visites_map_page.dart';

class CreateVisitePage extends StatefulWidget {
  final DateTime? initialDate;
  const CreateVisitePage({Key? key, this.initialDate}) : super(key: key);

  @override
  State<CreateVisitePage> createState() => _CreateVisitePageState();
}

class _CreateVisitePageState extends State<CreateVisitePage> {
  final VisiteController controller = Get.put(VisiteController());
  List<VisiteModel> mesVisites = [];
  bool isLoadingVisites = false;
  String errorVisites = '';

  // Variables d'état à ajouter dans le State
  String _searchQuery = '';
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      controller.setDate(widget.initialDate!);
    }
    _loadMesVisites();
  }

  Future<void> _loadMesVisites() async {
    setState(() {
      isLoadingVisites = true;
      errorVisites = '';
    });
    try {
      final t = StorageService.getToken();
      if (t != null && t.isNotEmpty) {
        mesVisites = await VisiteService().getAllVisites(t);
      } else {
        errorVisites = 'Token non trouvé.';
      }
    } catch (e) {
      errorVisites = 'Erreur lors du chargement des visites : $e';
    }
    setState(() {
      isLoadingVisites = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Visite', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Get.toNamed('/clients')?.then((added) {
                if (added == true) {
                  // Recharger la liste des clients dans le contrôleur
                  controller.loadData();
                }
              });
            },
            tooltip: 'Ajouter un client',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION MES VISITES
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ExpansionTile(
                    title: Text('Mes visites', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    initiallyExpanded: false,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            // Champ de recherche
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Rechercher un client...',
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                ),
                                onChanged: (val) => setState(() => _searchQuery = val),
                              ),
                            ),
                            SizedBox(width: 8),
                            // Sélecteur de date
                            InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _filterDate ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(Duration(days: 365)),
                                  lastDate: DateTime.now().add(Duration(days: 365)),
                                );
                                if (date != null) setState(() => _filterDate = date);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  border: Border.all(color: colorScheme.primary),
                                  borderRadius: BorderRadius.circular(12),
                                  color: colorScheme.surfaceContainerLow,
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 18, color: colorScheme.primary),
                                    SizedBox(width: 4),
                                    Text(_filterDate == null
                                        ? 'Date'
                                        : DateFormat('dd/MM/yyyy').format(_filterDate!),
                                      style: TextStyle(color: colorScheme.primary),
                                    ),
                                    if (_filterDate != null)
                                      IconButton(
                                        icon: Icon(Icons.close, size: 16, color: colorScheme.error),
                                        onPressed: () => setState(() => _filterDate = null),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoadingVisites)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (errorVisites.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(errorVisites, style: TextStyle(color: colorScheme.error)),
                        )
                      else if (mesVisites.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Aucune visite trouvée.'),
                        )
                      else ...[
                        // Filtrer les visites selon les critères
                        ..._groupVisitesByDate(_getFilteredVisites()).entries.map((entry) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              child: Text(
                                entry.key,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.primary),
                              ),
                            ),
                            ...entry.value.map((visite) => Card(
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Icon(Icons.person, color: colorScheme.onPrimaryContainer),
                                ),
                                title: Text(visite.client.fullName, style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (visite.client.adresse.isNotEmpty)
                                      Text(visite.client.adresse, style: TextStyle(fontSize: 13)),
                                    // Afficher la date ou '--:--' si pas d'heure
                                    Text('Date : ' + DateFormat('dd/MM/yyyy').format(visite.date)),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.map, color: colorScheme.primary),
                                  onPressed: () {
                                    controller.setClient(visite.client);
                                    controller.showPositionsMap();
                                  },
                                  tooltip: 'Voir sur la carte',
                                ),
                              ),
                            )),
                          ],
                        )),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date de visite',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: controller.selectedDate.value,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: colorScheme,
                                  dialogBackgroundColor: colorScheme.surface,
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            controller.setDate(date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                                style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                              ),
                              Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<ClientModel>(
                        value: controller.selectedClient,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLow,
                        ),
                        items: controller.clients.map((client) {
                          return DropdownMenuItem<ClientModel>(
                            value: client,
                            child: Text(client.fullName, style: TextStyle(color: colorScheme.onSurface)),
                          );
                        }).toList(),
                        onChanged: (client) => controller.setClient(client),
                        hint: Text('Sélectionnez un client', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        dropdownColor: colorScheme.surface,
                        icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                      ),
                      // Bouton pour afficher les positions
                      if (controller.selectedClient != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => controller.showPositionsMap(),
                            icon: Icon(Icons.map, color: colorScheme.primary),
                            label: Text(
                              'Voir les positions sur la carte',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Raison de visite',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<RaisonModel>(
                        value: controller.selectedRaison,
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: colorScheme.outlineVariant),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLow,
                        ),
                        items: controller.raisons.map((raison) {
                          return DropdownMenuItem(
                            value: raison,
                            child: Text(raison.nom, style: TextStyle(color: colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (raison) => controller.setRaison(raison),
                        hint: Text('Sélectionnez une raison', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        dropdownColor: colorScheme.surface,
                        icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (!controller.isLoading.value) {
                    final success = await controller.createVisite();
                    if (success) {
                      // Naviguer vers la page carte après création
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllVisitesMapPage(initialDate: controller.selectedDate.value),
                        ),
                      );
                    } else if (controller.error.isNotEmpty) {
                      // Afficher l'erreur dans une popup
                      Get.dialog(
                        AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          title: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 28),
                              const SizedBox(width: 12),
                              const Text('Erreur'),
                            ],
                          ),
                          content: Text(
                            controller.error.value,
                            style: TextStyle(fontSize: 16),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                controller.error.value = '';
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                child: controller.isLoading.value ?
                 SizedBox(
                   width: 20,
                   height: 20,
                   child: CircularProgressIndicator(color: colorScheme.onPrimary, strokeWidth: 2),
                 ) : const Text(
                  'Créer la visite',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Méthode pour filtrer les visites selon les critères
  List<VisiteModel> _getFilteredVisites() {
    return mesVisites.where((visite) {
      // Filtre par nom/prénom du client
      bool matchesSearch = _searchQuery.isEmpty || 
          visite.client.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filtre par date
      bool matchesDate = _filterDate == null || 
          (visite.date.year == _filterDate!.year && 
           visite.date.month == _filterDate!.month && 
           visite.date.day == _filterDate!.day);
      
      return matchesSearch && matchesDate;
    }).toList();
  }

  // Ajouter la méthode utilitaire pour grouper par date
  Map<String, List<VisiteModel>> _groupVisitesByDate(List<VisiteModel> visites) {
    final map = <String, List<VisiteModel>>{};
    for (final v in visites) {
      final dateStr = DateFormat('dd/MM/yyyy').format(v.date);
      map.putIfAbsent(dateStr, () => []).add(v);
    }
    return map;
  }
} 