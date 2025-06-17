import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/visite_controller.dart';
import '../models/client_model.dart';
import '../models/raison_model.dart';

class CreateVisitePage extends StatelessWidget {
  const CreateVisitePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisiteController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Visite', style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        elevation: 2,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Text(
              controller.error.value,
              style: TextStyle(color: colorScheme.error),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                          return DropdownMenuItem(
                            value: client,
                            child: Text(client.fullName, style: TextStyle(color: colorScheme.onSurface)),
                          );
                        }).toList(),
                        onChanged: (client) => controller.setClient(client),
                        hint: Text('Sélectionnez un client', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        dropdownColor: colorScheme.surface,
                        icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
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
                            child: Expanded(child: Text(raison.nom, style: TextStyle(color: colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
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
                      // La modal de succès est déjà affichée par le contrôleur
                      // Pas besoin de faire autre chose ici
                    } else if (controller.error.isNotEmpty) {
                      // Afficher l'erreur dans une modal si elle existe
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
                              onPressed: () => Get.back(),
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
} 