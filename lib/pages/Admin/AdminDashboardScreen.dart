import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  String? _selectedRole;
  File? _imageFile;
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = _storage.ref().child('profile_pics/${DateTime.now().toIso8601String()}');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image: $e');
      return null;
    }
  }

  Future<void> _addUser() async {
    try {
      // Créer l'utilisateur avec Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Obtenez l'ID de l'utilisateur
      String uid = userCredential.user?.uid ?? '';
      print('User ID: $uid');

      // Télécharger l'image si elle existe
      String? photoUrl;
      if (_imageFile != null) {
        photoUrl = await _uploadImage(_imageFile!);
      }

      // Ajouter les informations dans Firestore
      await _firestore.collection('users').doc(uid).set({
        'nom': _nomController.text.trim(),
        'prenom': _prenomController.text.trim(),
        'role': _selectedRole,
        'photoUrl': photoUrl,
      });

      // Vérifiez si les données ont été correctement enregistrées
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      print('Document Data: ${userDoc.data()}');

      // Réinitialiser les champs
      _emailController.clear();
      _passwordController.clear();
      _nomController.clear();
      _prenomController.clear();
      _selectedRole = null;
      _imageFile = null;

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur ajouté avec succès!')),
      );

    } catch (e) {
      print('Erreur: $e');

      // Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'inscription: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Administrateur'),
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
              },
              decoration: const InputDecoration(
                labelText: 'Sélectionnez le rôle',
              ),
            ),
            const SizedBox(height: 20),
            _imageFile == null
                ? const Text('Aucune image sélectionnée.')
                : Image.file(_imageFile!),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Choisir une photo de profil'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addUser,
              child: const Text("Ajouter Utilisateur"),
            ),
          ],
        ),
      ),
    );
  }
}
