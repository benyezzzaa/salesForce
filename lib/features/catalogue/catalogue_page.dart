// ✅ CataloguePage avec design plus moderne (force de vente - version alternative)
import 'package:flutter/material.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/features/catalogue/produit_service.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final service = ProduitService();
  Map<String, List<dynamic>> allProduits = {};
  Map<String, List<dynamic>> displayedProduits = {};
  bool isLoading = true;
  bool filterStock = false;
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    loadProduits();
  }

  Future<void> loadProduits() async {
    try {
      final produits = await service.fetchProduits();
      final Map<String, List<dynamic>> grouped = {};
      for (var p in produits) {
        final cat = p['categorie']['nom'];
        if (!grouped.containsKey(cat)) grouped[cat] = [];
        grouped[cat]!.add(p);
      }
      setState(() {
        allProduits = grouped;
        displayedProduits = Map.from(grouped);
        isLoading = false;
      });
    } catch (e) {
      print("Erreur catalogue : $e");
      setState(() => isLoading = false);
    }
  }

  void applyFilters() {
    final Map<String, List<dynamic>> filtered = {};
    allProduits.forEach((cat, produits) {
      final filteredList = produits.where((p) {
        final matchesSearch = p['nom'].toLowerCase().contains(searchTerm.toLowerCase());
        final hasStock = !filterStock || p['stock'] > 0;
        return matchesSearch && hasStock;
      }).toList();
      if (filteredList.isNotEmpty) {
        filtered[cat] = filteredList;
      }
    });
    setState(() {
      displayedProduits = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛒 Catalogue Produits", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        decoration: InputDecoration(
                          hintText: "🔍 Rechercher un produit...",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (val) {
                          searchTerm = val;
                          applyFilters();
                        },
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: filterStock,
                            onChanged: (val) {
                              setState(() => filterStock = val!);
                              applyFilters();
                            },
                          ),
                          const Text("Afficher uniquement les produits en stock"),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: displayedProduits.isEmpty
                      ? const Center(child: Text("Aucun produit trouvé."))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: displayedProduits.length,
                          itemBuilder: (context, index) {
                            final entry = displayedProduits.entries.elementAt(index);
                            final cat = entry.key;
                            final produits = entry.value;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                                  child: Text(cat, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                ),
                                ...produits.map((p) {
                                  return Card(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: p['images'] != null && p['images'].isNotEmpty
                                            ? Image.network(
                                                '${AppApi.baseUrl}${p['images'][0]}',
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                              )
                                            : const Icon(Icons.image_not_supported, size: 40),
                                      ),
                                      title: Text(p['nom'], style: TextStyle(fontWeight: FontWeight.bold, color: p['stock'] == 0 ? Colors.red : null)),
                                      subtitle: Text("Stock: ${p['stock']} • ${p['unite']['nom']}"),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("${p['prix']} €", style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const Icon(Icons.shopping_cart_outlined, size: 20)
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
