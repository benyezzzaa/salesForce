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
    if (produitController.produits.isEmpty) {
      produitController.fetchProduits();
    }
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

  void showProductDetails(BuildContext context, ProduitModel product) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.surface,
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "${AppApi.baseUrl}${product.images.first}",
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.image_not_supported, size: 100, color: colorScheme.onSurfaceVariant);
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(product.nom, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text("Prix : ${product.prix} €", style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text(product.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: colorScheme.onSurface)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () {
              addToCart(product.id);
              Navigator.pop(context);
            },
            icon: Icon(Icons.add_shopping_cart, color: colorScheme.onPrimary),
            label: Text("Ajouter au panier", style: TextStyle(color: colorScheme.onPrimary)),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  void showCartDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final produits = produitController.produits;
    final selectedProducts = produits.where((p) => cart[p.id] != null && cart[p.id]! > 0).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("🛒 Panier", style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: selectedProducts.map((p) {
              final qte = cart[p.id] ?? 0;
              final total = (p.prix * qte).toStringAsFixed(2);
              return ListTile(
                title: Text(p.nom, style: TextStyle(color: colorScheme.onSurface)),
                subtitle: Text("Quantité : \$qte  |  Prix unitaire : \${p.prix} €", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                trailing: Text("=\$total €", style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary)),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fermer", style: TextStyle(color: colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text("Sélection des produits", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        elevation: 2,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: colorScheme.onPrimary),
                onPressed: () => showCartDialog(context),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
                    child: Text('$cartItemCount', style: TextStyle(fontSize: 12, color: colorScheme.onError)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (produitController.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: colorScheme.primary));
        }

        final produits = produitController.produits.where((p) => selectedCategory == 'Tous' || p.categorie == selectedCategory).toList();

        return Column(
          children: [
            SizedBox(
              height: 70,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  'Tous',
                  ...{...produitController.produits.map((p) => p.categorie)}
                ].toSet().toList().map((cat) {
                  final isSelected = cat == selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                        boxShadow: isSelected ? [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 6, offset: Offset(0, 3))] : [],
                      ),
                      child: Center(
                        child: Text(
                          cat,
                          style: TextStyle(color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        ),
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
                    onTap: () => showProductDetails(context, p),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network("${AppApi.baseUrl}${p.images.first}", fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.image_not_supported, size: 80, color: colorScheme.onSurfaceVariant);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(p.nom, style: TextStyle(fontWeight: FontWeight.w600, color: colorScheme.onSurface)),
                            Text("${p.prix} €", style: TextStyle(color: colorScheme.onSurfaceVariant)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () => removeFromCart(p.id),
                                  icon: Icon(Icons.remove_circle_outline, color: colorScheme.error),
                                ),
                                Text('$qte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                                IconButton(
                                  onPressed: () => addToCart(p.id),
                                  icon: Icon(Icons.add_circle_outline, color: colorScheme.tertiary),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        );
      }),
      floatingActionButton: cartItemCount > 0 ? FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed('/select-client');
        },
        label: Text('Sélectionner Client', style: TextStyle(color: colorScheme.onPrimary)),
        icon: Icon(Icons.arrow_forward, color: colorScheme.onPrimary),
        backgroundColor: colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ) : null,
    );
  }
}
