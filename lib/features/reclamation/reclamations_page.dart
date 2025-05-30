import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/reclamation/Controller/reclamation_controller.dart';


class MesReclamationsPage extends StatelessWidget {
  final controller = Get.put(ReclamationController());

  MesReclamationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.fetchMyReclamations();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes réclamations')),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.mesReclamations.isEmpty) {
          return const Center(child: Text("Aucune réclamation envoyée"));
        }

        return ListView.builder(
          itemCount: controller.mesReclamations.length,
          itemBuilder: (context, index) {
            final rec = controller.mesReclamations[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                title: Text(rec['sujet']),
                subtitle: Text(rec['description']),
                trailing: Chip(label: Text(rec['status'])),
                leading: const Icon(Icons.report_problem),
              ),
            );
          },
        );
      }),
    );
  }
}
