import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_client_controller.dart'; // 👈 adapte selon ton arborescence

class FiscalTextFieldWithCamera extends StatelessWidget {
  final AddClientController controller;

  const FiscalTextFieldWithCamera({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => TextFormField(
          controller: controller.fiscalNumberController,
          decoration: InputDecoration(
            labelText: 'Numéro fiscal *',
            border: const OutlineInputBorder(),
            suffixIcon: controller.isScanning.value
                ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.camera_alt),
                    tooltip: 'Scanner un numéro fiscal',
                    onPressed: controller.scanFiscalNumber,
                  ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 13,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Numéro fiscal requis';
            }
            if (!RegExp(r'^\d{13}$').hasMatch(value)) {
              return 'Le numéro fiscal doit contenir 13 chiffres';
            }
            return null;
          },
        ));
  }
}
