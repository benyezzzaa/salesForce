import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelloPage extends StatelessWidget {
  const HelloPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Commencer'),
          onPressed: () => context.go('/login'),
        ),
      ),
    );
  }
}
