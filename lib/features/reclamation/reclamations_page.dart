import 'package:flutter/material.dart';

class ReclamationsPage extends StatefulWidget {
  const ReclamationsPage({super.key});

  @override
  State<ReclamationsPage> createState() => _ReclamationsPageState();
}

class _ReclamationsPageState extends State<ReclamationsPage> {
  final List<Map<String, String>> reclamations = [
    {
      'titre': 'Problème de livraison',
      'description': 'Le client n’a pas reçu le bon produit.',
      'date': '2024-05-01',
    },
    {
      'titre': 'Produit endommagé',
      'description': 'Le produit était cassé à l’arrivée.',
      'date': '2024-04-28',
    },
    {
      'titre': 'Erreur de commande',
      'description': 'Commande incomplète (manque 2 articles).',
      'date': '2024-04-25',
    },
  ];

  void openAjoutReclamation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F5B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: _FormulaireReclamation(
          onSubmit: (newReclamation) {
            setState(() {
              reclamations.add(newReclamation);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191A49),
      appBar: AppBar(
        title: const Text('Mes Réclamations'),
        backgroundColor: const Color(0xFF191A49),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reclamations.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final r = reclamations[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['titre']!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(r['description']!,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text("📅 ${r['date']!}",
                    style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: openAjoutReclamation,
      ),
    );
  }
}

class _FormulaireReclamation extends StatefulWidget {
  final Function(Map<String, String>) onSubmit;
  const _FormulaireReclamation({required this.onSubmit});

  @override
  State<_FormulaireReclamation> createState() => _FormulaireReclamationState();
}

class _FormulaireReclamationState extends State<_FormulaireReclamation> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? selectedDate;

  void pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  void submit() {
    if (_formKey.currentState!.validate() && selectedDate != null) {
      widget.onSubmit({
        'titre': _titreController.text,
        'description': _descController.text,
        'date': selectedDate!.toLocal().toString().split(' ')[0],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titreController,
            decoration: const InputDecoration(
              labelText: 'Titre',
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (v) => v == null || v.isEmpty ? 'Titre requis' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description',
              filled: true,
              fillColor: Colors.white,
            ),
            validator: (v) => v == null || v.isEmpty ? 'Description requise' : null,
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                selectedDate != null
                    ? selectedDate!.toLocal().toString().split(' ')[0]
                    : "Date non choisie",
                style: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: pickDate,
                child: const Text("Choisir la date"),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: submit,
            icon: const Icon(Icons.send),
            label: const Text("Soumettre"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
        ],
      ),
    );
  }
}
