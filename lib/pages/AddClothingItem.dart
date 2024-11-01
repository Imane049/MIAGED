import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import '../handlers/classifier.dart'; // Import the helper file

class AddClothingItem extends StatefulWidget {
  const AddClothingItem({super.key});

  @override
  _AddClothingItemState createState() => _AddClothingItemState();
}

class _AddClothingItemState extends State<AddClothingItem> {
  // Controllers for form fields
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController =
      TextEditingController(text: 'Pantalon'); // Example fixed category

  File? _selectedImage; // To hold the selected image
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  String? _imageUrl; // Hidden field for storing image URL

  Future<void> _pickImage() async {
    try {
      print("Picking image from gallery...");
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        print("Image selected: ${image.path}");

        // Use await to get the result from the async function
        print("Calling clothingItemCategory function...");
        clothingItemCategory(_selectedImage!);

        // Upload the image to Firebase Storage
        print("Uploading image to Firebase...");
        String imageUrl = await _uploadImageToFirebase(_selectedImage!);
        print("Image uploaded successfully. URL: $imageUrl");
        
        // Store the image URL in the hidden field
        setState(() {
          _imageUrl = imageUrl;
        });

      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    try {
      print("Getting file name...");
      // Get the file name
      String fileName = path.basename(image.path);
      // Reference to the Firebase Storage bucket
      Reference storageReference =
          FirebaseStorage.instance.ref().child('clothing_images/$fileName');
      // Upload the image to the reference
      UploadTask uploadTask = storageReference.putFile(image);
      // Wait for the upload to complete
      print("Uploading file...");
      TaskSnapshot snapshot = await uploadTask;
      // Get the image download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print("Image URL obtained: $downloadUrl");
      return downloadUrl;
    } catch (e) {
      print("Error uploading image to Firebase: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Clothing Item',
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
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Size Field
            TextFormField(
              controller: _sizeController,
              decoration: InputDecoration(
                labelText: "Size",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Brand Field
            TextFormField(
              controller: _brandController,
              decoration: InputDecoration(
                labelText: "Brand",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Price Field (digits only)
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Price",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: false, signed: false),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Category Field (read-only)
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: "Category",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Image Upload Section
            Text(
              "Image",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload from Device'),
            ),
            const SizedBox(height: 16),

            // Display selected image (if any)
            if (_selectedImage != null)
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
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for the logic part
                  print("Submit new clothing item with image URL: $_imageUrl");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  "Add Clothing Item",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
