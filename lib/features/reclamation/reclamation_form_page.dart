import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/features/reclamation/Controller/reclamation_controller.dart';


class ReclamationFormPage extends StatelessWidget {
  final controller = Get.put(ReclamationController());

  ReclamationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle réclamation")),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: ListView(
              children: [
                const Text("Client concerné :", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: controller.selectedClientId.value,
                  onChanged: (val) => controller.selectedClientId.value = val!,
                  items: controller.clients
                      .map((c) => DropdownMenuItem<int>(
                            value: c['id'],
                            child: Text(c['nom']),
                          ))
                      .toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Sélectionner un client',
                  ),
                  validator: (val) =>
                      val == null ? 'Client requis' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: controller.sujetController,
                  decoration: const InputDecoration(
                    labelText: 'Sujet',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Sujet requis' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: controller.descriptionController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Description requise' : null,
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("Envoyer"),
                  onPressed: controller.submitReclamation,
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
