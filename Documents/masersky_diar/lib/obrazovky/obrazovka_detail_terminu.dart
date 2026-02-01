import 'package:flutter/material.dart';

import '../modely/termin_detail.dart';
import '../sluzby/databaza.dart';
import '../sluzby/spustac_odkazov.dart';
import '../sluzby/notifikacie.dart';

class ObrazovkaDetailTerminu extends StatefulWidget {
  final int idTerminu;

  const ObrazovkaDetailTerminu({super.key, required this.idTerminu});

  @override
  State<ObrazovkaDetailTerminu> createState() => _ObrazovkaDetailTerminuState();
}

class _ObrazovkaDetailTerminuState extends State<ObrazovkaDetailTerminu> {
  late Future<TerminDetail?> _buduciDetail;

  @override
  void initState() {
    super.initState();
    _buduciDetail = Databaza.instancia.nacitajTerminDetail(widget.idTerminu);
  }

  String _formatDatumCas(DateTime dt) {
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$dd.$mm.$yyyy  $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail termínu'),
        actions: [
          IconButton(
            tooltip: 'Vymazať termín',
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final potvrdit = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Vymazať termín?'),
                  content: const Text('Naozaj chceš vymazať tento termín?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Nie'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Áno, vymazať'),
                    ),
                  ],
                ),
              );

              if (potvrdit != true) return;

              try {
                final idNotif = await Databaza.instancia
                    .nacitajIdNotifikaciePreTermin(widget.idTerminu);

                if (idNotif != null) {
                  await Notifikacie.zrusNotifikaciu(idNotif);
                }

                await Databaza.instancia.vymazTermin(widget.idTerminu);

                if (context.mounted) {
                  Navigator.of(context).pop(true);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Vymazanie zlyhalo: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),

      body: FutureBuilder<TerminDetail?>(
        future: _buduciDetail,
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

          final d = snapshot.data;
          if (d == null) {
            return const Center(child: Text('Termín sa nenašiel.'));
          }

          final cenaText = d.cena == null ? '—' : '${d.cena!.toStringAsFixed(2)} €';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                d.nazovSluzby,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),

              _RiadokInfo(nazov: 'Dátum a čas', hodnota: _formatDatumCas(d.zaciatok)),
              _RiadokInfo(nazov: 'Trvanie', hodnota: '${d.trvanieMin} min'),
              _RiadokInfo(nazov: 'Cena', hodnota: cenaText),
              _RiadokInfo(nazov: 'Stav', hodnota: d.stav),

              const SizedBox(height: 16),
              Text(
                'Klient',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.menoKlienta,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text('Telefón: ${d.telefonKlienta}'),
                      Text('E-mail: ${d.emailKlienta ?? '—'}'),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: () async {
                              try {
                                await SpustacOdkazov.zavolat(d.telefonKlienta);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Nepodarilo sa zavolať: $e')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.call),
                            label: const Text('Zavolať'),
                          ),
                          FilledButton.icon(
                            onPressed: () async {
                              try {
                                await SpustacOdkazov.poslatSms(
                                  d.telefonKlienta,
                                  text: 'Dobrý deň, pripomínam termín masáže...',
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Nepodarilo sa otvoriť SMS: $e')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.sms),
                            label: const Text('SMS'),
                          ),
                          FilledButton.icon(
                            onPressed: (d.emailKlienta == null || d.emailKlienta!.isEmpty)
                                ? null
                                : () async {
                                    try {
                                      await SpustacOdkazov.poslatEmail(
                                        d.emailKlienta!,
                                        predmet: 'Masáž – informácia',
                                        telo:
                                            'Dobrý deň,\n\nposielam informáciu k termínu masáže.\n',
                                      );
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Nepodarilo sa otvoriť e-mail: $e')),
                                        );
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.email),
                            label: const Text('E-mail'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Poznámka',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(d.poznamka?.trim().isNotEmpty == true ? d.poznamka! : '—'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RiadokInfo extends StatelessWidget {
  final String nazov;
  final String hodnota;

  const _RiadokInfo({required this.nazov, required this.hodnota});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              nazov,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(hodnota)),
        ],
      ),
    );
  }
}
