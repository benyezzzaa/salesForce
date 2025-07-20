import 'package:get/get.dart';
import 'package:pfe/features/commande/services/commandes_modifiees_service.dart';

class CommandesModifieesController extends GetxController {
  final CommandesModifieesService _service = CommandesModifieesService();
  
  final commandesModifiees = <dynamic>[].obs;
  final notifications = <dynamic>[].obs;
  final isLoading = false.obs;
  final modificationsCount = 0.obs;
  final searchQuery = ''.obs;
  final selectedDate = Rxn<DateTime>();
  final sortMode = 'date'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCommandesModifiees();
    fetchNotifications();
    checkModificationsCount();
  }

  /// Récupérer les commandes modifiées
  Future<void> fetchCommandesModifiees() async {
    try {
      isLoading.value = true;
      final data = await _service.getCommandesModifiees();
      commandesModifiees.value = data;
      print('📄 CommandesModifieesController: ${data.length} commandes modifiées récupérées');
    } catch (e) {
      print('❌ Erreur fetchCommandesModifiees: $e');
      // Fallback vers les notifications
      try {
        final notifs = await _service.getNotificationsModifications();
        commandesModifiees.value = notifs;
        print('📄 CommandesModifieesController: ${notifs.length} notifications récupérées (fallback)');
      } catch (fallbackError) {
        print('❌ Erreur fallback: $fallbackError');
        commandesModifiees.value = [];
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Récupérer les notifications
  Future<void> fetchNotifications() async {
    try {
      final data = await _service.getNotificationsModifications();
      notifications.value = data;
      print('📄 CommandesModifieesController: ${data.length} notifications récupérées');
    } catch (e) {
      print('❌ Erreur fetchNotifications: $e');
      notifications.value = [];
    }
  }

  /// Vérifier le nombre de modifications non vues
  Future<void> checkModificationsCount() async {
    try {
      final count = await _service.getNombreModificationsNonVues();
      modificationsCount.value = count;
      print('📄 CommandesModifieesController: $count modifications non vues');
    } catch (e) {
      print('❌ Erreur checkModificationsCount: $e');
      modificationsCount.value = 0;
    }
  }

  /// Marquer une commande comme vue
  Future<void> marquerCommeVue(int commandeId) async {
    try {
      final success = await _service.marquerCommeVue(commandeId);
      if (success) {
        // Mettre à jour la liste locale
        commandesModifiees.value = commandesModifiees.map((cmd) {
          if (cmd['id'] == commandeId || cmd['commande']?['id'] == commandeId) {
            return {...cmd, 'vu': true};
          }
          return cmd;
        }).toList();
        
        // Recalculer le nombre de modifications non vues
        await checkModificationsCount();
        
        Get.snackbar(
          'Succès',
          'Commande marquée comme vue',
          backgroundColor: Get.theme?.colorScheme?.primaryContainer,
          colorText: Get.theme?.colorScheme?.onPrimaryContainer,
        );
      }
    } catch (e) {
      print('❌ Erreur marquerCommeVue: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de marquer comme vue',
        backgroundColor: Get.theme?.colorScheme?.errorContainer,
        colorText: Get.theme?.colorScheme?.onErrorContainer,
      );
    }
  }

  /// Marquer toutes les modifications comme vues
  Future<void> marquerToutesCommeVues() async {
    try {
      final success = await _service.marquerToutesCommeVues();
      if (success) {
        // Marquer toutes les commandes comme vues localement
        commandesModifiees.value = commandesModifiees.map((cmd) => {...cmd, 'vu': true}).toList();
        modificationsCount.value = 0;
        
        Get.snackbar(
          'Succès',
          'Toutes les modifications marquées comme vues',
          backgroundColor: Get.theme?.colorScheme?.primaryContainer,
          colorText: Get.theme?.colorScheme?.onPrimaryContainer,
        );
      }
    } catch (e) {
      print('❌ Erreur marquerToutesCommeVues: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de marquer toutes comme vues',
        backgroundColor: Get.theme?.colorScheme?.errorContainer,
        colorText: Get.theme?.colorScheme?.onErrorContainer,
      );
    }
  }

  /// Filtrer les commandes selon les critères
  List<dynamic> get filteredCommandes {
    return commandesModifiees.where((cmd) {
      final commande = cmd['commande'] ?? cmd;
      final numeroCommande = commande['numero_commande']?.toString() ?? '';
      final clientNom = '${commande['client']?['prenom'] ?? ''} ${commande['client']?['nom'] ?? ''}'.trim();
      
      // Filtrer par recherche
      final matchesSearch = numeroCommande.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          clientNom.toLowerCase().contains(searchQuery.value.toLowerCase());
      
      // Filtrer par date si sélectionnée
      final matchesDate = selectedDate.value == null ||
        commande['dateCreation'] != null &&
        commande['dateCreation'].toString().startsWith(selectedDate.value.toString().substring(0, 10));
      
      return matchesSearch && matchesDate;
    }).toList();
  }

  /// Trier les commandes
  List<dynamic> get sortedCommandes {
    final filtered = filteredCommandes;
    
    if (sortMode.value == 'date') {
      filtered.sort((a, b) {
        final dateA = DateTime.parse((a['commande'] ?? a)['dateCreation']);
        final dateB = DateTime.parse((b['commande'] ?? b)['dateCreation']);
        return dateB.compareTo(dateA);
      });
    } else if (sortMode.value == 'montant') {
      filtered.sort((a, b) {
        final montantA = double.tryParse((a['commande'] ?? a)['prix_total_ttc'].toString()) ?? 0;
        final montantB = double.tryParse((b['commande'] ?? b)['prix_total_ttc'].toString()) ?? 0;
        return montantB.compareTo(montantA);
      });
    }
    
    return filtered;
  }

  /// Rafraîchir toutes les données
  Future<void> refresh() async {
    await Future.wait([
      fetchCommandesModifiees(),
      fetchNotifications(),
      checkModificationsCount(),
    ]);
  }

  /// Définir la requête de recherche
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Définir la date sélectionnée
  void setSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }

  /// Définir le mode de tri
  void setSortMode(String mode) {
    sortMode.value = mode;
  }

  /// Obtenir les statistiques
  Map<String, int> get statistiques {
    final total = commandesModifiees.length;
    final nonVues = commandesModifiees.where((cmd) => cmd['vu'] != true).length;
    final vues = total - nonVues;
    
    return {
      'total': total,
      'nonVues': nonVues,
      'vues': vues,
    };
  }
} 