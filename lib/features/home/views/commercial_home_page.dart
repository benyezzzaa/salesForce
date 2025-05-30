// 📁 lib/features/home/commercial_home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pfe/features/home/controller/commercial_controller.dart';

class CommercialHomePage extends StatelessWidget {
  const CommercialHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommercialController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF7FAFC);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final shadow = [BoxShadow(color: Colors.black12, blurRadius: 6)];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade600,
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
            child: CircleAvatar(backgroundImage: AssetImage('assets/profile.jpeg')),
          )
        ],
      ),
      drawer: _buildDrawer(context, cardColor),
      body: Obx(() {
        final percent = controller.currentYearProgress;
        final salesByCategory = controller.salesByCategory;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: AnimationLimiter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 500),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        curve: Curves.easeOutBack,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        const Text("Bienvenue, Fatma 👋", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _infoCard(Icons.location_on, "📍 Vous êtes à Paris 15e", const Color.fromARGB(255, 190, 191, 190), shadow),
                        const SizedBox(height: 16),
                        _infoCard(
                          Icons.campaign, 
                          "📢 ${controller.reclamationsCount} réclamations en attente\n🌟 Objectif à ${(percent * 100).toStringAsFixed(0)}% atteint !", 
                          Colors.deepPurple.shade100, 
                          shadow, 
                          isMultiline: true
                        ),
                        const SizedBox(height: 20),
                        const Text("Votre progression", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),
                        _progressSection(cardColor, shadow, percent, salesByCategory),
                        const SizedBox(height: 30),
                        _buildGrid(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBottomNav(context, cardColor),
          ],
        );
      }),
    );
  }

  Widget _buildDrawer(BuildContext context, Color cardColor) {
    return Drawer(
      backgroundColor: cardColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: const [
                CircleAvatar(radius: 32, backgroundImage: AssetImage('assets/profile.jpeg')),
                SizedBox(height: 8),
                Text("Fatma Bovazza", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text("Commercial", style: TextStyle(color: Colors.grey))
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings), 
            title: const Text("Paramètres"), 
            onTap: () => Navigator.pushNamed(context, '/settings')
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline), 
            title: const Text("Contacter l'Admin"), 
            onTap: () => Navigator.pushNamed(context, '/contact-admin')
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent), 
            title: const Text("Déconnexion", style: TextStyle(color: Colors.redAccent)), 
            onTap: () => Navigator.pushReplacementNamed(context, '/login')
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String text, Color bgColor, List<BoxShadow> shadow, {bool isMultiline = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), boxShadow: shadow),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _progressSection(Color cardColor, List<BoxShadow> shadow, double percent, List<Map<String, dynamic>> sales) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), boxShadow: shadow),
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
                  percent: percent,
                  center: Text("${(percent * 100).toStringAsFixed(0)}%", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  progressColor: Colors.indigo,
                  backgroundColor: Colors.grey.shade300,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Ventes par catégorie", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: sales.map((cat) => _buildBar((cat['totalQuantite'] / 100).clamp(0.1, 1.0), cat['categorie'])).toList(),
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

  Widget _buildGrid(BuildContext context) {
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 400),
          childAnimationBuilder: (widget) => ScaleAnimation(
            scale: 0.8,
            curve: Curves.easeInOutCubic,
            child: widget,
          ),
          children: [
            _buildCard(context, Icons.assignment, "Réclamations", '/reclamations/home'),
            _buildCard(context, Icons.place, "Visites", '/visite/create'),
            _buildCard(context, Icons.group, "Clients", '/clients'),
            _buildCard(context, Icons.shopping_cart, "Commandes", '/commandes'),
          ],
        ),
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

  Widget _buildBottomNav(BuildContext context, Color cardColor) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: cardColor,
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomIcon(context, Icons.notifications, "Notifications", '/notifications'),
          _buildBottomIcon(context, Icons.description_outlined, "Documents", '/documents'),
          _buildBottomIcon(context, Icons.library_books, "Catalogue", '/catalogue'),
          _buildBottomIcon(context, Icons.person, "Profil", '/profil'),
        ],
      ),
    );
  }

  Widget _buildBottomIcon(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: Colors.indigo),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
