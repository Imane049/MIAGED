import 'package:flutter/material.dart';
import '../components/navigationBar.dart';
import '../components/clothingItem.dart';
import '../handlers/ClothingService.dart';

class ClothingList extends StatefulWidget {
  const ClothingList({super.key});

  @override
  _ClothingListState createState() => _ClothingListState();
}

class _ClothingListState extends State<ClothingList> {
  String selectedBrand = "All Brands"; // Default selection for the dropdown
  final List<Map<String, dynamic>> clothingItems = []; // List to store fetched items
  bool _isLoading = true; // To track loading state

  @override
  void initState() {
    super.initState();
    _fetchClothingItems();
  }

  Future<void> _fetchClothingItems() async {
    try {
      ClothingService clothingService = ClothingService();
      List<Map<String, dynamic>> fetchedItems = await clothingService.fetchAllClothingItems();
      setState(() {
        clothingItems.addAll(fetchedItems);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching clothing items: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title: Text(
          'Clothing List',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: clothingItems.length,
                itemBuilder: (context, index) {
                  final clothingItem = clothingItems[index];

                  // Filter items based on selected brand
                  if (selectedBrand != "All Brands" && clothingItem['brand'] != selectedBrand) {
                    return Container(); // Skip items not matching the selected brand
                  }

                  return ClothingItemCard(clothingItem: clothingItem);
                },
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation between tabs here
        },
      ),
    );
  }
}
