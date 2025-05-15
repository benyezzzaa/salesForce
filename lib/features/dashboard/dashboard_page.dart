import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedCategory = 'All';

  final List<Map<String, dynamic>> categories = [
    {'label': 'All', 'icon': Icons.category},
    {'label': 'Meats', 'icon': Icons.set_meal},
    {'label': 'Vege', 'icon': Icons.eco},
    {'label': 'Fruits', 'icon': Icons.local_florist},
    {'label': 'Breads', 'icon': Icons.bakery_dining},
    {'label': 'Fish', 'icon': Icons.set_meal_outlined},
    {'label': 'Drinks', 'icon': Icons.local_drink},
  ];

  final List<Map<String, dynamic>> products = [
    {'name': 'Beetroot', 'weight': '500 gm', 'price': 17.29, 'category': 'Vege'},
    {'name': 'Avocado', 'weight': '450 gm', 'price': 14.29, 'category': 'Fruits'},
    {'name': 'Carrot', 'weight': '1000 gm', 'price': 27.29, 'category': 'Vege'},
    {'name': 'Fresh Beef', 'weight': '1000 gm', 'price': 23.46, 'category': 'Meats'},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == 'All'
        ? products
        : products.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    color: const Color(0xFF043D3D),
                    height: 330,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                       
                       
                       Center(
  child: Column(
    children: [
      const Text("Current Location", style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.location_on, color: Colors.white, size: 18),
          SizedBox(width: 4),
          Text("California, USA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    ],
  ),
),
                        const SizedBox(height: 30),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              final isSelected = cat['label'] == selectedCategory;
                              return GestureDetector(
                                onTap: () => setState(() => selectedCategory = cat['label']),
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
                                    Text(cat['label'], style: const TextStyle(fontSize: 12, color: Colors.white)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text("You might need", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Spacer(),
                  Text("See more", style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredProducts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = filteredProducts[index];
                  return _ProductCard(product: p);
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _DeliveryCard(
                    title: "Grocery",
                    subtitle: "By 12:15pm\nFree delivery",
                    color: Colors.yellow.shade100,
                    icon: Icons.shopping_bag,
                  ),
                  const SizedBox(width: 12),
                  _DeliveryCard(
                    title: "Wholesale",
                    subtitle: "By 1:30pm\nFree delivery",
                    color: Colors.pink.shade100,
                    icon: Icons.local_shipping,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  int quantity = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const FlutterLogo(size: 60),
          const SizedBox(height: 6),
          Text(widget.product['name'], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(widget.product['weight'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 6),
          Text("${widget.product['price']} \$", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAF6EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  onPressed: quantity > 0 ? () => setState(() => quantity--) : null,
                ),
                Text(quantity.toString()),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  const _DeliveryCard({required this.title, required this.subtitle, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          leading: Icon(icon, size: 30),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        ),
      ),
    );
  }
}
class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title cliqué')),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 100,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}