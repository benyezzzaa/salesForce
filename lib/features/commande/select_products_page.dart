// 📁 lib/features/commande/pages/select_products_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/features/commande/controllers/produit_controller.dart';

import '../../../data/models/produit_model.dart';


class SelectProductsPage extends StatefulWidget {
  const SelectProductsPage({super.key});

  @override
  State<SelectProductsPage> createState() => _SelectProductsPageState();
}

class _SelectProductsPageState extends State<SelectProductsPage> {
  final ProduitController produitController = Get.put(ProduitController());
  String selectedCategory = 'Tous';
  final Map<int, int> cart = {};

  @override
  void initState() {
    super.initState();
    produitController.fetchProduits();
  }

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

  void showProductDetails(ProduitModel product) {
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
              child: Image.network("${AppApi.baseUrl}${product.images.first}"),
            ),
            const SizedBox(height: 12),
            Text(product.nom, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Prix : ${product.prix} €", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(product.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              addToCart(product.id);
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

  void showCartDialog() {
    final produits = produitController.produits;
    final selectedProducts = produits.where((p) => cart[p.id] != null && cart[p.id]! > 0).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🛒 Panier"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: selectedProducts.map((p) {
              final qte = cart[p.id] ?? 0;
              final total = (p.prix * qte).toStringAsFixed(2);
              return ListTile(
                title: Text(p.nom),
                subtitle: Text("Quantité : \$qte  |  Prix unitaire : \${p.prix} €"),
                trailing: Text("=\$total €", style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade400,
        title: const Text("Sélection des produits", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: showCartDialog,
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('$cartItemCount', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (produitController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final produits = produitController.produits.where((p) => selectedCategory == 'Tous' || p.categorie == selectedCategory).toList();

        return Column(
          children: [
            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  'Tous',
                  ...{...produitController.produits.map((p) => p.categorie)}
                ].map((cat) {
                  final isSelected = cat == selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.orange : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.indigo, width: 1.2),
                      ),
                      child: Center(
                        child: Text(cat, style: TextStyle(color: isSelected ? Colors.white : Colors.indigo)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: produits.length,
                itemBuilder: (context, index) {
                  final p = produits[index];
                  final qte = cart[p.id] ?? 0;
                  return GestureDetector(
                    onTap: () => showProductDetails(p),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                             child: Image.network("${AppApi.baseUrl}${p.images.first}"),)
                             /* child: Image.network(
                                p.images.isNotEmpty ? p.images.first : '',
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                              ),
                            ),*/
                          ),
                          const SizedBox(height: 8),
                          Text(p.nom, style: const TextStyle(fontWeight: FontWeight.w600)),
                          Text("${p.prix} €", style: const TextStyle(color: Colors.grey)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => removeFromCart(p.id),
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.indigo),
                              ),
                              Text('$qte', style: const TextStyle(fontSize: 16)),
                              IconButton(
                                onPressed: () => addToCart(p.id),
                                icon: const Icon(Icons.add_circle_outline, color: Colors.indigo),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (cartItemCount == 0) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Le panier est vide")),
            );
          } else {
            Get.toNamed('/select-client', arguments: {'cart': cart});
          }
        },
        label: const Text("Continuer"),
        icon: const Icon(Icons.add_shopping_cart),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
