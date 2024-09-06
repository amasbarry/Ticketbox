import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

// Modèle Ticket
class Ticket {
  String id;
  String description;
  String category;
  String status;
  String apprenantId;
  String formateurId;
  String response;

  Ticket({
    required this.id,
    required this.description,
    required this.category,
    required this.status,
    required this.apprenantId,
    this.formateurId = '',
    this.response = '',
  });

  // Convertir Ticket en Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'status': status,
      'apprenantId': apprenantId,
      'formateurId': formateurId,
      'response': response,
    };
  }

  // Créer un Ticket à partir d'une Map (depuis Firebase)
  static Ticket fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      description: map['description'],
      category: map['category'],
      status: map['status'],
      apprenantId: map['apprenantId'],
      formateurId: map['formateurId'] ?? '',
      response: map['response'] ?? '',
    );
  }
}

// Fonction de soumission d'un ticket par un apprenant
Future<void> submitTicket(String description, String category, String apprenantId) async {
  var ticketId = const Uuid().v4(); // Générer un ID unique
  Ticket newTicket = Ticket(
    id: ticketId,
    description: description,
    category: category,
    status: 'Attente', // Statut initial
    apprenantId: apprenantId,
  );

  await FirebaseFirestore.instance.collection('tickets').doc(ticketId).set(newTicket.toMap());
}

// Fonction de mise à jour de l'état d'un ticket par un formateur
Future<void> updateTicketStatus(String ticketId, String formateurId, String newStatus) async {
  await FirebaseFirestore.instance.collection('tickets').doc(ticketId).update({
    'status': newStatus,
    'formateurId': formateurId,
  });
}

// Fonction pour marquer un ticket comme "En cours"
Future<void> takeInChargeTicket(String ticketId, String formateurId) async {
  await updateTicketStatus(ticketId, formateurId, 'En cours');
}

// Fonction pour résoudre un ticket avec une réponse du formateur
Future<void> resolveTicket(String ticketId, String formateurId, String response) async {
  await FirebaseFirestore.instance.collection('tickets').doc(ticketId).update({
    'status': 'Résolu',
    'response': response,
    'formateurId': formateurId,
  });
}

// Stream pour récupérer les tickets d'un apprenant (suivi)
Stream<List<Ticket>> getTicketsForApprenant(String apprenantId) {
  return FirebaseFirestore.instance
      .collection('tickets')
      .where('apprenantId', isEqualTo: apprenantId)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Ticket.fromMap(doc.data())).toList());
}

// Formulaire de création de ticket pour un apprenant
class CreateTicketPage extends StatelessWidget {
  final TextEditingController descriptionController = TextEditingController();
  final String apprenantId;

  CreateTicketPage({super.key, required this.apprenantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un ticket')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButton<String>(
              hint: const Text('Catégorie'),
              items: ['Technique', 'Pédagogique']
                  .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                // Gérer la sélection de catégorie
              },
            ),
            ElevatedButton(
              onPressed: () {
                submitTicket(
                  descriptionController.text,
                  'Technique', // Catégorie choisie
                  apprenantId,
                );
              },
              child: const Text('Soumettre'),
            ),
          ],
        ),
      ),
    );
  }
}

// Liste des tickets d'un apprenant (suivi)
class TicketsPage extends StatelessWidget {
  final String apprenantId;

  const TicketsPage({super.key, required this.apprenantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes tickets')),
      body: StreamBuilder<List<Ticket>>(
        stream: getTicketsForApprenant(apprenantId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var tickets = snapshot.data!;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var ticket = tickets[index];
              return ListTile(
                title: Text(ticket.description),
                subtitle: Text('Statut: ${ticket.status}'),
              );
            },
          );
        },
      ),
    );
  }
}

// Interface pour que les formateurs gèrent les tickets
class ManageTicketsPage extends StatelessWidget {
  final String formateurId;

  const ManageTicketsPage({super.key, required this.formateurId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gérer les tickets')),
      body: StreamBuilder<List<Ticket>>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('status', isEqualTo: 'Attente')
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => Ticket.fromMap(doc.data())).toList()),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var tickets = snapshot.data!;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              var ticket = tickets[index];
              return ListTile(
                title: Text(ticket.description),
                subtitle: Text('Catégorie: ${ticket.category}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    takeInChargeTicket(ticket.id, formateurId);
                  },
                  child: const Text('Prendre en charge'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
