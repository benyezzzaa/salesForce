import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pfe/features/commande/services/commandes_modifiees_service.dart';
import 'package:pfe/features/commande/models/commande_model.dart';
import 'commande_details_page.dart';

class CommandesModifieesPage extends StatefulWidget {
  const CommandesModifieesPage({super.key});

  @override
  State<CommandesModifieesPage> createState() => _CommandesModifieesPageState();
}

class _CommandesModifieesPageState extends State<CommandesModifieesPage> {
  final CommandesModifieesService _service = CommandesModifieesService();
  List<dynamic> commandesModifiees = [];
  List<dynamic> notifications = [];
  bool isLoading = true;
  String searchQuery = '';
  DateTime? selectedDate;
  String sortMode = 'date';

  @override
  void initState() {
    super.initState();
    fetchCommandesModifiees();
    fetchNotifications();
  }

  Future<void> fetchCommandesModifiees() async {
    setState(() => isLoading = true);
    try {
      // Récupérer les commandes modifiées par l'admin
      commandesModifiees = await _service.getCommandesModifiees();
      print("📄 Commandes modifiées récupérées: ${commandesModifiees.length}");
    } catch (e) {
      print("Erreur chargement commandes modifiées : $e");
      // Fallback : essayer de récupérer depuis les notifications
      try {
        commandesModifiees = await _service.getNotificationsModifications();
        print("📄 Commandes modifiées récupérées (fallback): ${commandesModifiees.length}");
      } catch (fallbackError) {
        print("Erreur fallback chargement commandes modifiées : $fallbackError");
        commandesModifiees = [];
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchNotifications() async {
    try {
      notifications = await _service.getNotificationsModifications();
      print("📄 Notifications récupérées: ${notifications.length}");
    } catch (e) {
      print("Erreur chargement notifications : $e");
    }
  }

  Future<void> markAsSeen(int commandeId) async {
    try {
      final success = await _service.marquerCommeVue(commandeId);
      if (success) {
        setState(() {
          commandesModifiees = commandesModifiees.map((cmd) {
            if (cmd['id'] == commandeId || cmd['commande']?['id'] == commandeId) {
              return {...cmd, 'vu': true};
            }
            return cmd;
          }).toList();
        });
        print("✅ Commande marquée comme vue");
      }
    } catch (e) {
      print("Erreur marquage comme vue: $e");
    }
  }

  List<dynamic> get filteredCommandes {
    return commandesModifiees.where((cmd) {
      final commande = cmd['commande'] ?? cmd;
      final numeroCommande = commande['numero_commande']?.toString() ?? '';
      final clientNom = '${commande['client']?['prenom'] ?? ''} ${commande['client']?['nom'] ?? ''}'.trim();
      
      // Filtrer par recherche
      final matchesSearch = numeroCommande.toLowerCase().contains(searchQuery.toLowerCase()) ||
          clientNom.toLowerCase().contains(searchQuery.toLowerCase());
      
      // Filtrer par date si sélectionnée
      final matchesDate = selectedDate == null ||
        DateFormat('yyyy-MM-dd').format(DateTime.parse(commande['dateCreation'])) == 
        DateFormat('yyyy-MM-dd').format(selectedDate!);
      
      return matchesSearch && matchesDate;
    }).toList();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'validee':
        return 'Validée';
      case 'livree':
        return 'Livrée';
      case 'annulee':
        return 'Annulée';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return Colors.orange;
      case 'validee':
        return Colors.green;
      case 'livree':
        return Colors.blue;
      case 'annulee':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = filteredCommandes;

    // Trier les commandes
    if (sortMode == 'date') {
      filtered.sort((a, b) {
        final dateA = DateTime.parse((a['commande'] ?? a)['dateCreation']);
        final dateB = DateTime.parse((b['commande'] ?? b)['dateCreation']);
        return dateB.compareTo(dateA);
      });
    } else if (sortMode == 'montant') {
      filtered.sort((a, b) {
        final montantA = double.tryParse((a['commande'] ?? a)['prix_total_ttc'].toString()) ?? 0;
        final montantB = double.tryParse((b['commande'] ?? b)['prix_total_ttc'].toString()) ?? 0;
        return montantB.compareTo(montantA);
      });
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Commandes Modifiées',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => sortMode = value),
            icon: const Icon(Icons.sort, color: Colors.white),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Text('Trier par date',
                    style: TextStyle(color: colorScheme.onSurface)),
              ),
              PopupMenuItem(
                value: 'montant',
                child: Text('Trier par montant',
                    style: TextStyle(color: colorScheme.onSurface)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              fetchCommandesModifiees();
              fetchNotifications();
            },
          ),
        ],
        elevation: 2,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une commande ou un client...',
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                suffixIcon: selectedDate != null
                    ? IconButton(
                        icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                        onPressed: () => setState(() => selectedDate = null),
                      )
                    : IconButton(
                        icon: Icon(Icons.calendar_today, color: colorScheme.onSurfaceVariant),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                      ),
                filled: true,
                fillColor: colorScheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              onChanged: (val) => setState(() => searchQuery = val),
            ),
          ),
          
          // Statistiques
          if (filtered.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    '${filtered.length} commande${filtered.length > 1 ? 's' : ''} modifiée${filtered.length > 1 ? 's' : ''} par l\'admin',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // Liste des commandes
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: colorScheme.primary),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit_note,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune commande modifiée',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Les commandes modifiées par l\'admin apparaîtront ici',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final cmd = filtered[index];
                          final commande = cmd['commande'] ?? cmd;
                          final isVu = cmd['vu'] == true;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isVu 
                                  ? BorderSide.none
                                  : BorderSide(color: Colors.orange, width: 2),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: isVu 
                                    ? colorScheme.primaryContainer
                                    : Colors.orange.shade100,
                                child: Icon(
                                  isVu ? Icons.check : Icons.edit,
                                  color: isVu 
                                      ? colorScheme.onPrimaryContainer
                                      : Colors.orange.shade700,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Commande ${commande['numero_commande']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isVu 
                                            ? colorScheme.onSurface
                                            : Colors.orange.shade700,
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
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    'Client: ${commande['client']?['prenom'] ?? ''} ${commande['client']?['nom'] ?? 'Inconnu'}',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(commande['statut']).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          _getStatusText(commande['statut']),
                                          style: TextStyle(
                                            color: _getStatusColor(commande['statut']),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatDate(commande['dateCreation']),
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total: ${double.tryParse(commande['prix_total_ttc'].toString())?.toStringAsFixed(2) ?? '0.00'} €',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (!isVu)
                                        TextButton(
                                          onPressed: () => markAsSeen(commande['id']),
                                          child: const Text('Marquer comme vu'),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                                                             onTap: () {
                                 // Convertir en CommandeModel pour la page de détails
                                 final commandeModel = CommandeModel.fromJson(commande);
                                 Get.toNamed('/commandes/modifiees/details', arguments: {
                                   'commande': commandeModel,
                                   'modifications': cmd,
                                 });
                               },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
} 