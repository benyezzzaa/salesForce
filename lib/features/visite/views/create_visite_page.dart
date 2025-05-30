import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/visite_controller.dart';
import '../models/client_model.dart';
import '../models/raison_model.dart';

class CreateVisitePage extends StatelessWidget {
  const CreateVisitePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisiteController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Visite'),
        backgroundColor: Colors.indigo.shade600,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(
            child: Text(
              controller.error.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDatePicker(context, controller),
              const SizedBox(height: 20),
              _buildClientDropdown(controller),
              const SizedBox(height: 20),
              _buildRaisonDropdown(controller),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  final success = await controller.createVisite();
                  // La navigation et le snackbar sont maintenant gérés dans le contrôleur après la création du circuit.
                  // if (success) {
                  //   Get.back(result: true);
                  //   Get.snackbar(
                  //     'Succès',
                  //     'Visite créée avec succès',
                  //     backgroundColor: Colors.green,
                  //     colorText: Colors.white,
                  //   );
                  // }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Créer la visite',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDatePicker(BuildContext context, VisiteController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date de visite',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: controller.selectedDate.value,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  controller.setDate(date);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${controller.selectedDate.value.day}/${controller.selectedDate.value.month}/${controller.selectedDate.value.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDropdown(VisiteController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Client',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<ClientModel>(
              value: controller.selectedClient,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: controller.clients.map((client) {
                return DropdownMenuItem(
                  value: client,
                  child: Text(client.fullName),
                );
              }).toList(),
              onChanged: (client) => controller.setClient(client),
              hint: const Text('Sélectionnez un client'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRaisonDropdown(VisiteController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Raison de visite',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<RaisonModel>(
              value: controller.selectedRaison,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              items: controller.raisons.map((raison) {
                return DropdownMenuItem(
                  value: raison,
                  child: Text(raison.nom),
                );
              }).toList(),
              onChanged: (raison) => controller.setRaison(raison),
              hint: const Text('Sélectionnez une raison'),
            ),
          ],
        ),
      ),
    );
  }
} 