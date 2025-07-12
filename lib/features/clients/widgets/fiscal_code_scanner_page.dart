import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class FiscalCodeScannerPage extends StatefulWidget {
  const FiscalCodeScannerPage({super.key});

  @override
  State<FiscalCodeScannerPage> createState() => _FiscalCodeScannerPageState();
}

class _FiscalCodeScannerPageState extends State<FiscalCodeScannerPage> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;
  String _detectedText = '';

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _detectedText = '';
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );

      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      setState(() {
        _detectedText = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Debug: afficher le texte reconnu
      print('🔍 Texte reconnu par l\'OCR: "${recognizedText.text}"');

      // Chercher un numéro fiscal de 13 chiffres (avec ou sans espaces)
      // Regex plus flexible pour détecter différents formats
      final fiscalPattern = RegExp(r'\b\d{1,4}(?:\s*\d{1,4}){12}\b');
      final matches = fiscalPattern.allMatches(recognizedText.text);

      if (matches.isNotEmpty) {
        String fiscalNumber = matches.first.group(0)!;
        // Supprimer tous les espaces et caractères non numériques
        fiscalNumber = fiscalNumber.replaceAll(RegExp(r'[^\d]'), '');
        
        // Vérifier que le numéro final fait bien 13 chiffres
        if (fiscalNumber.length == 13 && RegExp(r'^\d{13}$').hasMatch(fiscalNumber)) {
          setState(() {
            _detectedText = 'Numéro détecté: $fiscalNumber';
          });
          
          // Retourner le numéro fiscal après un court délai
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            Navigator.pop(context, fiscalNumber);
          }
        } else {
          setState(() {
            _detectedText = 'Numéro détecté mais invalide (${fiscalNumber.length} chiffres): ${matches.first.group(0)}';
          });
        }
      } else {
        // Essayer une approche plus permissive
        final allDigits = recognizedText.text.replaceAll(RegExp(r'[^\d]'), '');
        if (allDigits.length >= 13) {
          // Prendre les 13 premiers chiffres
          final potentialFiscal = allDigits.substring(0, 13);
          setState(() {
            _detectedText = 'Numéro potentiel détecté: $potentialFiscal (approche alternative)';
          });
          
          // Retourner le numéro fiscal après un court délai
          await Future.delayed(const Duration(milliseconds: 1000));
          if (mounted) {
            Navigator.pop(context, potentialFiscal);
          }
        } else {
          setState(() {
            _detectedText = 'Aucun numéro fiscal de 13 chiffres détecté. Texte reconnu: "${recognizedText.text}"';
          });
        }
      }
    } catch (e) {
      setState(() {
        _detectedText = 'Erreur de traitement: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner le numéro fiscal', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.lightBlue],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de caméra
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Instructions
              const Text(
                'Prenez une photo du numéro fiscal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              const Text(
                'Assurez-vous que le numéro de 13 chiffres\nest bien visible et lisible',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Bouton de scan
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _takePicture,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text('Traitement en cours...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt),
                            SizedBox(width: 10),
                            Text(
                              'Prendre une photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Texte détecté
              if (_detectedText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _detectedText,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Conseil: Assurez-vous que le numéro fiscal est bien visible et lisible sur la photo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}