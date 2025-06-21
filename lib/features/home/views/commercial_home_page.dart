// 📁 lib/features/home/commercial_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/features/home/controller/commercial_controller.dart';
import 'package:pfe/features/notifications/controllers/notification_controller.dart';
import 'package:pfe/features/profile/controllers/profile_controller.dart';
import 'package:pfe/features/reclamation/Controller/reclamation_controller.dart';

class CommercialHomePage extends StatelessWidget {
  const CommercialHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommercialController());
    final profileController = Get.put(ProfileController());
    final NotificationController notifController = Get.put(NotificationController());
    final ReclamationController reclamationController = Get.put(ReclamationController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
        title: const Text('Digital Process ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600 , color: Colors.white)),
        actions: [
          Obx(() {
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/notifications');
              },
              child: Stack(
                children: [
                  Icon(Icons.notifications_none_rounded, size: 40, color: Colors.white),
                  if (notifController.promotions.length > 0)
                    Positioned(
                      right: 13,
                      bottom: 23,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          notifController.promotions.length.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ],
      ),
      body: Obx(() {
        return AnimationLimiter(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 500),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  Text(
                    "👋 Bonjour ${profileController.prenom.value} ${profileController.nom.value}",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle("Vos Objectifs"),
                  _objectifOverview(controller),
                  const SizedBox(height: 12),
                  _infoCard(Icons.emoji_objects, "📢 ${reclamationController.mesReclamations.length} réclamations en attente 🎯"),
                  const SizedBox(height: 12),
                  _sectionTitle("Navigation rapide"),
                  const SizedBox(height: 12),
                  _buildGrid(context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _infoCard(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _objectifOverview(CommercialController controller) {
    final objectifs = controller.objectifs;
    final colorScheme = Theme.of(Get.context!).colorScheme;

    if (objectifs.isEmpty) {
      return Center(
        child: Text(
          "Aucun objectif trouvé",
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: objectifs.map((obj) {
            final double objectifValue = obj.objectif;
            final double realiseValue = obj.realise;

            double percentage = 0.0;
            if (objectifValue > 0) {
              percentage = (realiseValue / objectifValue).clamp(0.0, 1.0);
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    obj.categorie.trim(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: colorScheme.primary,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Réalisé : ${realiseValue.toStringAsFixed(1)}",
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        "Objectif : ${objectifValue.toStringAsFixed(1)}",
                        style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        "${(percentage * 100).toStringAsFixed(1)}%",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: colorScheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final List<Map<String, dynamic>> shortcuts = [
      {'label': 'Réclamations', 'icon': Icons.assignment, 'route': '/reclamations/home'},
      {'label': 'Visites', 'icon': Icons.place, 'route': '/visite/create'},
      {'label': 'Clients', 'icon': Icons.group, 'route': '/clients'},
      {'label': 'Commandes', 'icon': Icons.shopping_cart, 'route': '/commandes'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shortcuts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final item = shortcuts[index];
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, item['route']),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], size: 32, color: Colors.indigo),
                const SizedBox(height: 10),
                Text(
                  item['label'],
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.indigo),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
