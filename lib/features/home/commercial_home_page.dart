import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';

class CommercialHomePage extends StatelessWidget {
  const CommercialHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFE3F2FD),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: const [
                  CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/images/profile.jpg')),
                  SizedBox(height: 8),
                  Text("Fatma Bovazza", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("Commercial", style: TextStyle(color: Colors.grey))
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Paramètres"),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text("Contacter l'Admin"),
              onTap: () => Navigator.pushNamed(context, '/contact-admin'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text("Déconnexion", style: TextStyle(color: Colors.redAccent)),
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Bienvenue, Fatma 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.location_on, color: Colors.indigo),
                        SizedBox(width: 8),
                        Text("Paris 15e", style: TextStyle(color: Colors.black87)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.campaign, color: Colors.indigo),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("3 nouvelles réclamations", style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Objectif atteint à 90%. Bravo 👏")
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Votre progression", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              const Text("Objectifs Commercial\nAnnée 2024", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              CircularPercentIndicator(
                                radius: 50.0,
                                lineWidth: 10.0,
                                percent: 0.9,
                                center: const Text("90%", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                progressColor: Colors.indigo,
                                backgroundColor: Colors.grey.shade300,
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                              const SizedBox(height: 8),
                              const Text("Objectifs Commercial\nAnnée 2024", textAlign: TextAlign.center, style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Progression des ventes\npar catégorie", style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildBar(0.75, "Produit\n1"),
                                  _buildBar(0.85, "Produit\n2"),
                                  _buildBar(0.95, "Produit\n3"),
                                  _buildBar(1.0, "Produit\n4"),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCard(context, Icons.assignment, "Réclamations", '/reclamations'),
                      _buildCard(context, Icons.place, "Visites", '/visites'),
                      _buildCard(context, Icons.group, "Clients", '/clients'),
                      _buildCard(context, Icons.shopping_cart, "Commandes", '/commandes'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none),
                  onPressed: () => Navigator.pushNamed(context, '/notifications'),
                ),
                IconButton(
                  icon: const Icon(Icons.insert_drive_file_outlined),
                  onPressed: () => Navigator.pushNamed(context, '/documents'),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => Navigator.pushNamed(context, '/profil'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, String label) {
    return Column(
      children: [
        Container(
          height: 100 * heightFactor,
          width: 14,
          decoration: BoxDecoration(
            color: Colors.indigo,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10))
      ],
    );
  }

  Widget _buildCategoryProgress(String label, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            color: Colors.indigo.shade400,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAFE),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.indigo),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.indigo)),
          ],
        ),
      ),
    );
  }
} 
