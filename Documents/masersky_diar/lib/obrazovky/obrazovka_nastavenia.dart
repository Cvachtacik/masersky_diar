import 'package:flutter/material.dart';

class ObrazovkaNastavenia extends StatelessWidget {
  const ObrazovkaNastavenia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nastavenia')),
      body: const Center(child: Text('Tu budú nastavenia (notifikácie, export...).')),
    );
  }
}
