// ✅ CataloguePage avec design plus moderne (force de vente - version alternative)
import 'package:flutter/material.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/features/catalogue/produit_service.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage>
    with TickerProviderStateMixin {
  final service = ProduitService();
  List<dynamic> allProduits = [];
  List<dynamic> displayedProduits = [];
  List<String> categories = [];
  String selectedCategory = 'Tous';
  bool isLoading = true;
  String searchTerm = '';

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    
    loadProduits();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadProduits() async {
    try {
      final produits = await service.fetchProduits();
      final Set<String> cats = produits.map<String>((p) => p['categorie']['nom'] as String).toSet();
      setState(() {
        allProduits = produits;
        categories = ['Tous', ...cats];
        displayedProduits = List.from(produits);
        isLoading = false;
      });
    } catch (e) {
      print("Erreur catalogue : $e");
      setState(() => isLoading = false);
    }
  }

  void filterByCategory(String cat) {
    setState(() {
      selectedCategory = cat;
      if (cat == 'Tous') {
        displayedProduits = allProduits.where((p) => p['nom'].toLowerCase().contains(searchTerm.toLowerCase())).toList();
      } else {
        displayedProduits = allProduits.where((p) => p['categorie']['nom'] == cat && p['nom'].toLowerCase().contains(searchTerm.toLowerCase())).toList();
      }
    });
  }

  void onSearch(String val) {
    setState(() {
      searchTerm = val;
      filterByCategory(selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Chargement du catalogue...",
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Header stylé
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorScheme.surface.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shopping_bag,
                                color: colorScheme.onSurface,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "🛒 Catalogue Produits",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    "${displayedProduits.length} produit(s) disponible(s)",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Barre de recherche et filtres
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.onSurface.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            // Barre de recherche
                            TextField(
                              onChanged: onSearch,
                              style: TextStyle(color: colorScheme.onSurface),
                              decoration: InputDecoration(
                                hintText: '🔍 Rechercher un produit...',
                                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                                prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: colorScheme.onSurface),
                                ),
                                filled: true,
                                fillColor: colorScheme.surface.withOpacity(0.1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Filtres par catégorie
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: categories.map((category) => 
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      label: Text(
                                        category,
                                        style: TextStyle(
                                          color: selectedCategory == category 
                                            ? colorScheme.onSurface 
                                            : colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                      ),
                                      selected: selectedCategory == category,
                                      onSelected: (selected) {
                                        filterByCategory(category);
                                      },
                                      backgroundColor: colorScheme.surface.withOpacity(0.1),
                                      selectedColor: colorScheme.onSurface.withOpacity(0.3),
                                      checkmarkColor: colorScheme.onSurface,
                                      side: BorderSide(color: colorScheme.onSurface.withOpacity(0.3)),
                                    ),
                                  ),
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Liste des produits
                      Expanded(
                        child: displayedProduits.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Icon(
                                        Icons.inbox_outlined,
                                        size: 64,
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      "Aucun produit trouvé",
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withOpacity(0.8),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Aucun produit ne correspond à vos critères",
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withOpacity(0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.75,
                                ),
                                itemCount: displayedProduits.length,
                                itemBuilder: (context, index) {
                                  final p = displayedProduits[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.surface.withOpacity(0.15),
                                          colorScheme.surface.withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: colorScheme.onSurface.withOpacity(0.2)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () {
                                          // Action pour voir les détails du produit
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: p['images'] != null && p['images'].isNotEmpty
                                                      ? Image.network(
                                                          '${AppApi.baseUrl}${p['images'][0]}',
                                                          width: double.infinity,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (context, error, stackTrace) => Container(
                                                            color: colorScheme.surface.withOpacity(0.1),
                                                            child: Icon(Icons.error, size: 40, color: colorScheme.onSurface.withOpacity(0.6)),
                                                          ),
                                                        )
                                                      : Container(
                                                          color: colorScheme.surface.withOpacity(0.1),
                                                          child: Icon(Icons.image_not_supported, size: 40, color: colorScheme.onSurface.withOpacity(0.6)),
                                                        ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                p['nom'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold, 
                                                  fontSize: 16,
                                                  color: colorScheme.onSurface,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                p['unite'] != null ? p['unite']['nom'] : '',
                                                style: TextStyle(
                                                  color: colorScheme.onSurface.withOpacity(0.7), 
                                                  fontSize: 13,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${p['prix']} €",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold, 
                                                  color: colorScheme.onSurface,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
