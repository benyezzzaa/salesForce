import 'package:flutter/material.dart';

class SelectProductsPage extends StatefulWidget {
  const SelectProductsPage({super.key});

  @override
  State<SelectProductsPage> createState() => _SelectProductsPageState();
}

class _SelectProductsPageState extends State<SelectProductsPage> {
  final List<Map<String, dynamic>> categories = [
    {'label': 'Tous', 'icon': Icons.grid_view},
    {'label': 'Viandes', 'icon': Icons.set_meal},
    {'label': 'Légumes', 'icon': Icons.eco},
    {'label': 'Fruits', 'icon': Icons.local_florist},
    {'label': 'Boissons', 'icon': Icons.local_drink},
  ];

  final List<Map<String, dynamic>> products = [
    {'id': 1, 'name': 'Poulet', 'price': 10.0, 'category': 'Viandes', 'image': 'https://picsum.photos/200?1'},
    {'id': 2, 'name': 'Boeuf', 'price': 12.0, 'category': 'Viandes', 'image': 'https://picsum.photos/200?2'},
    {'id': 3, 'name': 'Tomate', 'price': 2.0, 'category': 'Légumes', 'image': 'https://picsum.photos/200?3'},
    {'id': 4, 'name': 'Carotte', 'price': 1.5, 'category': 'Légumes', 'image': 'https://picsum.photos/200?4'},
    {'id': 5, 'name': 'Pomme', 'price': 3.0, 'category': 'Fruits', 'image': 'https://picsum.photos/200?5'},
    {'id': 6, 'name': "Jus d'orange", 'price': 2.5, 'category': 'Boissons', 'image': 'https://picsum.photos/200?6'},
  ];

  String selectedCategory = 'Tous';
  final Map<int, int> cart = {};

  void addToCart(int productId) {
    setState(() {
      cart[productId] = (cart[productId] ?? 0) + 1;
    });
  }

  void removeFromCart(int productId) {
    setState(() {
      if ((cart[productId] ?? 0) > 0) {
        cart[productId] = cart[productId]! - 1;
      }
    });
  }

  int get cartItemCount => cart.values.fold(0, (sum, qte) => sum + qte);

  void showProductDetails(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(product['image'], height: 150, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text(product['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Prix : \${product['price']} €", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            const Text(
              "Ce produit est l'un des plus populaires. Il est frais et livré rapidement.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              addToCart(product['id']);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text("Ajouter au panier"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = selectedCategory == 'Tous'
        ? products
        : products.where((p) => p['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        title: const Text(
          "Sélection des produits",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/select-client',
                    arguments: {'cart': cart, 'products': products},
                  );
                },
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text('$cartItemCount', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat['label'] == selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => selectedCategory = cat['label']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.orange : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.indigo, width: 1.2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(cat['icon'], color: isSelected ? Colors.white : Colors.indigo),
                        const SizedBox(height: 4),
                        Text(
                          cat['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.indigo,
                            fontSize: 11,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                final qte = cart[product['id']] ?? 0;
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.95, end: 1.0),
                  duration: const Duration(milliseconds: 400),
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: GestureDetector(
                        onTap: () => showProductDetails(product),
                        child: Card(
                          color: Colors.white,
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                product['image'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                              ),
                            ),
                            title: Text(product['name'], style: const TextStyle(color: Colors.black87)),
                            subtitle: Text("${product['price']} €", style: const TextStyle(color: Colors.black54)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.indigo),
                                  onPressed: () => removeFromCart(product['id']),
                                ),
                                Text('$qte', style: const TextStyle(color: Colors.black87)),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.indigo),
                                  onPressed: () => addToCart(product['id']),
                                ),
                              ],
                            ),
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
    );
  }
}
