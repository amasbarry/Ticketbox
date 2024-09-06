import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApprenantHomePage extends StatelessWidget {
  const ApprenantHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Apprenant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Bienvenue Apprenant!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page de consultation des tickets
                Navigator.of(context).pushNamed('/viewTickets');
              },
              child: const Text('Consulter les tickets'),
            ),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page de consultation des notifications
                Navigator.of(context).pushNamed('/viewNotifications');
              },
              child: const Text('Consulter les notifications'),
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
