import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pfe/core/utils/app_api.dart';
import 'package:pfe/core/utils/app_services.dart';
import 'package:pfe/features/commande/services/commandes_modifiees_service.dart';

class DocumentsValidesPage extends StatefulWidget {
  const DocumentsValidesPage({super.key});

  @override
  State<DocumentsValidesPage> createState() => _DocumentsValidesPageState();
}

class _DocumentsValidesPageState extends State<DocumentsValidesPage> with SingleTickerProviderStateMixin {
  final ApiService api = ApiService();
  final CommandesModifieesService _modificationsService = CommandesModifieesService();
  List<dynamic> documents = [];
  List<dynamic> commandesModifiees = [];
  bool isLoading = true;
  bool hasModifications = false;
  String searchQuery = '';
  DateTime? selectedDate;
  List<dynamic> notifications = [];
  bool hasNotifications = false;
  int modificationsCount = 0;
  int currentTabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentTabIndex = _tabController.index;
      });
    });
    fetchDocuments();
    fetchNotifications();
    fetchCommandesModifiees();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchDocuments() async {
    setState(() => isLoading = true);
    try {
      // Récupérer les commandes du commercial connecté
      final response = await api.get("${AppApi.getCommandeUrl}/me");
      documents = response.data;
      print("📄 Documents récupérés pour le commercial: ${documents.length} commandes");
    } catch (e) {
      print("Erreur chargement documents : $e");
      // En cas d'erreur, essayer de récupérer toutes les commandes validées
      try {
        final response = await api.get("${AppApi.getCommandeUrl}/validees");
        documents = response.data;
        print("📄 Documents récupérés (fallback): ${documents.length} commandes");
      } catch (fallbackError) {
        print("Erreur fallback chargement documents : $fallbackError");
        documents = [];
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await api.get("${AppApi.getCommandeUrl}/notifications");
      notifications = response.data;
      setState(() {
        hasNotifications = notifications.any((n) => n['vu'] != true);
      });
      if (hasNotifications) {
        _showNotificationsAlert();
      }
    } catch (e) {
      print("Erreur chargement notifications : $e");
    }
  }

  void _showModificationAlert() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications_active, color: Colors.orange.shade600, size: 28),
            const SizedBox(width: 12),
            const Text("Modifications détectées"),
          ],
        ),
        content: Text(
          "Vous avez ${commandesModifiees.length} commande${commandesModifiees.length > 1 ? 's' : ''} qui a ${commandesModifiees.length > 1 ? 'ont' : 'a'} été modifiée${commandesModifiees.length > 1 ? 's' : ''} par l'administrateur.",
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Fermer"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Marquer comme vues et rafraîchir
              _markAsViewed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text("Voir les détails"),
          ),
        ],
      ),
    );
  }

  void _showNotificationsAlert() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications, color: Colors.orange.shade600, size: 28),
            const SizedBox(width: 12),
            const Text("Modifications de vos commandes"),
          ],
        ),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: notifications.map<Widget>((notif) => ListTile(
              leading: const Icon(Icons.edit, color: Colors.orange),
              title: Text("Commande n°${notif['numero_commande'] ?? notif['commande']?['numero_commande'] ?? ''}"),
              subtitle: Text(notif['message'] ?? "Votre commande a été modifiée"),
              trailing: notif['vu'] == true
                  ? const Icon(Icons.check, color: Colors.green)
                  : TextButton(
                      onPressed: () => markNotificationAsSeen(notif['id']),
                      child: const Text("Marquer comme vu"),
                    ),
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Fermer"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> markNotificationAsSeen(int id) async {
    try {
      await api.put("${AppApi.getCommandeUrl}/notifications/$id/vu", {});
      setState(() {
        notifications = notifications.map((n) {
          if (n['id'] == id) return {...n, 'vu': true};
          return n;
        }).toList();
        hasNotifications = notifications.any((n) => n['vu'] != true);
      });
      if (!hasNotifications) Get.back();
    } catch (e) {
      print("Erreur lors du marquage comme vu : $e");
    }
  }

  Future<void> fetchCommandesModifiees() async {
    try {
      commandesModifiees = await _modificationsService.getCommandesModifiees();
      final count = await _modificationsService.getNombreModificationsNonVues();
      setState(() {
        modificationsCount = count;
        hasModifications = count > 0;
      });
      print("📄 Commandes modifiées récupérées: ${commandesModifiees.length}");
    } catch (e) {
      print("Erreur chargement commandes modifiées : $e");
      setState(() {
        commandesModifiees = [];
        modificationsCount = 0;
        hasModifications = false;
      });
    }
  }

  Future<void> _markAsViewed() async {
    try {
      await api.patch("${AppApi.getCommandeUrl}/historique/vue", {});
      setState(() {
        hasModifications = false;
      });
      print("✅ Modifications marquées comme vues");
    } catch (e) {
      print("Erreur marquage comme vues: $e");
    }
  }

  List<dynamic> get filteredDocuments {
    return documents.where((doc) {
      // Filtrer uniquement les commandes validées
      final isValid = (doc['statut']?.toLowerCase() == 'validée' || 
                      doc['statut']?.toLowerCase() == 'validee' ||
                      doc['statut']?.toLowerCase() == 'validated');
      // Filtrer par recherche
      final matchesSearch = doc['numero_commande'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc['client']['nom'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          doc['client']['prenom'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      // Filtrer par date si sélectionnée
      final matchesDate = selectedDate == null ||
        DateFormat('yyyy-MM-dd').format(DateTime.parse(doc['dateCreation'])) == DateFormat('yyyy-MM-dd').format(selectedDate!);
      return isValid && matchesSearch && matchesDate;
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade400,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.blue.shade900,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        elevation: 1,
        title: Column(
          children: [
            const Text(
              "Mes Documents",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              "Commercial connecté",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8), 
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 18),
                  const SizedBox(width: 8),
                  Text('Commandes Validées'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note, size: 18),
                  const SizedBox(width: 8),
                  Text('Modifiées'),
                  if (modificationsCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        modificationsCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barre de recherche et filtre date
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: currentTabIndex == 0 
                            ? 'Rechercher une commande ou un client...'
                            : 'Rechercher une commande modifiée...',
                        hintStyle: TextStyle(color: Colors.blueGrey.shade300),
                        prefixIcon: Icon(Icons.search, color: Colors.blueGrey.shade300),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _selectDate(context),
                    icon: Icon(Icons.calendar_today, color: Colors.blue.shade700),
                    label: Text(
                      selectedDate == null
                        ? 'Date'
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade200),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  if (selectedDate != null)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.red.shade300),
                      tooltip: 'Effacer la date',
                      onPressed: () => setState(() => selectedDate = null),
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Onglet Commandes Validées
                  _buildCommandesValideesTab(),
                  // Onglet Commandes Modifiées
                  _buildCommandesModifieesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandesValideesTab() {
    return isLoading
        ? Center(child: CircularProgressIndicator(color: Colors.blue.shade400))
        : filteredDocuments.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.blueGrey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Aucune commande validée trouvée",
                      style: TextStyle(
                        color: Colors.blueGrey.shade400, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Vos commandes validées apparaîtront ici",
                      style: TextStyle(
                        color: Colors.blueGrey.shade300, 
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final doc = filteredDocuments[index];
                  final totalTtc = double.tryParse(doc['prix_total_ttc'].toString()) ?? 0;
                  return _buildDocumentCard(doc, totalTtc);
                },
              );
  }

  Widget _buildCommandesModifieesTab() {
    final filteredModifications = commandesModifiees.where((cmd) {
      final commande = cmd['commande'] ?? cmd;
      final numeroCommande = commande['numero_commande']?.toString() ?? '';
      final clientNom = '${commande['client']?['prenom'] ?? ''} ${commande['client']?['nom'] ?? ''}'.trim();
      
      // Filtrer par recherche
      final matchesSearch = numeroCommande.toLowerCase().contains(searchQuery.toLowerCase()) ||
          clientNom.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Filtrer par date si sélectionnée
      final matchesDate = selectedDate == null ||
        commande['dateCreation'] != null &&
        commande['dateCreation'].toString().startsWith(selectedDate.toString().substring(0, 10));
      
      return matchesSearch && matchesDate;
    }).toList();

    return filteredModifications.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_note,
                  size: 64,
                  color: Colors.blueGrey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  "Aucune commande modifiée",
                  style: TextStyle(
                    color: Colors.blueGrey.shade400, 
                    fontSize: 16, 
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Les commandes modifiées par l'admin apparaîtront ici",
                  style: TextStyle(
                    color: Colors.blueGrey.shade300, 
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredModifications.length,
            itemBuilder: (context, index) {
              final cmd = filteredModifications[index];
              return _buildCommandeModifieeCard(cmd);
            },
          );
  }

  Widget _buildDocumentCard(dynamic doc, double totalTtc) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: Colors.blue.shade400, size: 22),
                const SizedBox(width: 8),
                Text(
                  doc['numero_commande'],
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Icon(Icons.verified, color: Colors.green.shade400, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Validée',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blueGrey.shade300, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${doc['client']['prenom']} ${doc['client']['nom']}',
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blueGrey.shade300, size: 16),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(doc['dateCreation'])),
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(Icons.attach_money, color: Colors.blueGrey.shade300, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${totalTtc.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _downloadDocument(doc),
                icon: Icon(Icons.download_rounded, color: Colors.blue.shade900, size: 20),
                label: Text(
                  'Télécharger PDF',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommandeModifieeCard(dynamic cmd) {
    final commande = cmd['commande'] ?? cmd;
    final isVu = cmd['vu'] == true;
    final totalTtc = double.tryParse(commande['prix_total_ttc'].toString()) ?? 0;
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isVu 
            ? BorderSide.none
            : BorderSide(color: Colors.orange, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isVu ? Icons.check : Icons.edit,
                  color: isVu ? Colors.green.shade400 : Colors.orange.shade600,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    commande['numero_commande'],
                    style: TextStyle(
                      color: isVu ? Colors.blue.shade900 : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (!isVu)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Nouveau',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person, color: Colors.blueGrey.shade300, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${commande['client']?['prenom'] ?? ''} ${commande['client']?['nom'] ?? 'Inconnu'}',
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blueGrey.shade300, size: 16),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(commande['dateCreation'])),
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(Icons.attach_money, color: Colors.blueGrey.shade300, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${totalTtc.toStringAsFixed(2)} €',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _viewModifications(commande),
                    icon: Icon(Icons.visibility, color: Colors.blue.shade900, size: 20),
                    label: Text(
                      'Voir les modifications',
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade100,
                      foregroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                    ),
                  ),
                ),
                if (!isVu) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _markAsSeen(commande['id']),
                    icon: Icon(Icons.check, color: Colors.white, size: 20),
                    label: Text(
                      'Marquer vu',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewModifications(dynamic commande) {
    // Navigation vers la page de détails des modifications
    Get.toNamed('/commandes/modifiees/details', arguments: {
      'commande': commande,
      'modifications': commande,
    });
  }

  void _markAsSeen(int commandeId) async {
    try {
      final success = await _modificationsService.marquerCommeVue(commandeId);
      if (success) {
        setState(() {
          commandesModifiees = commandesModifiees.map((cmd) {
            if (cmd['id'] == commandeId || cmd['commande']?['id'] == commandeId) {
              return {...cmd, 'vu': true};
            }
            return cmd;
          }).toList();
        });
        await fetchCommandesModifiees(); // Recalculer le compteur
        Get.snackbar(
          'Succès',
          'Commande marquée comme vue',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de marquer comme vue',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _downloadDocument(dynamic doc) async {
    final id = doc['id'];
    try {
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Téléchargement en cours...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      await api.downloadPdf(id);
      Get.back();
      Get.snackbar(
        "✅ Succès",
        "PDF téléchargé avec succès",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.back();
      Get.snackbar(
        "❌ Erreur",
        "Échec du téléchargement",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
        icon: Icon(Icons.error, color: Colors.white),
      );
    }
  }
}
