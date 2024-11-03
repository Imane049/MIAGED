import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> persistClothingItem({
  required String title,
  required String brand,
  required String size,
  required double price,
  required String category,
  required String imagePath,
}) async {
  await FirebaseFirestore.instance.collection('clothingItems').add({
    'title': title,
    'brand': brand,
    'size': size,
    'price': price,
    'category': category,
    'imagePath': imagePath,
  });
}
