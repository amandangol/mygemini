import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mygemini/data/services/api_service.dart';
import 'package:mygemini/features/screens/document_analyzer/model/docbot_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentAnalyzerController extends GetxController {
  final userInputController = TextEditingController();

  var analyzerMessages = <AnalyzerMessage>[].obs;
  var isLoading = false.obs;

  var currentState = AnalyzerState.askingForFile.obs;
  var selectedFile = Rx<PlatformFile?>(null);
  var analysisType = ''.obs;
  var lastAnalysisResult = ''.obs;

  late SharedPreferences _prefs;

  static const int maxConversationLength = 50;
  var isMaxLengthReached = false.obs;

  @override
  void onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    _loadConversation();
    if (analyzerMessages.isEmpty) {
      _addBotMessage(
          "Hi! I'm DocAnalyzer. Please upload a document you'd like me to analyze.");
    }
    _checkMaxLength();
  }

  @override
  void onClose() {
    userInputController.dispose();
    super.onClose();
  }

  void _loadConversation() {
    final savedMessages = _prefs.getStringList('analyzerMessages');
    if (savedMessages != null) {
      analyzerMessages.value = savedMessages
          .map((e) => AnalyzerMessage.fromJson(json.decode(e)))
          .toList();
      if (analyzerMessages.length > maxConversationLength) {
        analyzerMessages.value = analyzerMessages
            .sublist(analyzerMessages.length - maxConversationLength);
      }
      currentState.value =
          AnalyzerState.values[_prefs.getInt('currentState') ?? 0];
      analysisType.value = _prefs.getString('analysisType') ?? '';
      lastAnalysisResult.value = _prefs.getString('lastAnalysisResult') ?? '';
    }
    _checkMaxLength();
  }

  void _checkMaxLength() {
    isMaxLengthReached.value = analyzerMessages.length >= maxConversationLength;
  }

  Future<void> _saveConversation() async {
    if (analyzerMessages.length > maxConversationLength) {
      analyzerMessages.value = analyzerMessages
          .sublist(analyzerMessages.length - maxConversationLength);
    }
    await _prefs.setStringList('analyzerMessages',
        analyzerMessages.map((e) => json.encode(e.toJson())).toList());
    await _prefs.setInt('currentState', currentState.value.index);
    await _prefs.setString('analysisType', analysisType.value);
    await _prefs.setString('lastAnalysisResult', lastAnalysisResult.value);
    _checkMaxLength();
  }

  Future<void> sendMessage() async {
    if (userInputController.text.isEmpty || isMaxLengthReached.value) return;

    final userMessage = userInputController.text;
    _addUserMessage(userMessage);
    userInputController.clear();

    isLoading.value = true;

    try {
      switch (currentState.value) {
        case AnalyzerState.askingAnalysisType:
          analysisType.value = userMessage;
          currentState.value = AnalyzerState.analyzingDocument;
          await _analyzeDocument();
          break;
        case AnalyzerState.analyzingDocument:
          await _handlePostAnalysisInteraction(userMessage);
          break;
        default:
          _addBotMessage(
              "I'm not sure how to respond to that. You can upload a document or ask for a specific analysis.");
      }
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I encountered an error. Can you please try again?");
    } finally {
      isLoading.value = false;
      await _saveConversation();
    }
  }

  Future<void> pickFile() async {
    var permissionGranted = await _storagePermission();
    if (!permissionGranted) {
      _addBotMessage(
          "I'm sorry, but I need storage permission to access files. Please grant the permission and try again.");
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'csv', 'md'],
    );

    if (result != null) {
      selectedFile.value = result.files.first;
      _addUserMessage("Uploaded file: ${selectedFile.value!.name}");
      _addBotMessage(
          "Great! I've received your file. What type of analysis would you like me to perform?");
      currentState.value = AnalyzerState.askingAnalysisType;
    } else {
      _addBotMessage(
          "No file was selected. Please try uploading a document again.");
    }
    await _saveConversation();
  }

  Future<void> _analyzeDocument() async {
    _addBotMessage(
        "Alright, I'm analyzing the document now. Please wait a moment...");

    try {
      final String fileContent = await _extractFileContent(selectedFile.value!);
      final List<Map<String, String>> prompt = [
        {
          "role": "user",
          "content":
              'Analyze the following document content and ${analysisType.value}. Provide a detailed response.\n\nDocument content:\n$fileContent'
        }
      ];

      String analysisContent = await APIs.geminiAPI(prompt);
      lastAnalysisResult.value = analysisContent;
      _addBotMessage(analysisContent, isAnalysis: true);
      _addBotMessage(
          "Here's the analysis result. Would you like me to explain any part of it, perform a different type of analysis, or analyze a new document?");
    } catch (e) {
      _addBotMessage(
          "I'm sorry, I couldn't analyze the document. The error was: ${e.toString()}");
    }
  }

  Future<void> _handlePostAnalysisInteraction(String userMessage) async {
    if (userMessage.toLowerCase().contains('explain')) {
      _addBotMessage(
          "Certainly! I'd be happy to explain the analysis. Which part would you like me to elaborate on?");
    } else if (userMessage.toLowerCase().contains('different analysis') ||
        userMessage.toLowerCase().contains('new analysis')) {
      currentState.value = AnalyzerState.askingAnalysisType;
      _addBotMessage(
          "Sure, I can perform a different type of analysis. What kind of analysis would you like me to do now?");
    } else if (userMessage.toLowerCase().contains('new document')) {
      await resetConversation();
    } else {
      List<Map<String, String>> prompt = [
        {
          "role": "user",
          "content":
              'The user asked: "${userMessage}" in response to this document analysis:\n\n${lastAnalysisResult.value}\n\nProvide a helpful response:'
        }
      ];
      String response = await APIs.geminiAPI(prompt);
      _addBotMessage(response);
      _addBotMessage(
          "Is there anything else you'd like to know about the analysis, or would you like to analyze a new document?");
    }
  }

  Future<bool> _storagePermission() async {
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    final int androidVersion = int.parse(androidInfo.version.release);

    if (androidVersion >= 13) {
      final request = await [Permission.videos, Permission.photos].request();
      return request.values
          .every((status) => status == PermissionStatus.granted);
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  Future<String> _extractFileContent(PlatformFile file) async {
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
        throw UnimplementedError(
            'Word document parsing not implemented. Try .pdf, .txt, .csv and .md');
      default:
        throw UnsupportedError('Unsupported file type: $extension');
    }
  }

  void _addUserMessage(String message) {
    analyzerMessages.add(AnalyzerMessage(content: message, isUser: true));
    _saveConversation();
  }

  void _addBotMessage(String message, {bool isAnalysis = false}) {
    analyzerMessages.add(AnalyzerMessage(
        content: message, isUser: false, isAnalysis: isAnalysis));
    _saveConversation();
  }

  Future<void> resetConversation() async {
    analyzerMessages.clear();
    currentState.value = AnalyzerState.askingForFile;
    selectedFile.value = null;
    analysisType.value = '';
    lastAnalysisResult.value = '';
    isMaxLengthReached.value = false;
    _addBotMessage(
        "Let's start over! Please upload a document you'd like me to analyze.");
    await _saveConversation();
  }
}

enum AnalyzerState {
  askingForFile,
  askingAnalysisType,
  analyzingDocument,
}
