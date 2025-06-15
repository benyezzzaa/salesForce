import 'package:flutter/material.dart';
import 'package:pfe/features/catalogue/catalogue_page.dart';
import 'package:pfe/features/documents/documents_valides_page.dart';
import 'package:pfe/features/home/views/commercial_home_page.dart';
import 'package:pfe/features/profile/views/profile_page.dart';


class BottomNavWrapper extends StatefulWidget {
  final int initialIndex;
   BottomNavWrapper({super.key,  this.initialIndex=0});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _selectedIndex = 0;

  @override
  void initState() {
    _selectedIndex= widget.initialIndex;
    super.initState();
  }

  final List<Widget> _pages = [
    const CommercialHomePage(),
    DocumentsValidesPage(),     // à adapter avec ton vrai fichier
    const CataloguePage(),     // idem
    ProfilePage(),       // idem
  ];

  final List<String> _titles = [
    "Accueil",
    "Documents",
    "Catalogue",
    "Profil",
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E293B)
        : Colors.white;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: cardColor,
          border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomIcon(context, Icons.home, "Accueil", 0),
            _buildBottomIcon(context, Icons.description_outlined, "Documents", 1),
            _buildBottomIcon(context, Icons.library_books, "Catalogue", 2),
            _buildBottomIcon(context, Icons.person, "Profil", 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomIcon(BuildContext context, IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.indigo.shade100 : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, size: 24, color: Colors.indigo),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.indigo : Colors.black,
              )),
        ],
      ),
    );
  }
}
