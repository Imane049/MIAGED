import 'package:flutter/material.dart';
import '../components/navigationBar.dart';
import '../components/clothingItem.dart';
import '../handlers/ClothingService.dart';
import 'dart:ui';

class ClothingList extends StatefulWidget {
  const ClothingList({super.key});

  @override
  _ClothingListState createState() => _ClothingListState();
}

class _ClothingListState extends State<ClothingList> {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Acheter',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                ),
              ),
              // Main content area with loading or grid view
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: clothingItems.length,
                              itemBuilder: (context, index) {
                                final clothingItem = clothingItems[index];

                                // Filter items based on selected brand
                               
                                return ClothingItemCard(clothingItem: clothingItem);
                              },
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {        },
      ),
    );
  }
}
