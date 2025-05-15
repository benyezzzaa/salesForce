import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';


class ObjectivesCard extends StatelessWidget {
  const ObjectivesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mes Objectifs", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _buildProgress("Ventes", 0.90, Colors.orange),
          _buildProgress("Visites", 0.75, Colors.green),
          _buildProgress("Commandes", 0.50, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildProgress(String title, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: Colors.white)),
        LinearPercentIndicator(
          lineHeight: 8.0,
          percent: value,
          backgroundColor: Colors.white24,
          progressColor: color,
          barRadius: const Radius.circular(8),
        ),
      ],
    );
  }
}
