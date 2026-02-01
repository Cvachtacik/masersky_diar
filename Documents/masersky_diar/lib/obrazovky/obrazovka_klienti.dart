import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modely/klient.dart';
import '../sluzby/databaza.dart';

class ObrazovkaKlienti extends StatefulWidget {
  const ObrazovkaKlienti({super.key});

  @override
  State<ObrazovkaKlienti> createState() => _ObrazovkaKlientiState();
}

class _ObrazovkaKlientiState extends State<ObrazovkaKlienti> {
  late Future<List<Klient>> _buduciZoznam;

  @override
  void initState() {
    super.initState();
    _obnovZoznam();
  }

  void _obnovZoznam() {
    _buduciZoznam = Databaza.instancia.nacitajKlientov();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Klienti')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/klienti/pridat');
          setState(_obnovZoznam);
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Klient>>(
        future: _buduciZoznam,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Chyba pri načítaní klientov: ${snapshot.error}'),
            );
          }

          final klienti = snapshot.data ?? [];
          if (klienti.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Zatiaľ nemáš žiadnych klientov. Pridaj prvého cez +.'),
              ),
            );
          }

          return ListView.separated(
            itemCount: klienti.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final klient = klienti[index];
              return ListTile(
                title: Text(klient.meno),
                subtitle: Text(klient.telefon),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await context.push('/klienti/${klient.id}');
                  setState(_obnovZoznam);
                },
              );
            },
          );
        },
      ),
    );
  }
}
