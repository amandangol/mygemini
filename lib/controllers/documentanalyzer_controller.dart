import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class DocumentAnalyzerController extends GetxController {
  final analysisTypeC = TextEditingController();

  var selectedFileName = ''.obs;
  var analysisResults = ''.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  PlatformFile? selectedFile;

  @override
  void onClose() {
    analysisTypeC.dispose();
    super.onClose();
  }

  Future<bool> storagePermission() async {
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    final int androidVersion = int.parse(androidInfo.version.release);
    bool havePermission = false;

    if (androidVersion >= 13) {
      final request = await [
        Permission.videos,
        Permission.photos,
      ].request();

      havePermission =
          request.values.every((status) => status == PermissionStatus.granted);
    } else {
      final status = await Permission.storage.request();
      havePermission = status.isGranted;
    }

    if (!havePermission) {
      await openAppSettings();
    }

    return havePermission;
  }

  Future<void> pickFile() async {
    try {
      // Request storage permission using the custom method
      var permissionGranted = await storagePermission();

      if (permissionGranted) {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        );

        if (result != null) {
          clearFields();

          selectedFile = result.files.first;
          selectedFileName.value = selectedFile!.name;
          errorMessage.value = ''; // Clear any previous error message
        } else {
          // User canceled the picker
          errorMessage.value = 'No file selected.';
        }
      } else {
        errorMessage.value = 'Storage permission is required to select files.';
      }
    } catch (e) {
      print('Error picking file: $e');
      errorMessage.value = 'Failed to pick file. Please try again.';
    }
  }

  Future<String> extractFileContent(PlatformFile file) async {
    final String path = file.path!;
    final String extension = file.extension?.toLowerCase() ?? '';

    switch (extension) {
      case 'pdf':
        final PdfDocument document =
            PdfDocument(inputBytes: await File(path).readAsBytes());
        PdfTextExtractor extractor = PdfTextExtractor(document);
        String text = extractor.extractText();
        document.dispose();
        return text;
      case 'txt':
      case 'csv':
      case 'md':
        return await File(path).readAsString();
      case 'doc':
      case 'docx':
        // For Word documents,  need a specific library
        throw UnimplementedError(
            'Word document parsing not implemented. Try .pdf, .txt, .csv and .md');
      default:
        throw UnsupportedError('Unsupported file type: $extension');
    }
  }

  Future<void> analyzeDocument() async {
    if (selectedFile == null) {
      errorMessage.value = 'Please select a document to analyze.';
      return;
    }

    if (analysisTypeC.text.isEmpty) {
      errorMessage.value = 'Please specify the type of analysis.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';
    analysisResults.value = '';

    try {
      // Extract the content of the selected file
      final String fileContent = await extractFileContent(selectedFile!);

      // Prepare the prompt for analysis
      final String prompt =
          'Analyze the following document content and ${analysisTypeC.text}. Provide a detailed response.\n\nDocument content:\n$fileContent';

      // Send the file content to the API for analysis
      String analysisContent = await APIs.geminiAPI(prompt);
      analysisResults.value = analysisContent;
    } catch (e) {
      print('Error analyzing document: $e');
      if (e is UnsupportedError) {
        errorMessage.value = e.message.toString();
      } else {
        errorMessage.value = 'Failed to analyze document. Please try again.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void clearFields() {
    selectedFile = null;
    selectedFileName.value = '';
    analysisTypeC.clear();
    analysisResults.value = '';
    errorMessage.value = '';
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied!',
      'Analysis results copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2C3E50).withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void shareContent(String text) {
    Share.share(text, subject: 'Document Analysis Results');
  }
}
