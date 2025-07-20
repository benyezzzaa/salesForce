import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pfe/features/commande/models/commande_model.dart';
import 'package:pfe/features/commande/services/commandes_modifiees_service.dart';

class CommandeModifieeDetailsPage extends StatefulWidget {
  final CommandeModel commande;
  final Map<String, dynamic>? modifications;
  
  const CommandeModifieeDetailsPage({
    super.key, 
    required this.commande,
    this.modifications,
  });

  @override
  State<CommandeModifieeDetailsPage> createState() => _CommandeModifieeDetailsPageState();
}

class _CommandeModifieeDetailsPageState extends State<CommandeModifieeDetailsPage> {
  final CommandesModifieesService _service = CommandesModifieesService();
  Map<String, dynamic>? detailsModifications;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetailsModifications();
  }

  Future<void> _loadDetailsModifications() async {
    setState(() => isLoading = true);
    try {
      final details = await _service.getDetailsCommandeModifiee(widget.commande.id);
      setState(() {
        detailsModifications = details;
        isLoading = false;
      });
    } catch (e) {
      print("Erreur chargement détails modifications : $e");
      setState(() => isLoading = false);
    }
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

  Widget _buildModificationCard(String title, String? oldValue, String? newValue) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasChanged = oldValue != newValue;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: hasChanged ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: hasChanged 
            ? BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasChanged ? Icons.edit : Icons.check,
                  color: hasChanged ? Colors.orange : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: hasChanged ? Colors.orange.shade700 : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (hasChanged) ...[
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ancienne valeur',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            oldValue ?? 'Non définie',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouvelle valeur',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            newValue ?? 'Non définie',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  newValue ?? 'Non définie',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Détails modifications',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDetailsModifications,
          ),
        ],
        elevation: 2,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de la commande
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: colorScheme.primary,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Commande ${widget.commande.numeroCommande}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      'Client: ${widget.commande.clientNom}',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(widget.commande.statut).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getStatusText(widget.commande.statut),
                                  style: TextStyle(
                                    color: _getStatusColor(widget.commande.statut),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date de création',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(widget.commande.dateCreation),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total TTC',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${widget.commande.prixTotalTTC.toStringAsFixed(2)} €',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section des modifications
                  Text(
                    'Modifications apportées',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (detailsModifications != null) ...[
                    // Statut
                    _buildModificationCard(
                      'Statut',
                      detailsModifications!['ancien_statut'],
                      detailsModifications!['nouveau_statut'],
                    ),
                    
                    // Prix total
                    _buildModificationCard(
                      'Prix total TTC',
                      detailsModifications!['ancien_prix_total'] != null 
                          ? '${detailsModifications!['ancien_prix_total']} €'
                          : null,
                      detailsModifications!['nouveau_prix_total'] != null 
                          ? '${detailsModifications!['nouveau_prix_total']} €'
                          : null,
                    ),
                    
                    // Date de modification
                    if (detailsModifications!['date_modification'] != null)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Modifiée le: ${_formatDate(detailsModifications!['date_modification'])}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Modifié par
                    if (detailsModifications!['modifie_par'] != null)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.purple),
                              const SizedBox(width: 8),
                              Text(
                                'Modifié par: ${detailsModifications!['modifie_par']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Raison de la modification
                    if (detailsModifications!['raison_modification'] != null)
                      Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info, color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Raison de la modification',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                detailsModifications!['raison_modification'],
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun détail de modification disponible',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Les détails des modifications ne sont pas encore disponibles pour cette commande.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Bouton pour marquer comme vue
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final success = await _service.marquerCommeVue(widget.commande.id);
                          if (success) {
                            Get.snackbar(
                              'Succès',
                              'Commande marquée comme vue',
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                            Get.back();
                          }
                        } catch (e) {
                          Get.snackbar(
                            'Erreur',
                            'Impossible de marquer comme vue',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Marquer comme vue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 