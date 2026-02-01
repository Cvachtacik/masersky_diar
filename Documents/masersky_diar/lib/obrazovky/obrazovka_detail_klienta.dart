import 'package:flutter/material.dart';

import '../modely/klient.dart';
import '../sluzby/databaza.dart';
import 'obrazovka_pridat_upravit_klienta.dart';

class ObrazovkaDetailKlienta extends StatefulWidget {
  final int idKlienta;

  const ObrazovkaDetailKlienta({super.key, required this.idKlienta});

  @override
  State<ObrazovkaDetailKlienta> createState() => _ObrazovkaDetailKlientaState();
}

class _ObrazovkaDetailKlientaState extends State<ObrazovkaDetailKlienta> {
  late Future<Klient?> _buduciKlient;

  @override
  void initState() {
    super.initState();
    _obnov();
  }

  void _obnov() {
    _buduciKlient = Databaza.instancia.nacitajKlientaPodlaId(widget.idKlienta);
  }

  Future<void> _upravit() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ObrazovkaPridatAleboUpravitKlienta(idKlienta: widget.idKlienta),
      ),
    );
    setState(_obnov);
  }

  Future<void> _vymazat() async {
    final potvrdene = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vymazať klienta?'),
        content: const Text('Túto akciu nie je možné vrátiť späť.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Zrušiť'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Vymazať'),
          ),
        ],
      ),
    );

    if (potvrdene != true) return;

    await Databaza.instancia.vymazKlienta(widget.idKlienta);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail klienta'),
        actions: [
          IconButton(
            onPressed: _upravit,
            icon: const Icon(Icons.edit),
            tooltip: 'Upraviť',
          ),
          IconButton(
            onPressed: _vymazat,
            icon: const Icon(Icons.delete),
            tooltip: 'Vymazať',
          ),
        ],
      ),
      body: FutureBuilder<Klient?>(
        future: _buduciKlient,
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

          final klient = snapshot.data;
          if (klient == null) {
            return const Center(child: Text('Klient sa nenašiel.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  klient.meno,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Telefón: ${klient.telefon}'),
                const SizedBox(height: 6),
                Text('E-mail: ${klient.email ?? '—'}'),
                const SizedBox(height: 12),
                Text('Poznámka: ${klient.poznamka ?? '—'}'),
                const SizedBox(height: 24),
                const Text(
                  'Rýchle akcie (pridáme v ďalšom kroku):',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: const [
                    Chip(label: Text('Zavolať')),
                    Chip(label: Text('SMS')),
                    Chip(label: Text('E-mail')),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
