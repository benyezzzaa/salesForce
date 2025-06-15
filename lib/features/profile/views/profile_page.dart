import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/profile/controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: 
      AppBar(
        backgroundColor: Colors.indigo.shade600,
        elevation: 0,
      leading: SizedBox(),
      title:Text("Mon Profil", style: TextStyle(color: Colors.white),),
      ),
      body: Obx(() => SingleChildScrollView(
            padding: const EdgeInsets.all(16),  
            child: Column(
              children: [
                // Avatar + nom complet
                Card(
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
                          backgroundColor: Colors.teal,
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
                // Infos
                InfoTile(icon: Icons.email, label: 'Email', value: controller.email.value),
                InfoTile(icon: Icons.phone, label: 'Téléphone', value: controller.tel.value),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    // Action de déconnexion (optionnel)
                    Get.defaultDialog(
                      title: "Déconnexion",
                      middleText: "Voulez-vous vraiment vous déconnecter ?",
                      textCancel: "Annuler",
                      textConfirm: "Oui",
                      confirmTextColor: Colors.white,
                      onConfirm: () {
                        Get.reset(); // ou StorageService.clear()
                        Get.offAllNamed('/login');
                      },
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Déconnexion"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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

  const InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal[700]),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
