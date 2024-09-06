import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ticketing_app/pages/LoginPage.dart';
import 'package:ticketing_app/pages/SignupPage.dart';
import 'firebase_options.dart';


void main() async {
  // Initialisation de Flutter et de Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase avec les options de configuration
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAOWq0joXjXe8P0CeneWbyEpeFVYatt6ic",
      authDomain: "fir-ticketing-cd8e9.firebaseapp.com",
      projectId: "fir-ticketing-cd8e9",
      storageBucket: "fir-ticketing-cd8e9.appspot.com",
      messagingSenderId: "574255748909",
      appId: "1:574255748909:web:244c00592383f6f80be5a4",
      measurementId: "G-GNLS7RBPLX",
    ),
  );

  runApp(const MyApp());
}





class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Auth',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const MyHomePage(title: 'Page d\'Accueil'),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: const Text('Bienvenue sur la page d\'accueil!'),
      ),
    );
  }
}
