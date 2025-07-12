import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/reclamation/Controller/reclamation_controller.dart';

class ReclamationHomePage extends StatelessWidget {
  const ReclamationHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = Get.put(ReclamationController());

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text("Réclamations", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Que souhaitez-vous faire ?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.add_circle_outline, color: colorScheme.onPrimary),
              label: Text("Nouvelle réclamation", style: TextStyle(fontSize: 16)),
              onPressed: () async {
                final result = await Get.toNamed('/reclamations/new');
                if (result == 'added') {
                  await controller.fetchMyReclamations();
                  Get.snackbar('Succès', 'Réclamation ajoutée avec succès ✅');
                }
              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.list_alt, color: colorScheme.primary),
              label: Text("Mes réclamations", style: TextStyle(fontSize: 16, color: colorScheme.onSurface)),
              onPressed: () => Get.toNamed('/reclamations/mes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
