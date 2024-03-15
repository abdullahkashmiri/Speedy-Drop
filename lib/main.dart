import 'package:flutter/material.dart';
import 'package:speedydrop/Screens/Splash/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:speedydrop/firebase_options.dart'; // Importing your Firebase options file

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
    return MaterialApp(
      title: 'Speedy Drop',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const Splash_Screen(),
    );
  }
}
