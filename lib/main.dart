import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/loading_screen.dart';
import 'features/auth/login_page.dart'; // Import WAJIB agar rute kenal
import 'features/auth/register_page.dart'; // Import WAJIB
import 'features/auth/complete_profile_page.dart'; // Import WAJIB
import 'pages/home_page.dart'; // Import WAJIB

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LoveSpaceApp());
}

class LoveSpaceApp extends StatelessWidget {
  const LoveSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Love Space',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pinkAccent,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const LoadingScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/complete-profile': (context) => const CompleteProfilePage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}