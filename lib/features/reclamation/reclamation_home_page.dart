import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReclamationHomePage extends StatelessWidget {
  const ReclamationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // Get color scheme

    return Scaffold(
      backgroundColor: colorScheme.background, // Use background color
      appBar: AppBar(
        title: Text("Réclamations", style: TextStyle(color: colorScheme.onPrimary)), // Use onPrimary
        backgroundColor: colorScheme.primary, // Use primary color
        iconTheme: IconThemeData(color: colorScheme.onPrimary), // Use onPrimary for back button
        elevation: 2, // Consistent elevation
      ),
      body: Padding(
        padding: const EdgeInsets.all(24), // Increased padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch buttons horizontally
          children: [
            Text("Que souhaitez-vous faire ?", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)), // Use onSurface
            const SizedBox(height: 40), // Increased spacing
            ElevatedButton.icon(
              icon: Icon(Icons.add_circle_outline, color: colorScheme.onPrimary), // Use onPrimary, adjusted icon
              label: Text("Nouvelle réclamation", style: TextStyle(fontSize: 16)), // Consistent font size
              onPressed: () => Get.toNamed('/reclamations/new'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Use primary color
                foregroundColor: colorScheme.onPrimary, // Use onPrimary
                minimumSize: const Size.fromHeight(50), // Maintain height
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Consistent border radius
                elevation: 4, // Consistent elevation
              ),
            ),
            const SizedBox(height: 20), // Consistent spacing
            ElevatedButton.icon(
              icon: Icon(Icons.list_alt, color: colorScheme.primary), // Use primary color, adjusted icon
              label: Text("Mes réclamations", style: TextStyle(fontSize: 16, color: colorScheme.onSurface)), // Use onSurface
              onPressed: () => Get.toNamed('/reclamations/mes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surface, // Use surface color for secondary button
                foregroundColor: colorScheme.onSurface, // Use onSurface
                minimumSize: const Size.fromHeight(50), // Maintain height
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)), // Consistent border radius, add outline
                elevation: 2, // Slightly less elevation for secondary
              ),
            ),
          ],
        ),
      ),
    );
  }
}
