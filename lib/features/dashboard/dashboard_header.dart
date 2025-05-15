import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const DashboardHeader({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Vague verte
        ClipPath(
          clipper: WaveClipper(),
          child: Container(
            height: 230,
            color: const Color(0xFF043D3D),
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔍 Search + 🛒 Cart
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            icon: Icon(Icons.search),
                            hintText: 'Search for "Grocery"',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 16),
                const Text("Current Location", style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.location_on, color: Colors.white, size: 18),
                    SizedBox(width: 4),
                    Text("California, USA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Catégories rondes placées à l'extérieur
        Positioned(
          bottom: -45,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat['label'] == selectedCategory;

                return GestureDetector(
                  onTap: () => onCategorySelected(cat['label']),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : const Color(0xFFFFF3E0),
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: Icon(cat['icon'], color: isSelected ? Colors.green : Colors.orange),
                      ),
                      const SizedBox(height: 6),
                      Text(cat['label'], style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ClipPath pour vague
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
