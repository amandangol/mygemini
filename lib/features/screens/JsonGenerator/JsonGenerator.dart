// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

// class GeminiJsonGeneratorController extends GetxController {
//   final GenerativeModel _model;
//   final textController = TextEditingController();
//   final resultController = TextEditingController();
//   var isLoading = false.obs;

//   GeminiJsonGeneratorController()
//       : _model = GenerativeModel(
//           model: 'gemini-1.5-pro',
//           apiKey: 'AIzaSyBMLZpHDLMOyapj7Jx2iS8PkCLR5gIytT4',
//           generationConfig: GenerationConfig(
//             responseMimeType: 'application/json',
//           ),
//         );

//   Future<void> generateJsonContent() async {
//     if (textController.text.isEmpty) return;

//     isLoading.value = true;
//     try {
//       final prompt = textController.text;
//       final response = await _model.generateContent([Content.text(prompt)]);
//       resultController.text = response.text ?? 'No response generated';
//     } catch (e) {
//       resultController.text = 'Error: ${e.toString()}';
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> generateJsonWithSchema() async {
//     if (textController.text.isEmpty) return;

//     isLoading.value = true;
//     try {
//       final schema = Schema.array(
//         description: 'List of recipes',
//         items: Schema.object(
//           properties: {
//             'recipeName': Schema.string(
//               description: 'Name of the recipe.',
//               nullable: false,
//             ),
//           },
//           requiredProperties: ['recipeName'],
//         ),
//       );

//       final modelWithSchema = GenerativeModel(
//         model: 'gemini-1.5-pro',
//         apiKey: 'AIzaSyBMLZpHDLMOyapj7Jx2iS8PkCLR5gIytT4',
//         generationConfig: GenerationConfig(
//           responseMimeType: 'application/json',
//           responseSchema: schema,
//         ),
//       );

//       final prompt = textController.text;
//       final response =
//           await modelWithSchema.generateContent([Content.text(prompt)]);
//       resultController.text = response.text ?? 'No response generated';
//     } catch (e) {
//       resultController.text = 'Error: ${e.toString()}';
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }

// class GeminiJsonGeneratorView extends GetView<GeminiJsonGeneratorController> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Gemini JSON Generator')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: controller.textController,
//               decoration: InputDecoration(labelText: 'Enter your prompt'),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: controller.generateJsonContent,
//               child: Text('Generate JSON'),
//             ),
//             SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: controller.generateJsonWithSchema,
//               child: Text('Generate JSON with Schema'),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: Obx(() {
//                 if (controller.isLoading.value) {
//                   return Center(child: CircularProgressIndicator());
//                 }
//                 return TextField(
//                   controller: controller.resultController,
//                   maxLines: null,
//                   readOnly: true,
//                   decoration: InputDecoration(
//                     labelText: 'Generated JSON',
//                     border: OutlineInputBorder(),
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
