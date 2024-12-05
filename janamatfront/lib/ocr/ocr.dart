import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRPage extends StatefulWidget {
  @override
  _OCRPageState createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  File? _imageFile1;
  File? _imageFile2;
  bool _isVerificationSuccessful = false;
  String _verificationMessage = '';
  Map<String, dynamic> _extractedData = {}; // Add this state variable

  // Pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source, int imageNumber) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        if (imageNumber == 1) {
          _imageFile1 = File(pickedFile.path);
        } else {
          _imageFile2 = File(pickedFile.path);
        }
      });
    }
  }

  // Process the image with Firebase ML Kit
  Future<void> _processImage(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      final extractedData = _extractDataFromText(recognizedText.text);
      print('Extracted Data: $extractedData'); // Print the extracted data
      setState(() {
        _extractedData = extractedData; // Update the state with extracted data
      });
      final isValid = validateCitizenship(extractedData);
      setState(() {
        _isVerificationSuccessful = isValid;
        _verificationMessage = isValid ? 'Verification Successful' : 'Verification Failed';
      });
      Navigator.pop(context, isValid);
    } catch (e) {
      setState(() {
        _verificationMessage = 'Error recognizing text: $e';
      });
    } finally {
      textRecognizer.close();
    }
  }

  Map<String, dynamic> _extractDataFromText(String text) {
    // Improved extraction logic
    final lines = text.split('\n');
    String citizenshipNumber = '';
    String fullName = '';
    String dateOfBirth = '';
    String permanentAddress = '';

    for (var line in lines) {
      if (line.contains('Citizenship Certificate number')) {
        citizenshipNumber = line.split(':').last.trim();
      } else if (line.contains('Full name')) {
        fullName = line.split(':').last.trim();
      } else if (line.contains('Date of Birth')) {
        dateOfBirth = line.split(':').last.trim();
      } else if (line.contains('Permanent Address')) {
        permanentAddress = line.split(':').last.trim();
      } else if (line.contains(RegExp(r'^\d{2}-\d{2}-\d{2}-\d{5}$'))) {
        citizenshipNumber = line.trim();
      }
    }

    return {
      'citizenshipNumber': citizenshipNumber,
      'fullName': fullName,
      'dateOfBirth': dateOfBirth,
      'permanentAddress': permanentAddress,
    };
  }

  bool validateCitizenship(Map<String, dynamic> extractedData) {
    // Extracted data from OCR
    String citizenshipNumber = extractedData['citizenshipNumber'] ?? '';
    String fullName = extractedData['fullName'] ?? '';
    String dateOfBirth = extractedData['dateOfBirth'] ?? '';
    String permanentAddress = extractedData['permanentAddress'] ?? '';

    // Step 1: Validate Citizenship Number Format
    final regExp = RegExp(r'^\d{2}-\d{2}-\d{2}-\d{5}$'); // XX-XX-YY-ZZZZZ
    if (!regExp.hasMatch(citizenshipNumber)) {
      print('Invalid citizenship number format');
      return false;
    }

    // Step 2: Validate Other Fields
    if (fullName.isEmpty || dateOfBirth.isEmpty || permanentAddress.isEmpty) {
      print('Missing required fields');
      return false;
    }

    print('Citizenship is valid');
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Citizenship Verification')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(children: [
                  Text('Citizenship Front',style: TextStyle(fontWeight: FontWeight.bold),),
                GestureDetector(
                  onTap: () => _showImageSourceDialog(1),
                  child: _imageFile1 != null
                      ? Image.file(_imageFile1!, width: 100, height: 100)
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.add_a_photo),
                        ),
                ),],),
                Column(children: [
                  Text('Citizenship Back',style: TextStyle(fontWeight: FontWeight.bold),),
                GestureDetector(
                  onTap: () => _showImageSourceDialog(2),
                  child: _imageFile2 != null
                      ? Image.file(_imageFile2!, width: 100, height: 100)
                      : Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.add_a_photo),
                        ),
                ),],),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _extractData,
              child: Text('Extract Data'),
            ),
            SizedBox(height: 20),
            if (_verificationMessage.isNotEmpty)
              Text(
                _verificationMessage,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isVerificationSuccessful ? Colors.green : Colors.red,
                ),
              ),
            if (_extractedData.isNotEmpty) ...[
              Text('Extracted Data:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Citizenship Number: ${_extractedData['citizenshipNumber']}'),
              Text('Full Name: ${_extractedData['fullName']}'),
              Text('Date of Birth: ${_extractedData['dateOfBirth']}'),
              Text('Permanent Address: ${_extractedData['permanentAddress']}'),
            ],
          ],
        ),
      ),
    );
  }

  void _extractData() {
    if (_imageFile2 != null) {
      _processImage(_imageFile2!);
    } else {
      setState(() {
        _verificationMessage = 'Please provide the back side of the citizenship card';
      });
    }
  }

  void _showImageSourceDialog(int imageNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, imageNumber);
            },
            child: Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera, imageNumber);
            },
            child: Text('Camera'),
          ),
        ],
      ),
    );
  }
}
