import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

    final Timestamp? anniversaireTimestamp =
        _anniversaire != null ? Timestamp.fromDate(_anniversaire!) : null;

    final updatedData = {
      'adresse': _addressController.text.trim(),
      'codePostal': int.tryParse(_postalCodeController.text.trim()) ?? 0,
      'ville': _cityController.text.trim(),
      'anniversaire': anniversaireTimestamp,
      'password': _passwordController.text.trim(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(updatedData);

      userProvider.setUserData(userId, {
        ...?userProvider.userData,
        ...updatedData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Changes saved successfully"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save changes: $e"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
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

  Widget _buildInputField({
    required String label,
    required TextEditingController? controller,
    bool readOnly = false,
    bool isPassword = false,
    VoidCallback? onTap,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        obscureText: isPassword && _obscurePassword,
        onTap: onTap,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;
    String formattedAnniversaire = _anniversaire != null
        ? DateFormat('dd/MM/yyyy').format(_anniversaire!)
        : "Select Date";

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Mon profil",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              Provider.of<UserProvider>(context, listen: false).clearUserData();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout_rounded),
            label: Text(
              "Se déconnecter",
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                       
                        const SizedBox(height: 24),
                        _buildInputField(
                          label: "Login",
                          controller: TextEditingController(
                              text: userData?['username'] ?? "N/A"),
                          readOnly: true,
                        ),
                        _buildInputField(
                          label: "Password",
                          controller: _passwordController,
                          isPassword: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        _buildInputField(
                          label: "Anniversaire",
                          controller:
                              TextEditingController(text: formattedAnniversaire),
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          suffixIcon: Icon(
                            Icons.calendar_today_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                         const SizedBox(height: 24),
                        _buildInputField(
                          label: "Adresse",
                          controller: _addressController,
                        ),
                        _buildInputField(
                          label: "Code Postal",
                          controller: _postalCodeController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        _buildInputField(
                          label: "Ville",
                          controller: _cityController,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Valider",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                                const SizedBox(height: 14),

                 ElevatedButton(
                  onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClothingItem()),
          );
        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Ajouter un vêtement",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

     
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
      ),
    );
  }
}