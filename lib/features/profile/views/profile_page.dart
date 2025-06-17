import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // <-- important
import 'package:pfe/core/routes/app_routes.dart';
import 'package:pfe/features/profile/controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF4F6F9);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
        leading: const SizedBox(),
        title: const Text("Mon Profil", style: TextStyle(color: Colors.white)),
      ),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar + nom complet
                Card(
                  color: cardColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.indigo,
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${controller.prenom.value} ${controller.nom.value}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          controller.role.value.capitalize!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Infos personnelles
                InfoTile(icon: Icons.email, label: 'Email', value: controller.email.value, color: cardColor),
                InfoTile(icon: Icons.phone, label: 'Téléphone', value: controller.tel.value, color: cardColor),
                const SizedBox(height: 30),

                // Bouton de déconnexion
                ElevatedButton.icon(
                  onPressed: () {
                    Get.defaultDialog(
                      title: "Déconnexion",
                      middleText: "Voulez-vous vraiment vous déconnecter ?",
                      textCancel: "Annuler",
                      textConfirm: "Oui",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                         GetStorage().erase();                      // 🧹 Nettoyer la session
                        Get.offAllNamed(AppRoutes.loginPage);     // ✅ Rediriger d’abord
                        Get.reset(); // 🔁 Redirige vers login
                      },
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Déconnexion"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
