import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  // Cloudinary details
  final String cloudName = 'dzcrrgzs4';
  final String apiKey = '544823886844589';
  final String apiSecret = 'dF2CiAr0-9GEG8j6ge0cOufNSoI';
  final String uploadPreset = 'myPreset';

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    var request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['timestamp'] = timestamp
      ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      final String imageUrl = jsonResponse['secure_url'];
      print("Uploaded image URL: $imageUrl");
    } else {
      print('Failed to upload image');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cloudinary Image Upload'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image == null
                ? Text("No image selected.")
                : Image.file(_image!),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Pick Image"),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text("Upload Image"),
            ),
          ],
        ),
      ),
    );
  }
}
