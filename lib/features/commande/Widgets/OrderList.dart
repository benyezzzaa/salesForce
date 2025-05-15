import 'package:flutter/material.dart';

class OrderList extends StatelessWidget {
  const OrderList({super.key});

  final List<Map<String, dynamic>> orders = const [
    {
      "numero": "1001",
      "date": "04/03/2024",
      "montant": "512,00 €",
      "statut": "validée"
    },
    {
      "numero": "1002",
      "date": "04/03/2024",
      "montant": "545,00 €",
      "statut": "en_attente"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Infos de gauche
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("N° ${order['numero']}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(order['date'], style: const TextStyle(color: Colors.white60)),
                ],
              ),
              // Montant + statut
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(order['montant'], style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: order['statut'] == "validée" ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order['statut'] == "validée" ? "Validée" : "En attente",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
