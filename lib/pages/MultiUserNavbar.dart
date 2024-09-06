import 'package:flutter/material.dart';
import 'package:ticketing_app/pages/Admin/AdminDashboardScreen.dart';
import 'package:ticketing_app/pages/ApprenantHomePage.dart';
import 'package:ticketing_app/pages/FormateurHomePage.dart';


class MultiUserNavbar extends StatefulWidget {
  const MultiUserNavbar({Key? key}) : super(key: key);

  @override
  State<MultiUserNavbar> createState() => _MultiUserNavbarState();
}

class _MultiUserNavbarState extends State<MultiUserNavbar> {
  int _selectedIndex = 0;

  // Liste des pages pour chaque type d'utilisateur
  final List<Widget> _apprenantPages = [
    const ApprenantHomePage(),
    const Center(child: Text('Mes Notifications')),
    const Center(child: Text('Mon Profil')),
  ];

  final List<Widget> _formateurPages = [
    const FormateurHomePage(),
    const Center(child: Text('Tickets')),
    const Center(child: Text('Notifications')),
    const Center(child: Text('Profil')),
  ];

  final List<Widget> _adminPages = [
    AdminDashboardScreen(),
    const Center(child: Text('Gestion des Utilisateurs')),
    const Center(child: Text('Statistiques')),
    const Center(child: Text('Mon Profil')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion de Tickets'),
        actions: [
          // Bouton pour basculer entre les rôles d'utilisateur
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: const Text('Apprenant'),
                      onTap: () {
                        setState(() {
                          _selectedIndex = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Formateur'),
                      onTap: () {
                        setState(() {
                          _selectedIndex = 1;
                        });
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      title: const Text('Administrateur'),
                      onTap: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _getCurrentUserPage(), // Affiche la page en fonction du rôle sélectionné
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _getCurrentUserPage() {
    switch (_selectedIndex) {
      case 0:
        return _apprenantPages[_selectedIndex];
      case 1:
        return _formateurPages[_selectedIndex];
      case 2:
        return _adminPages[_selectedIndex];
      default:
        return const Center(child: Text('Page non disponible'));
    }
  }
}