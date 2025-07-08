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
      final match = RegExp(r'\d{13}').firstMatch(line);
      if (match != null) return match.group(0);
    }

    return null;
  }
}
