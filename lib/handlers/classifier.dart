import 'dart:io';
import 'package:tflite/tflite.dart';

Future<void> loadModel() async {
  try {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite", 
      labels: "assets/labels.txt",  
    );
  } catch (e) {
    print("Error loading model: $e");
  }
}

void clothingItemCategory(File image) async {
  try {
    var output = await Tflite.runModelOnImage(
      path: '../lib/assets/téléchargementveste.jpeg',
      numResults: 4, 
      threshold: 0.5, 
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (output != null && output.isNotEmpty) {
      String label = output[0]["label"];
      print("Category: $label");
    } else {
      print("Could not classify image");
    }
  } catch (e) {
    print("Error classifying image: $e");
    print("Error during classification");
  }
}
