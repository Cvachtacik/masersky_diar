import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modely/termin.dart';
import '../sluzby/databaza.dart';

class ObrazovkaDnes extends StatefulWidget {
  const ObrazovkaDnes({super.key});

  @override
  State<ObrazovkaDnes> createState() => _ObrazovkaDnesState();
}

class _ObrazovkaDnesState extends State<ObrazovkaDnes> {
  late Future<List<Termin>> _buduceTerminy;

  @override
  void initState() {
    super.initState();
    _obnov();
  }

  void _obnov() {
    _buduceTerminy = Databaza.instancia.nacitajTerminyPreDen(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dnešné termíny')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/terminy/pridat');
          setState(_obnov);
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Termin>>(
        future: _buduceTerminy,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Chyba: ${snapshot.error}'),
            );
          }

          final terminy = snapshot.data ?? [];
          if (terminy.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Dnes nemáš žiadne termíny. Pridaj nový cez +.'),
              ),
            );
          }

          return ListView.separated(
            itemCount: terminy.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final t = terminy[i];
              final h = t.zaciatok.hour.toString().padLeft(2, '0');
              final m = t.zaciatok.minute.toString().padLeft(2, '0');

              return ListTile(
                title: Text('${t.nazovSluzby} (${t.trvanieMin} min)'),
                subtitle: Text('Čas: $h:$m'),
                // neskôr: detail termínu
              );
            },
          );
        },
      ),
    );
  }
}
