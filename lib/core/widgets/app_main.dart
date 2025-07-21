import 'package:flutter/material.dart';
import 'package:pfe/features/catalogue/catalogue_page.dart';
import 'package:pfe/features/documents/documents_valides_page.dart';
import 'package:pfe/features/home/views/commercial_home_page.dart';
import 'package:pfe/features/profile/views/profile_page.dart';

class BottomNavWrapper extends StatefulWidget {
  final int initialIndex;

  const BottomNavWrapper({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _selectedIndex = 0;
  final GlobalKey homeKey = GlobalKey();

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    super.initState();
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return CommercialHomePage(key: homeKey);
      case 1:
        return DocumentsValidesPage();
      case 2:
        return CataloguePage();
      case 3:
        return ProfilePage();
      default:
        return ProfilePage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0 && homeKey.currentState != null) {
        // ignore: invalid_use_of_protected_member
        (homeKey.currentState as dynamic).controller.fetchData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBottomIcon(Icons.home_rounded, "Accueil", 0),
              _buildBottomIcon(Icons.description_outlined, "Documents", 1),
              _buildBottomIcon(Icons.library_books_rounded, "Catalogue", 2),
              _buildBottomIcon(Icons.person_rounded, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomIcon(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 80, 
        height: 60, 
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3F51B5) : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: isSelected 
            ? [
                BoxShadow(
                  color: const Color(0xFF3F51B5).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected 
                ? Colors.white 
                : Colors.grey.shade600,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected 
                  ? Colors.white 
                  : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
