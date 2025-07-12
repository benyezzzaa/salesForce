// lib/features/clients/services/fiscal_ocr_service.dart

import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class FiscalOCRService {
  Future<String?> scanFiscalCode() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return null;

    final inputImage = InputImage.fromFilePath(image.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(inputImage);

    for (final line in result.text.split('\n')) {
      // Chercher un numéro fiscal de 13 chiffres (avec ou sans espaces)
      final match = RegExp(r'\b\d{1,4}(?:\s*\d{1,4}){12}\b').firstMatch(line);
      if (match != null) {
        String fiscalNumber = match.group(0)!;
        // Supprimer tous les espaces et caractères non numériques
        fiscalNumber = fiscalNumber.replaceAll(RegExp(r'[^\d]'), '');
        
        // Vérifier que le numéro final fait bien 13 chiffres
        if (fiscalNumber.length == 13 && RegExp(r'^\d{13}$').hasMatch(fiscalNumber)) {
          return fiscalNumber;
        }
      }
    }
    
    // Approche alternative: extraire tous les chiffres et prendre les 13 premiers
    final allDigits = result.text.replaceAll(RegExp(r'[^\d]'), '');
    if (allDigits.length >= 13) {
      return allDigits.substring(0, 13);
    }

    return null;
  }
}
