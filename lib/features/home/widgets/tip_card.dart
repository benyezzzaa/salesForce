import 'package:flutter/material.dart';

class TipCard extends StatelessWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: const [
          Icon(Icons.lightbulb, color: Colors.yellowAccent),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Astuce : Toujours proposer un produit complémentaire en fin de commande.",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
