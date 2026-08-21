import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MlService {
  Interpreter? interpreter;

  // Load TFLite model
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model.tflite');
    print("Model Loaded");
  }

  // Predict the class index for a given image
  Future<int> predict(File imageFile) async {
    if (interpreter == null) {
      print("Model not loaded!");
      return -1;
    }

    // Decode image and resize to 224x224
    img.Image? image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) throw Exception("Cannot decode image");
    img.Image resized = img.copyResize(image, width: 224, height: 224);

    // Prepare input buffer [1, 224, 224, 3] as Float32
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(224, (_) => List.filled(3, 0.0)),
      ),
    );

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        var pixel = resized.getPixel(x, y);
        input[0][y][x][0] = pixel.r / 255.0; // Red
        input[0][y][x][1] = pixel.g / 255.0; // Green
        input[0][y][x][2] = pixel.b / 255.0; // Blue
      }
    }

    // Prepare output buffer (make sure shape matches your model, here 10 classes)
    var output = List.filled(4, 0.0).reshape([1, 4]);

    // Run inference
    interpreter!.run(input.reshape([1, 224, 224, 3]), output);

    print("Raw output: ${output[0]}");

    // Get index of max probability
    int maxIndex = 0;
    double maxProb = output[0][0];
    for (int i = 0; i < output[0].length; i++) {
      if (output[0][i] > maxProb) {
        maxProb = output[0][i];
        maxIndex = i;
      }
    }

    print("Predicted class index: $maxIndex");
    return maxIndex;
  }
}
