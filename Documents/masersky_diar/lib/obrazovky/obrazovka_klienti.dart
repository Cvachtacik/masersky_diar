import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ObrazovkaKlienti extends StatelessWidget {
  const ObrazovkaKlienti({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klienti')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/klienti/pridat'),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Ukážkový klient (klik)'),
            subtitle: const Text('+421 900 000 000'),
            onTap: () => context.push('/klienti/1'),
          ),
        ],
      ),
    );
  }
}
