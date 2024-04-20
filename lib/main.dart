import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speedydrop/Models/User/user.dart';
import 'package:speedydrop/Screens/Splash/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:speedydrop/Services/Auth/auth.dart';
import 'package:speedydrop/firebase_options.dart';


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
    return StreamProvider<Current_User?>.value(
      initialData: null,
      value: Auth_Service().user,
      catchError: (_,__) => null,
      child: MaterialApp(
        title: 'Speedy Drop',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        // home: const MapScreen(),


        home: const Splash_Screen(),
      ),
    );
  }
}
