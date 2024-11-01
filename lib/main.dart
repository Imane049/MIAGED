import 'package:flutter/material.dart';
import 'pages/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'handlers/UserProvider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // (
  //   options: const FirebaseOptions(
  //     apiKey: "AIzaSyAxRPVxoj9WemyZoau4P03dGIjiCooFnLE",
  // authDomain: "projet2-9d413.firebaseapp.com",
  // projectId: "projet2-9d413",
  // storageBucket: "projet2-9d413.appspot.com",
  // messagingSenderId: "792586615267",
  // appId: "1:792586615267:web:7b79987991d39cbb81c8d6",
  // measurementId: "G-Z9181NFDWS"
  //   ),
  // );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,

        // Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 255, 28, 138),
          brightness: Brightness.light,
        ),

        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: GoogleFonts.oswald(
            fontSize: 30,
            fontStyle: FontStyle.italic,
          ),
          bodyMedium: GoogleFonts.merriweather(),
          displaySmall: GoogleFonts.pacifico(),
        ),
      ),
      home: const LoginPage(),
    );
  }
}
