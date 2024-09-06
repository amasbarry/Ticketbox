import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<String> _categories = ['Technique', 'Éducative', 'Administrative'];
  String _selectedCategory = 'Technique'; // Valeur par défaut
  String? _userRole;
  String? _userId; // ID de l'utilisateur connecté

  @override
  void initState() {
    super.initState();
    _getUserRole();
    _getUserId();
  }

  Future<void> _getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _userRole = userDoc.data()?['role'] ?? 'Unknown'; // Utilisation de data() avec une valeur par défaut
      });
    }
  }

  Future<void> _getUserId() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal,
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundImage: AssetImage('assets/profile_picture.png'),
        ),
      ),
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 10),
            const Text('Gestedux', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndAddRow(),
          const SizedBox(height: 20),
          Expanded(child: _buildTicketList()),
        ],
      ),
    );
  }

  Widget _buildSearchAndAddRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Rechercher...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (query) {
              setState(() {
                // Filtrer les tickets en fonction de la recherche
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        if (_userRole == 'Apprenant' && _userId != null) // Les apprenants peuvent ajouter des tickets
          ElevatedButton(
            onPressed: () {
              _showAddTicketDialog();
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.all(16),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildTicketList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('tickets').where('userId', isEqualTo: _userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        final tickets = snapshot.data!.docs;

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            var ticket = tickets[index];
            return _buildTicketRow(ticket);
          },
        );
      },
    );
  }

  Widget _buildTicketRow(DocumentSnapshot ticket) {
    final data = ticket.data() as Map<String, dynamic>?; // Utilisation de data() pour obtenir une carte
    if (data == null) {
      return const Center(child: Text('Données manquantes pour le ticket.'));
    }

    final title = data['title'] ?? 'Titre non disponible';
    final description = data['description'] ?? 'Description non disponible';
    final status = data['status'] ?? 'Statut non disponible';
    final date = data['date'] ?? 'Date non disponible';
    final category = data['category'] ?? 'Catégorie non disponible';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(status, style: TextStyle(color: _getStatusColor(status), fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Text(date),
            const SizedBox(width: 10),
            Text(category),
            if (_userRole == 'Apprenant' && _userId == ticket.data()?['userId'] ) ...[ // Vérifier si l'utilisateur est l'auteur du ticket
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () {
                  _showEditTicketDialog(ticket.id, title, description, category);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  _deleteTicket(ticket.id);
                },
              ),
            ],
            if (_userRole == 'Formateur') ...[
              if (status == 'Attente')
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.blue),
                  onPressed: () {
                    _updateTicketStatus(ticket.id, 'En cours');
                  },
                ),
              if (status == 'En cours')
                IconButton(
                  icon: const Icon(Icons.done_all, color: Colors.green),
                  onPressed: () {
                    _updateTicketStatus(ticket.id, 'Résolu');
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Résolu':
        return Colors.green;
      case 'En cours':
        return Colors.orange;
      case 'Attente':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddTicketDialog() {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Titre du ticket'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Description détaillée'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _addTicket(
                _titleController.text,
                _descriptionController.text,
                _selectedCategory,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _addTicket(String title, String description, String category) {
    _firestore.collection('tickets').add({
      'title': title,
      'description': description,
      'status': 'Attente',
      'date': DateTime.now().toIso8601String(),
      'category': category,
      'userId': _userId,
    });
  }

  void _showEditTicketDialog(String ticketId, String title, String description, String category) {
    final _titleController = TextEditingController(text: title);
    final _descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Titre du ticket'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Description détaillée'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: category,
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _updateTicket(
                ticketId,
                _titleController.text,
                _descriptionController.text,
                _selectedCategory,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _updateTicket(String ticketId, String title, String description, String category) {
    _firestore.collection('tickets').doc(ticketId).update({
      'title': title,
      'description': description,
      'category': category,
    });
  }

  void _deleteTicket(String ticketId) {
    _firestore.collection('tickets').doc(ticketId).delete();
  }

  void _updateTicketStatus(String ticketId, String status) {
    _firestore.collection('tickets').doc(ticketId).update({
      'status': status,
    });
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Accueil',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Recherche',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }
}