import 'package:flutter/material.dart';

class SelectClientPage extends StatefulWidget {
  const SelectClientPage({super.key});

  @override
  State<SelectClientPage> createState() => _SelectClientPageState();
}

class _SelectClientPageState extends State<SelectClientPage> {
  final List<Map<String, String>> clients = [
    {'id': '1', 'name': 'Fatma Ben Ali', 'email': 'fatma@example.com'},
    {'id': '2', 'name': 'Ali Messaoudi', 'email': 'ali@example.com'},
    {'id': '3', 'name': 'Mohamed Salah', 'email': 'ms@example.com'},
    {'id': '4', 'name': 'Amine Jaballah', 'email': 'amine@example.com'},
  ];

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final searchController = TextEditingController();
  String searchQuery = '';

  void _showAddClientDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ajouter un client"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nom et Prénom"),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Téléphone"),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: "Adresse"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                setState(() {
                  clients.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text,
                    'email': emailController.text,
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Client ajouté avec succès")),
                );
                nameController.clear();
                emailController.clear();
                phoneController.clear();
                addressController.clear();
              }
            },
            child: const Text("Ajouter"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map? ?? {};
    final cart = arguments['cart'] as Map<int, int>? ?? {};
    final products = arguments['products'] as List<Map<String, dynamic>>? ?? [];
    final selectedProducts = products.where((p) => cart[p['id']] != null && cart[p['id']]! > 0).toList();

    final filteredClients = clients
        .where((c) => c['name']!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionner un client"),
        backgroundColor: Colors.indigo.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddClientDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (selectedProducts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("🛒 Produits sélectionnés :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...selectedProducts.map((product) {
                    final qte = cart[product['id']]!;
                    return Text(
                      "${product['name']} - ${qte} x ${product['price']} € = ${(qte * product['price']).toStringAsFixed(2)} €",
                      style: const TextStyle(fontSize: 14),
                    );
                  }).toList(),
                  const Divider(),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: searchController,
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Rechercher un client...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("👤 Choisir un client :", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredClients.length,
              itemBuilder: (context, index) {
                final client = filteredClients[index];
                return Card(
                  child: ListTile(
                    title: Text(client['name']!),
                    subtitle: Text(client['email']!),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/commande-details',
                        arguments: {
                          'client': client,
                          'cart': cart,
                          'products': products,
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
