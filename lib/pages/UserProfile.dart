import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Added import for DateFormat
import '../handlers/UserProvider.dart';
import '../pages/LoginPage.dart';
import '../pages/AddClothingItem.dart';
import 'package:flutter/services.dart';
import '../components/navigationBar.dart';


class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Controllers for editable fields
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  DateTime? _anniversaire;

  @override
  void initState() {
    super.initState();
    final userData = Provider.of<UserProvider>(context, listen: false).userData;
    _addressController.text = userData?['adresse'] ?? "";
    _postalCodeController.text = (userData?['codePostal'] ?? 0).toString();
    _cityController.text = userData?['ville'] ?? "";
    _passwordController.text = userData?['password'] ?? "";
    _anniversaire = userData?['anniversaire'] != null
        ? (userData?['anniversaire'] as Timestamp).toDate()
        : null;
  }

  Future<void> _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.userData?['id'];

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: User ID not found")),
      );
      return;
    }

    // Convert _anniversaire to Timestamp if it's not null
    final Timestamp? anniversaireTimestamp =
        _anniversaire != null ? Timestamp.fromDate(_anniversaire!) : null;

    // Prepare the updated data
    final updatedData = {
      'adresse': _addressController.text.trim(),
      'codePostal': int.tryParse(_postalCodeController.text.trim()) ?? 0,
      'ville': _cityController.text.trim(),
      'anniversaire': anniversaireTimestamp,
      'password': _passwordController.text.trim(),
    };

    try {
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updatedData);

      // Update local user data in the provider
      userProvider.setUserData(userId, {
        ...?userProvider.userData,
        ...updatedData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Changes saved successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save changes: $e")),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _anniversaire ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _anniversaire) {
      setState(() {
        _anniversaire = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;

    String formattedAnniversaire = _anniversaire != null
        ? DateFormat('dd/MM/yyyy').format(_anniversaire!)
        : "Select Date";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Mon profil",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).clearUserData();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: Text(
              "Se déconnecter",
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Displaying Login field as read-only
            TextFormField(
              initialValue: userData?['username'] ?? "N/A",
              decoration: InputDecoration(
                labelText: "Login",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),

            // Editable Password field with obfuscation toggle
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Editable Birthday field with calendar picker
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: "Anniversaire",
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  controller: TextEditingController(text: formattedAnniversaire),
                  readOnly: true,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Editable Address field
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Adresse",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),

            // Editable Code Postal field (digits only)
            TextFormField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: "Code Postal",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),

            // Editable City field
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: "Ville",
                labelStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 30),

            // Save Changes Button
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(
                  "Valider",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClothingItem()),
          );
        },
        label: const Text('Ajouter un vêtement'),
        icon: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    );
  }
}
