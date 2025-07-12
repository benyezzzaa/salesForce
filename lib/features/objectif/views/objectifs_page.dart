// 📁 lib/features/objectifs/views/objectifs_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/objectif/controller/objectifs_controller.dart';


class ObjectifsPage extends StatelessWidget {
  const ObjectifsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ObjectifsController controller = Get.put(ObjectifsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Objectifs", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.objectifs.isEmpty) {
          return const Center(child: Text("Aucun objectif trouvé."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.objectifs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final obj = controller.objectifs[index];
            final isAtteint = obj["atteint"] == true;
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAtteint ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isAtteint ? Colors.green : Colors.redAccent),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Catégorie : ${obj["categorie"]}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Objectif : ${obj["objectif"]}%", style: const TextStyle(fontSize: 14)),
                  Text("Réalisé : ${obj["realise"]}%", style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(isAtteint ? Icons.check_circle : Icons.cancel, color: isAtteint ? Colors.green : Colors.red),
                      const SizedBox(width: 6),
                      Text(
                        isAtteint ? "Objectif atteint" : "Objectif non atteint",
                        style: TextStyle(color: isAtteint ? Colors.green : Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
