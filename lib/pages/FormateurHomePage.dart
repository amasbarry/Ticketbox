import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FormateurHomePage extends StatelessWidget {
  const FormateurHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Formateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Bienvenue Formateur!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page de gestion des notifications
                Navigator.of(context).pushNamed('/manageNotifications');
              },
              child: const Text('Gérer les notifications'),
            ),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page de gestion des tickets
                Navigator.of(context).pushNamed('/manageTickets');
              },
              child: const Text('Gérer les tickets'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Déconnexion'),
            ),
          ],
        ),
      ),
    );
  }
}
