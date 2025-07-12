// ✅ NotificationsPage avec design Force de Vente (theme cohérent)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/notifications/controllers/notification_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController controller = Get.put(NotificationController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Promotions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Text(
              'Erreur: ${controller.errorMessage.value}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        if (controller.promotions.isEmpty) {
          return const Center(
            child: Text(
              'Aucune promotion disponible pour le moment.',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.promotions.length,
          itemBuilder: (context, index) {
            final promotion = controller.promotions[index];
            final String titre = promotion['titre'] ?? 'Titre inconnu';
            final String description = promotion['description'] ?? 'Description manquante';
            final double tauxReduction = (promotion['tauxReduction'] as num?)?.toDouble() ?? 0.0;
            final String dateDebut = promotion['dateDebut'] ?? 'Date inconnue';
            final String dateFin = promotion['dateFin'] ?? 'Date inconnue';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_offer_outlined, color: Colors.indigo, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          titre,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(description, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.discount, size: 18, color: Colors.green.shade700),
                      const SizedBox(width: 6),
                      Text("Réduction: ${tauxReduction.toStringAsFixed(0)}%", style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("📆 Du $dateDebut au $dateFin", style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
