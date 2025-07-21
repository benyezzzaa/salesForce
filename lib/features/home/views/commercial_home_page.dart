// 📁 lib/features/home/commercial_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/features/home/controller/commercial_controller.dart';
import 'package:pfe/features/notifications/controllers/notification_controller.dart';
import 'package:pfe/features/profile/controllers/profile_controller.dart';
import 'package:pfe/features/reclamation/Controller/reclamation_controller.dart';
import 'package:pfe/features/objectif/models/objectif_model.dart';
import 'package:pfe/features/satisfaction/commercial_surveys_page.dart';

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
    
    // Debug logs
    print('🏠 CommercialHomePage initState');
    print('📊 Controller objectifs count: ${controller.objectifs.length}');
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
                        Icon(Icons.assignment_turned_in, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CommercialSurveysPage()),
                            ),
                            child: Text(
                              'Enquêtes de satisfaction',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                decoration: TextDecoration.underline,
                              ),
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
          Obx(() {
            final now = DateTime.now();
            final objectifsPerso = controller.objectifs.where((obj) => !obj.isGlobal && obj.dateFin.isAfter(now)).toList();
            if (controller.isLoading.value) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (objectifsPerso.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text("Aucun objectif personnel")),
              );
            }
            return Column(
              children: objectifsPerso.map((obj) => _buildObjectifCard(obj, colorScheme)).toList(),
            );
          }),
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
                  icon: Icons.people,
                  label: 'Clients',
                  onTap: () => Get.toNamed('/clients'),
                ),
                _QuickNavCard(
                  icon: Icons.shopping_cart,
                  label: 'Commandes',
                  onTap: () => Get.toNamed('/commandes'),
                ),
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
               
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildObjectifCard(ObjectifModel obj, ColorScheme colorScheme) {
    print('DEBUG Objectif: mission= [33m${obj.mission} [0m, dateDebut=${obj.dateDebut}, dateFin=${obj.dateFin}');
    final double percent = (obj.montantCible > 0) ? (obj.ventes / obj.montantCible).clamp(0.0, 1.0) : 0.0;
    final String percentText = (percent * 100).toStringAsFixed(0);
    final bool isFull = obj.atteint || percent >= 1.0;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec mission et pourcentage
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        obj.mission,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isFull ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$percentText%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Barre de progression
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFull ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Informations détaillées
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Objectif',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${obj.montantCible.toStringAsFixed(0)} €',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Réalisé',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${obj.ventes.toStringAsFixed(0)} €',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isFull ? Colors.green : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (obj.prime > 0)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prime',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              '${obj.prime.toStringAsFixed(0)} €',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // Statut
          if (isFull) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Objectif atteint !',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          // Ajout du Padding de la période comme enfant du Column principal
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Center(
              child: Text(
                'Période : '
                '${obj.dateDebut.day.toString().padLeft(2, '0')}/'
                '${obj.dateDebut.month.toString().padLeft(2, '0')}/'
                '${obj.dateDebut.year} - '
                '${obj.dateFin.day.toString().padLeft(2, '0')}/'
                '${obj.dateFin.month.toString().padLeft(2, '0')}/'
                '${obj.dateFin.year}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHorizontalBarChart(List<Map<String, dynamic>> data, {Color color = Colors.grey}) {
    final max = data.map((e) => e['value'] as num).fold<num>(0, (a, b) => a > b ? a : b);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: data.map((item) {
          final double percent = max > 0 ? (item['value'] as num) / max : 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Barre stylée
                Expanded(
                  flex: 6,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.12),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: percent,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade700,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Valeur réalisée dans un badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade700,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item['value']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (item['prime'] != null && item['prime'] > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Prime : ${item['prime']} €',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickNavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickNavCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color.fromARGB(255, 5, 25, 80), // ✅ bordure bleu clair
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // ✅ ombre légère
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

