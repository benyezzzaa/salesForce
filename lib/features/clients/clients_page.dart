import 'package:flutter/material.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final List<Map<String, dynamic>> clients = [
    {
      'id': 1,
      'nom': 'Ben Ali',
      'prenom': 'Fatma',
      'email': 'fatma@mail.com',
      'tel': '12345678',
      'isActive': true,
    },
    {
      'id': 2,
      'nom': 'Zid',
      'prenom': 'Khaled',
      'email': 'khaled@mail.com',
      'tel': '98765432',
      'isActive': false,
    },
  ];

  void toggleActivation(int index) {
    setState(() {
      clients[index]['isActive'] = !clients[index]['isActive'];
    });
  }

  void editClient(int index) {
    final client = clients[index];
    final nomController = TextEditingController(text: client['nom']);
    final prenomController = TextEditingController(text: client['prenom']);
    final emailController = TextEditingController(text: client['email']);
    final telController = TextEditingController(text: client['tel']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Modifier le client"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomController, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: prenomController, decoration: const InputDecoration(labelText: 'Prénom')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: telController, decoration: const InputDecoration(labelText: 'Téléphone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                clients[index] = {
                  'id': client['id'],
                  'nom': nomController.text,
                  'prenom': prenomController.text,
                  'email': emailController.text,
                  'tel': telController.text,
                  'isActive': client['isActive'],
                };
              });
              Navigator.pop(context);
            },
            child: const Text("Enregistrer"),
          ),
        ],
      ),
    );
  }

  void addClient() {
    final nomController = TextEditingController();
    final prenomController = TextEditingController();
    final emailController = TextEditingController();
    final telController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un client"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomController, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: prenomController, decoration: const InputDecoration(labelText: 'Prénom')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: telController, decoration: const InputDecoration(labelText: 'Téléphone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                clients.add({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'nom': nomController.text,
                  'prenom': prenomController.text,
                  'email': emailController.text,
                  'tel': telController.text,
                  'isActive': true,
                });
              });
              Navigator.pop(context);
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191A49),
appBar: AppBar(
  backgroundColor: const Color(0xFF191A49),
  iconTheme: const IconThemeData(color: Colors.white), // Flèche de retour blanche
  title: const Text(
    "Clients",
    style: TextStyle(color: Colors.white), // Titre en blanc
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.person_add, color: Colors.white),
      onPressed: addClient, // Appelle la méthode addClient
    ),
  ],
),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final client = clients[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text("${client['prenom']} ${client['nom']}", style: const TextStyle(color: Colors.white)),
              subtitle: Text(client['email'], style: const TextStyle(color: Colors.white60)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: client['isActive'],
                    onChanged: (_) => toggleActivation(index),
                    activeColor: Colors.green,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () => editClient(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
