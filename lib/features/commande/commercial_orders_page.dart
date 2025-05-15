import 'package:flutter/material.dart';
import 'commande_details_page.dart';

class CommercialOrdersPage extends StatefulWidget {
  const CommercialOrdersPage({super.key});

  @override
  State<CommercialOrdersPage> createState() => _CommercialOrdersPageState();
}

class _CommercialOrdersPageState extends State<CommercialOrdersPage> {
  final List<Map<String, dynamic>> commandes = [
    {
      'numeroCommande': 'CMD1001',
      'client': 'Fatma Ben Ali',
      'date': '2024-05-10',
      'totalTTC': 200.0,
      'statut': 'validée',
      'lignes': [
        {'nom': 'Produit A', 'quantite': 2, 'prix': 50},
        {'nom': 'Produit B', 'quantite': 1, 'prix': 100},
      ]
    },
    {
      'numeroCommande': 'CMD1002',
      'client': 'Ali Messaoudi',
      'date': '2024-05-11',
      'totalTTC': 90.0,
      'statut': 'en_attente',
      'lignes': [
        {'nom': 'Produit C', 'quantite': 3, 'prix': 30},
      ]
    },
  ];

  bool showValidOnly = false;

  @override
  Widget build(BuildContext context) {
    final filtered = showValidOnly
        ? commandes.where((c) => c['statut'] == 'validée').toList()
        : commandes;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes Commandes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: '🔍 Rechercher...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/select-products'),
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvelle commande'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF1E5),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => setState(() => showValidOnly = !showValidOnly),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDCEEFF),
                      foregroundColor: Colors.blue.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(showValidOnly ? 'Toutes' : 'Validées'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final cmd = filtered[index];
                  final isValid = cmd['statut'] == 'validée';

                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.9, end: 1),
                    duration: const Duration(milliseconds: 400),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 400),
                                pageBuilder: (context, animation, secondaryAnimation) => CommandeDetailsPage(commande: cmd),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
                                  final offsetAnimation = animation.drive(tween);
                                  return SlideTransition(position: offsetAnimation, child: child);
                                },
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDEE8FF), Color(0xFFE8F0FE)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Commande #${cmd['numeroCommande']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isValid ? Colors.green.shade100 : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isValid ? "Validée" : "En attente",
                                        style: TextStyle(
                                          color: isValid ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(cmd['client']),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(cmd['date']),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text("💰", style: TextStyle(fontSize: 18)),
                                    const SizedBox(width: 6),
                                    Text(
                                      "${cmd['totalTTC']} DT",
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
