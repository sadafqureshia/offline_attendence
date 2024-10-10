import 'package:firebase_core/firebase_core.dart';
import 'package:offline_attendence/firebase_options.dart';
import 'package:offline_attendence/pages/dashboard/Home-page.dart';
import 'package:offline_attendence/pages/log_in/login-page.dart';
import 'package:offline_attendence/pages/log_in/signup-page.dart';
import 'package:offline_attendence/utilts/Routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    // Handle the initialization error (optional)
    print("Firebase Initialization Error: $e");
    return; // Exit if initialization fails
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.lato().fontFamily,
      ),
      debugShowCheckedModeBanner: false, // Disable debug banner
      darkTheme: ThemeData(brightness: Brightness.dark),
      initialRoute: MyRoutes.homeRoute,
      routes: {
        MyRoutes.loginRoute: (context) => const LogInPage(),
        MyRoutes.homeRoute: (context) => const Homepage(),
        MyRoutes.registerRoute: (context) => const RegisterPage(),
      },
    );
  }
}