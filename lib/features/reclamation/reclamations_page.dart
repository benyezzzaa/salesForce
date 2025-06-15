import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/reclamation/controller/reclamation_controller.dart';


class MesReclamationsPage extends StatelessWidget {
  final controller = Get.put(ReclamationController());

  MesReclamationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // Get color scheme
    // Ensure fetchMyReclamations is called, perhaps more conditionally
    // controller.fetchMyReclamations(); // Moved this call to onInit or ensure it's handled in controller initialization

    return Scaffold(
      backgroundColor: colorScheme.background, // Use background color
      appBar: AppBar(
        title: Text('Mes réclamations', style: TextStyle(color: colorScheme.onPrimary)), // Use onPrimary
        backgroundColor: colorScheme.primary, // Use primary color
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Use onPrimary for back button
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

        if (controller.mesReclamations.isEmpty) {
          return Center(child: Text("Aucune réclamation envoyée", style: TextStyle(color: colorScheme.onSurfaceVariant))); // Use onSurfaceVariant
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Adjusted padding
          itemCount: controller.mesReclamations.length,
          itemBuilder: (context, index) {
            final rec = controller.mesReclamations[index];
            // Safely access data, provide default values or handle null
            final String sujet = rec['sujet'] ?? 'Sujet inconnu';
            final String description = rec['description'] ?? 'Aucune description';
            final String status = rec['status'] ?? 'Inconnu';

            Color statusColor = colorScheme.surfaceVariant; // Default color
            Color onStatusColor = colorScheme.onSurfaceVariant; // Default text color
            switch(status.toLowerCase()) {
              case 'en attente':
                statusColor = colorScheme.secondaryContainer;
                onStatusColor = colorScheme.onSecondaryContainer;
                break;
              case 'traitée': // Assuming 'traitée' is another status
                statusColor = colorScheme.tertiaryContainer; // Or primaryContainer
                onStatusColor = colorScheme.onTertiaryContainer; // Or onPrimaryContainer
                break;
              case 'fermée': // Assuming 'fermée' is another status
                 statusColor = colorScheme.errorContainer; // Or a greyish color
                 onStatusColor = colorScheme.onErrorContainer; // Or onSurface
                 break;
              // Add more cases for other statuses if needed
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6), // Consistent margin
              elevation: 4, // Consistent elevation
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
              color: colorScheme.surface, // Use surface color
              child: ListTile(
                leading: Icon(Icons.report_problem, color: colorScheme.onSurfaceVariant), // Use onSurfaceVariant
                title: Text(sujet, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface)), // Use onSurface
                subtitle: Text(description, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)), // Use onSurfaceVariant, slightly smaller font
                trailing: Chip(
                   label: Text(status, style: TextStyle(color: onStatusColor, fontSize: 11, fontWeight: FontWeight.w600)), // Use onStatusColor
                   backgroundColor: statusColor, // Use statusColor
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Adjusted shape
                ),
                // onTap: () { // Add navigation to details if a details page exists
                //   // Navigate to reclamation details page, maybe passing rec['id']
                // },
              ),
            );
          },
        );
      }),
    );
  }
}
