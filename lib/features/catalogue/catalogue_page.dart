import 'package:flutter/material.dart';


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
    return Scaffold(
      appBar: AppBar(title: const Text("Catalogue Produits")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Rechercher un produit...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      searchTerm = val;
                      applyFilters();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: filterStock,
                        onChanged: (val) {
                          setState(() {
                            filterStock = val!;
                          });
                          applyFilters();
                        },
                      ),
                      const Text("Afficher uniquement les produits en stock"),
                    ],
                  ),
                ),
                Expanded(
                  child: displayedProduits.isEmpty
                      ? const Center(child: Text("Aucun produit trouvé."))
                      : ListView(
                          children: displayedProduits.entries.map((entry) {
                            final cat = entry.key;
                            final produits = entry.value;

                            return ExpansionTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.indigo,
                                    child: Text(
                                      produits.length.toString(),
                                      style: const TextStyle(fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              children: produits.map((p) {
                                return ListTile(
                                  leading: p['images'] != null && p['images'].isNotEmpty
                                      ? Image.network(
                                          'http://localhost:4000${p['images'][0]}',
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image_not_supported),
                                  title: Text(
                                    p['nom'],
                                    style: TextStyle(color: p['stock'] == 0 ? Colors.red : null),
                                  ),
                                  subtitle: Text("Stock: ${p['stock']} • ${p['unite']['nom']}"),
                                  trailing: Text("${p['prix']} €"),
                                );
                              }).toList(),
                            );
                          }).toList(),
                        ),
                ),
              ],
            ),
    );
  }
}
