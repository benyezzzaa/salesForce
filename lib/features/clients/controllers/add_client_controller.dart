// lib/features/clients/controllers/add_client_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/fiscal_ocr_service.dart';
import '../widgets/fiscal_code_scanner_page.dart';

class AddClientController extends GetxController {
  final fiscalNumberController = TextEditingController();
  final isScanning = false.obs;

  final FiscalOCRService _ocrService = FiscalOCRService();

  Future<void> scanFiscalNumber() async {
    isScanning.value = true;
    try {
      final code = await Get.to(() => const FiscalCodeScannerPage());
      if (code != null && code is String) {
        fiscalNumberController.text = code;
      }
    } finally {
      isScanning.value = false;
    }
  }

  @override
  void onClose() {
    fiscalNumberController.dispose();
    super.onClose();
  }
}
