import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/reclamation/Controller/reclamation_controller.dart';


class ReclamationFormPage extends StatelessWidget {
  final controller = Get.find<ReclamationController>();

  ReclamationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // Get color scheme

    return Scaffold(
      backgroundColor: colorScheme.background, // Use background color
      appBar: AppBar(
        title: const Text("Nouvelle réclamation", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2, // Consistent elevation
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary)); // Use primary color
        }

        // Handle error state if available in controller
        // if (controller.errorMessage.isNotEmpty) {
        //   return Center(
        //     child: Text(
        //       controller.errorMessage.value,
        //       textAlign: TextAlign.center,
        //       style: TextStyle(color: colorScheme.error, fontSize: 16),
        //     ),
        //   );
        // }

        return Padding(
          padding: const EdgeInsets.all(16), // Consistent padding
          child: Form(
            key: controller.formKey,
            child: ListView(
              children: [
                Text("Client concerné :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: colorScheme.onSurface)), // Use onSurface
                const SizedBox(height: 10), // Consistent spacing
                DropdownButtonFormField<int>(
                  value: controller.selectedClientId.value,
                  onChanged: (val) => controller.selectedClientId.value = val!,
                  items: controller.clients
                      .map((c) => DropdownMenuItem<int>(
                            value: c['id'],
                            child: Text(c['nom'] ?? 'Client inconnu', style: TextStyle(color: colorScheme.onSurface)), // Use onSurface
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(8), // Consistent border radius
                       borderSide: BorderSide(color: colorScheme.outlineVariant), // Use outlineVariant
                    ),
                    focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(8), // Consistent border radius
                       borderSide: BorderSide(color: colorScheme.primary, width: 2), // Use primary
                    ),
                     filled: true,
                     fillColor: colorScheme.surfaceContainerLow, // Use subtle surface color
                    hintText: 'Sélectionner un client',
                     hintStyle: TextStyle(color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant
                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), // Adjusted padding
                  ),
                   style: TextStyle(color: colorScheme.onSurface), // Use onSurface
                  validator: (val) =>
                      val == null ? 'Client requis' : null,
                ),
                const SizedBox(height: 20), // Consistent spacing

                TextFormField(
                  controller: controller.sujetController,
                  decoration: InputDecoration(
                    labelText: 'Sujet',
                     labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(8), // Consistent border radius
                       borderSide: BorderSide(color: colorScheme.outlineVariant), // Use outlineVariant
                    ),
                     focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(8), // Consistent border radius
                       borderSide: BorderSide(color: colorScheme.primary, width: 2), // Use primary
                    ),
                     filled: true,
                     fillColor: colorScheme.surfaceContainerLow, // Use subtle surface color
                     hintStyle: TextStyle(color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), // Adjusted padding
                  ),
                   style: TextStyle(color: colorScheme.onSurface), // Use onSurface
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Sujet requis' : null,
                ),
                const SizedBox(height: 20), // Consistent spacing

                TextFormField(
                  controller: controller.descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Description',
                     labelStyle: TextStyle(color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant
                    border: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(8), // Consistent border radius
                       borderSide: BorderSide(color: colorScheme.outlineVariant), // Use outlineVariant
                    ),
                     focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(8), // Consistent border radius
                       borderSide: BorderSide(color: colorScheme.primary, width: 2), // Use primary
                    ),
                     filled: true,
                     fillColor: colorScheme.surfaceContainerLow, // Use subtle surface color
                     hintStyle: TextStyle(color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15), // Adjusted padding
                  ),
                   style: TextStyle(color: colorScheme.onSurface), // Use onSurface
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Description requise' : null,
                ),
                const SizedBox(height: 20), // Consistent spacing

                ElevatedButton.icon(
                  icon: Icon(Icons.send, color: colorScheme.onPrimary), // Use onPrimary
                  label: Text("Envoyer", style: TextStyle(fontSize: 16)), // Consistent font size
                  onPressed: controller.isLoading.value ? null : controller.submitReclamation, // Disable while loading
                   style: ElevatedButton.styleFrom(
                     backgroundColor: colorScheme.primary, // Use primary color
                     foregroundColor: colorScheme.onPrimary, // Use onPrimary
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
                     padding: const EdgeInsets.symmetric(vertical: 16), // Consistent padding
                     elevation: 4, // Consistent elevation
                   ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
