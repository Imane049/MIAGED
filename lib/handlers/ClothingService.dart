import 'package:cloud_firestore/cloud_firestore.dart';


class ClothingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchAllClothingItems() async {
    List<Map<String, dynamic>> clothingItems = [];

    try {
      // Fetch all documents from the 'clothingItems' collection
      QuerySnapshot snapshot = await _firestore.collection('clothingItems').get();

      for (var doc in snapshot.docs) {
        // Convert each document into a map and add it to the list
        Map<String, dynamic> clothingItem = doc.data() as Map<String, dynamic>;
        clothingItem['id'] = doc.id; // Include the document ID
        clothingItems.add(clothingItem);
      }

      print('Fetched ${clothingItems.length} clothing items successfully.');
      
      // Debugging: Log the fetched items
      for (var item in clothingItems) {
        print("Fetched item: ${item.toString()}");
      }

      print('Total items fetched: ${clothingItems.length}');
    } catch (e) {
      print('Error fetching clothing items: $e');
    }

    return clothingItems;
  }

  Future<Map<String, dynamic>?> fetchClothingItemById(String itemId) async {
    try {
      // Fetch the document with the specified ID from the 'clothingItems' collection
      DocumentSnapshot doc = await _firestore.collection('clothingItems').doc(itemId).get();

      if (doc.exists) {
        Map<String, dynamic> clothingItem = doc.data() as Map<String, dynamic>;
        clothingItem['id'] = doc.id; // Include the document ID for reference

        print('Fetched item: ${clothingItem.toString()}');
        return clothingItem;
      } else {
        print('No item found with ID: $itemId');
        return null;
      }
    } catch (e) {
      print('Error fetching clothing item by ID: $e');
      return null;
    }
  }
  
}
