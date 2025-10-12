import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';
import './auth/auth_gate.dart';
import './auth/auth_service.dart';
import './theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService(FirebaseAuth.instance);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider<AuthService>.value(value: authService),
        StreamProvider<User?>.value(
          value: authService.authStateChanges,
          initialData: null,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Using a more sophisticated slate blue as the seed color
    const Color primarySeedColor = Color(0xFF005f73);

    // Using Montserrat for titles and Lato for body text for a modern and readable feel
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.montserrat(fontSize: 57, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.montserrat(fontSize: 45, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.bold),
      labelMedium: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold),
      labelSmall: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.bold),
    );

    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );

    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor.withAlpha(200), // Adjusted for a nice dark theme effect
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return MaterialApp(
      title: 'Inventario App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}
