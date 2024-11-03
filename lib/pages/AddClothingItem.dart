import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:tp2/handlers/ClothesClassifier.dart'; // Import classifyImageFromUrl function
import 'package:tp2/handlers/AddClothesService.dart';
class AddClothingItem extends StatefulWidget {
  const AddClothingItem({super.key});

  @override
  _AddClothingItemState createState() => _AddClothingItemState();
}

class _AddClothingItemState extends State<AddClothingItem> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(text: '');

  File? _selectedImage; // To hold the selected image for mobile
  Uint8List? _webImage; // To hold the image for web
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  String? _imageUrl; // Hidden field for storing image URL

  Future<void> _pickImage() async {
    try {
      setState(() {
        _categoryController.clear();
      });

      if (kIsWeb) {
        // Web: Use file picker
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
        );
        if (result != null) {
          setState(() {
            _webImage = result.files.first.bytes;
          });
          print("Image selected from web.");

          // Upload the image to Firebase and get the URL
          String imageUrl = await _uploadImageToFirebaseWeb(result.files.first);

          // Get the category using the image URL
          String category = await classifyImageFromUrl(imageUrl);
          setState(() {
            _categoryController.text = category;
            _imageUrl = imageUrl;
          });
        } else {
          print("No image selected.");
        }
      } else {
        // Mobile (Android/iOS): Use ImagePicker
        final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
          print("Image selected: ${image.path}");

          // Upload the image to Firebase and get the URL
          String imageUrl = await _uploadImageToFirebaseMobile(_selectedImage!);

          // Get the category using the image URL
          String category = await classifyImageFromUrl(imageUrl);
          setState(() {
            _categoryController.text = category;
            _imageUrl = imageUrl;
          });
        } else {
          print("No image selected.");
        }
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String> _uploadImageToFirebaseWeb(PlatformFile file) async {
    try {
      print("Uploading image to Firebase (Web)...");
      Reference storageReference = FirebaseStorage.instance.ref().child('clothing_images/${file.name}');
      UploadTask uploadTask = storageReference.putData(file.bytes!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image URL obtained: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image to Firebase (Web): $e");
      rethrow;
    }
  }

  Future<String> _uploadImageToFirebaseMobile(File image) async {
    try {
      print("Uploading image to Firebase (Mobile)...");
      String fileName = path.basename(image.path);
      Reference storageReference = FirebaseStorage.instance.ref().child('clothing_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image URL obtained: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image to Firebase (Mobile): $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajouter un vêtement',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const SizedBox(height: 8),

             if (_selectedImage != null || _webImage != null)
              Column(
                children: [
                  Text(
                    "Selected Image:",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: DecorationImage(
                          image: kIsWeb
                              ? MemoryImage(_webImage!)
                              : FileImage(_selectedImage!) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
   const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Parcourir image'),
            ),
            const SizedBox(height: 30),
                         const SizedBox(height: 48),

            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Titre",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            
            const SizedBox(height: 16),

            TextFormField(
              controller: _sizeController,
              decoration: InputDecoration(
                labelText: "Taille",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: "Marque",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Prix",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: "Catégorie",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              readOnly: true,
            ),
            const SizedBox(height: 32),

          

           

            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (_imageUrl == null) {
                    print("Please upload an image before submitting.");
                    return;
                  }
                  try {
                    // Persist clothing item
                    await persistClothingItem(
                      title: _titleController.text,
                      brand: _brandController.text,
                      size: _sizeController.text,
                      price: double.parse(_priceController.text),
                      category: _categoryController.text,
                      imagePath: _imageUrl!,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Clothing item added successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );

                    _titleController.clear();
                    _sizeController.clear();
                    _brandController.clear();
                    _priceController.clear();
                    setState(() {
                      _imageUrl = null;
                      _selectedImage = null;
                      _webImage = null;
                      _categoryController.text = '';
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to add clothing item: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  "Valider",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
