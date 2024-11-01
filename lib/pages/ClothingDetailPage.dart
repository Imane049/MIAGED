import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../handlers/UserProvider.dart';

class ClothingDetailPage extends StatefulWidget {
  final Map<String, dynamic> clothingItem;

  const ClothingDetailPage({super.key, required this.clothingItem});

  @override
  _ClothingDetailPageState createState() => _ClothingDetailPageState();
}

class _ClothingDetailPageState extends State<ClothingDetailPage> {
  @override
  Widget build(BuildContext context) {
    final clothingItem = widget.clothingItem;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          clothingItem['title'],
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Center(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: DecorationImage(
                    image: NetworkImage(clothingItem['imagePath']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Product Title
            Text(
              clothingItem['title'],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Product Brand and Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  clothingItem['brand'],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
                Text(
                  'Category: ${clothingItem['category'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Product Price
            Text(
              '${clothingItem['price'].toString()} MAD',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),

            Text(
              'Size',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              clothingItem['size'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Add to Cart Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _addToCart(clothingItem['id']);
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Ajouter au panier'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to add item to cart in Firestore and update UserProvider
  Future<void> _addToCart(String itemId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userData?['id'];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User ID not found")),
      );
      return;
    }

    try {
      List<dynamic> currentCart = userProvider.userData?['cart'] ?? [];

      if (!currentCart.contains(itemId)) {
        currentCart.add(itemId);

        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'cart': currentCart,
        });

        userProvider.saveUserData({'cart': currentCart});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Item added to cart: ${widget.clothingItem['title']}")),
        );

        print('Cart updated successfully. Current cart items: $currentCart');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item is already in your cart.")),
        );
      }
    } catch (e) {
      print("Error adding item to cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add item to cart: $e")),
      );
    }
  }
}
