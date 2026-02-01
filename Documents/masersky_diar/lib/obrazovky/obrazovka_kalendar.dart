import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modely/termin.dart';
import '../sluzby/databaza.dart';

class ObrazovkaKalendar extends StatefulWidget {
  const ObrazovkaKalendar({super.key});

  @override
  State<ObrazovkaKalendar> createState() => _ObrazovkaKalendarState();
}

class _ObrazovkaKalendarState extends State<ObrazovkaKalendar> {
  DateTime _vybranyDen = DateTime.now();
  late Future<List<Termin>> _buduceTerminy;

  @override
  void initState() {
    super.initState();
    _obnov();
  }

  void _obnov() {
    _buduceTerminy = Databaza.instancia.nacitajTerminyPreDen(_vybranyDen);
  }

  Future<void> _vyberDatum() async {
    final dnes = DateTime.now();
    final vybrany = await showDatePicker(
      context: context,
      initialDate: _vybranyDen,
      firstDate: DateTime(dnes.year - 1),
      lastDate: DateTime(dnes.year + 2),
    );
    if (vybrany != null) {
      setState(() {
        _vybranyDen = vybrany;
        _obnov();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final datumText =
        '${_vybranyDen.day}.${_vybranyDen.month}.${_vybranyDen.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalendár'),
        actions: [
          IconButton(
            onPressed: _vyberDatum,
            icon: const Icon(Icons.date_range),
            tooltip: 'Vybrať dátum',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/terminy/pridat');
          setState(_obnov);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Termíny na deň: $datumText',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<Termin>>(
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
                  return const Center(child: Text('Na tento deň nie sú termíny.'));
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
