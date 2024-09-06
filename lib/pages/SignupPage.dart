import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assurez-vous d'ajouter ce package
import 'package:ticketing_app/pages/LoginPage.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance; // Instanciation de Firestore
  String? _selectedRole; // Variable pour stocker le rôle sélectionné

  Future<void> _signup() async {
    try {
      // Créer l'utilisateur avec Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Obtenez l'ID de l'utilisateur
      String uid = userCredential.user?.uid ?? '';
      print('User ID: $uid');

      // Ajouter le nom, prénom et rôle dans Firestore
      await _firestore.collection('users').doc(uid).set({
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'role': _selectedRole,
      });

      // Vérifiez si les données ont été correctement enregistrées
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      print('Document Data: ${userDoc.data()}');

      // Rediriger vers la page de connexion après l'inscription
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ));
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs d'inscription
      print('Erreur: $e');
    } catch (e) {
      // Gérer d'autres erreurs
      print('Erreur inconnue: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _prenomController,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: <String>['Apprenant', 'Admin', 'Formateur']
                  .map((String role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRole = newValue;
                });
                print('Rôle sélectionné: $_selectedRole'); // Debugging
              },
              decoration: const InputDecoration(
                labelText: 'Sélectionnez votre rôle',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signup,
              child: const Text("S'inscrire"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ));
              },
              child: const Text("Vous avez déjà un compte ? Connectez-vous"),
            ),
          ],
        ),
      ),
    );
  }
}
