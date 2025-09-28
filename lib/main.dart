import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import './firebase_options.dart';
import './login_screen.dart';
import './home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primarySeedColor = Colors.teal;

    return MaterialApp(
      title: 'Qrden', // App title changed
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primarySeedColor,
          brightness: Brightness.light,
        ),
        textTheme: TextTheme(
          displaySmall: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.bold),
          displayLarge: GoogleFonts.montserrat(fontSize: 57, fontWeight: FontWeight.bold),
          titleLarge: GoogleFonts.lato(fontSize: 22, fontWeight: FontWeight.bold),
          bodyMedium: GoogleFonts.roboto(fontSize: 14),
          labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primarySeedColor,
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: primarySeedColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withAlpha(26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[200],
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
