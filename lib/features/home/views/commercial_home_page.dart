// 📁 lib/features/home/commercial_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/features/home/controller/commercial_controller.dart';
import 'package:pfe/features/notifications/controllers/notification_controller.dart';
import 'package:pfe/features/profile/controllers/profile_controller.dart';
import 'package:pfe/features/reclamation/Controller/reclamation_controller.dart';
import 'package:pfe/features/objectif/models/objectif_model.dart';

class CommercialHomePage extends StatefulWidget {
  const CommercialHomePage({super.key});

  @override
  State<CommercialHomePage> createState() => _CommercialHomePageState();
}

class _CommercialHomePageState extends State<CommercialHomePage> {
  late final CommercialController controller;
  late final ProfileController profileController;
  late final NotificationController notifController;
  late final ReclamationController reclamationController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CommercialController());
    profileController = Get.put(ProfileController());
    notifController = Get.put(NotificationController());
    reclamationController = Get.put(ReclamationController());
    controller.fetchData(); // Recharge les objectifs à chaque fois
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userName = '${profileController.prenom.value} ${profileController.nom.value}';

    // Si la liste des objectifs est vide, on tente un fetch (une seule fois)
    if (controller.objectifs.isEmpty) {
      Future.microtask(() => controller.fetchData());
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF3F51B5),
          elevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              'Digital Process',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          actions: [
            Obx(() => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.white, size: 28),
                  onPressed: () => Get.toNamed(AppRoutes.notificationsPage),
                ),
                if (notifController.promotions.isNotEmpty)
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${notifController.promotions.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            )),
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 8, top: 8, bottom: 8),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  profileController.prenom.value.isNotEmpty
                    ? profileController.prenom.value[0].toUpperCase()
                    : '',
                  style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        children: [
          // Header Bonjour
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Text(
              '👋 Bonjour $userName',
              style: const TextStyle(
                color: Color(0xFF3F51B5),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),

          // Réclamations en attente - juste en dessous du message Bonjour
          Obx(() => reclamationController.mesReclamations.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  color: colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Icon(Icons.campaign, color: colorScheme.error),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${reclamationController.mesReclamations.length} réclamations en attente 🎯',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),

          // Vos Objectifs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Vos Objectifs',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
            children: _buildObjectifsCards(controller, colorScheme),
          )),
          const SizedBox(height: 10),

          // Navigation rapide
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Navigation rapide',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _QuickNavCard(
                  icon: Icons.assignment,
                  label: 'Réclamations',
                  onTap: () => Get.toNamed('/reclamations'),
                ),
                _QuickNavCard(
                  icon: Icons.location_on,
                  label: 'Visites',
                  onTap: () => Get.toNamed('/visite/create'),
                ),
                _QuickNavCard(
                  icon: Icons.people,
                  label: 'Clients',
                  onTap: () => Get.toNamed('/clients'),
                ),
                _QuickNavCard(
                  icon: Icons.shopping_cart,
                  label: 'Commandes',
                  onTap: () => Get.toNamed('/commandes'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<Widget> _buildObjectifsCards(CommercialController controller, ColorScheme colorScheme) {
    // Afficher un indicateur de chargement si les données sont en cours de chargement
    if (controller.isLoading.value) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: Column(
              children: [
                CircularProgressIndicator(color: colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  "Chargement des objectifs...",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final objectifs = controller.objectifs;
    if (objectifs.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.track_changes_outlined,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  "Aucun objectif disponible",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Vos objectifs apparaîtront ici",
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    return objectifs.map((obj) {
      final double realise = obj.realise.toDouble();
      final double objectif = obj.objectif.toDouble();
      final double percent = (objectif > 0) ? (realise / objectif).clamp(0.0, 1.0) : 0.0;
      final String percentText = objectif > 0 ? ((realise / objectif) * 100).clamp(0.0, 100.0).toStringAsFixed(1) : '0.0';
      final bool isFull = obj.atteint || (realise / objectif) >= 1.0;
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isFull 
                  ? [Colors.green.withOpacity(0.1), Colors.green.withOpacity(0.05)]
                  : [colorScheme.primary.withOpacity(0.1), colorScheme.primary.withOpacity(0.05)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isFull ? Icons.check_circle : Icons.track_changes,
                        color: isFull ? Colors.green : colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          obj.categorie,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFull ? Colors.green : colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$percentText%',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      backgroundColor: colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFull ? Colors.green : colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Réalisé',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$realise',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Objectif',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '$objectif',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isFull) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.celebration, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Objectif atteint !',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

class _QuickNavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickNavCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: 36),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}
