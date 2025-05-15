import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Icon(Icons.notifications, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "3 nouvelles réclamations\nObjectif ventes à 90 % ! Bravo 👏",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
