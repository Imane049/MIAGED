import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ModelService {
  Interpreter? _interpreter;
  final List<String> _labels = ["Pantalon", "T-shirt", "Veste", "Chaussures"];

  // Constructor to load the model once when the service is created
  ModelService() {
    _loadModel();
  }

  // Load the TensorFlow Lite model from a local file path
  Future<void> _loadModel() async {
    try {
      final modelPath = '/mnt/data/model_unquant.tflite';
      _interpreter = await Interpreter.fromFile(File(modelPath));
      print("Model loaded successfully from $modelPath.");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  // Download image from URL and save it to a temporary file
  Future<File> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final documentDirectory = await getTemporaryDirectory();
    final filePath = path.join(documentDirectory.path, path.basename(url));

    final file = File(filePath);
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  List<List<List<List<double>>>> _preprocessImage(File imageFile) {
    final image = img.decodeImage(imageFile.readAsBytesSync())!;
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    // Prepare input structure with a batch dimension [1, 224, 224, 3]
    final input = List.generate(1, (b) => List.generate(224, (x) => List.generate(224, (y) => List.filled(3, 0.0))));
    
    for (int x = 0; x < 224; x++) {
      for (int y = 0; y < 224; y++) {
        final pixel = resizedImage.getPixel(x, y);
        final red = pixel.r;
        final green = pixel.g;
        final blue = pixel.b;

        input[0][x][y][0] = red / 255.0;
        input[0][x][y][1] = green / 255.0;
        input[0][x][y][2] = blue / 255.0;
      }
    }
    return input;
  }

  // Function to predict class from image URL and return the label
 Future<String> predictClassFromUrl(String url) async {
  // Ensure model is loaded
  if (_interpreter == null) {
    print("Model not loaded yet.");
    await _loadModel();
  }

  try {
    // Download and preprocess image
    File imageFile = await _downloadImage(url);
    var input = _preprocessImage(imageFile);

    // Define output structure and run inference
    var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter?.run(input, output);

    // Debugging: Print the raw output to inspect confidence scores
    print("Raw model output: $output");

    // Cast output to List<double> to avoid dynamic type issues
    List<double> outputList = output[0].map((e) => e as double).toList();

    // Find the top label index and map it to the corresponding label
    int topLabelIndex = outputList.indexOf(outputList.reduce((double curr, double next) => curr > next ? curr : next));
    String label = _labels[topLabelIndex];

    // Print the predicted label to the console
    print("Predicted label: $label");

    return label;
  } catch (e) {
    print("Error predicting class: $e");
    return "Error during classification";
  }
}

}
