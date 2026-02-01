import 'package:flutter/material.dart';

import '../modely/klient.dart';
import '../modely/termin.dart';
import '../sluzby/databaza.dart';
import '../sluzby/notifikacie.dart';

class ObrazovkaPridatAleboUpravitTermin extends StatefulWidget {
  const ObrazovkaPridatAleboUpravitTermin({super.key});

  @override
  State<ObrazovkaPridatAleboUpravitTermin> createState() =>
      _ObrazovkaPridatAleboUpravitTerminState();
}

class _ObrazovkaPridatAleboUpravitTerminState
    extends State<ObrazovkaPridatAleboUpravitTermin> {
  final _klucFormulara = GlobalKey<FormState>();

  List<Klient> _klienti = const [];
  int? _idVybratehoKlienta;

  DateTime _datum = DateTime.now();
  TimeOfDay _cas = TimeOfDay.now();

  final _sluzbaCtrl = TextEditingController(text: 'Masáž');
  final _trvanieCtrl = TextEditingController(text: '60');
  final _cenaCtrl = TextEditingController();
  final _poznamkaCtrl = TextEditingController();

  bool _upozornit = true;
  int _minPred = 60;

  bool _nacitavam = true;
  bool _ulozujem = false;

  @override
  void initState() {
    super.initState();
    _nacitajKlientov();
  }

  @override
  void dispose() {
    _sluzbaCtrl.dispose();
    _trvanieCtrl.dispose();
    _cenaCtrl.dispose();
    _poznamkaCtrl.dispose();
    super.dispose();
  }

  Future<void> _nacitajKlientov() async {
    setState(() => _nacitavam = true);
    try {
      final klienti = await Databaza.instancia.nacitajKlientov();
      setState(() {
        _klienti = klienti;
        _idVybratehoKlienta =
            klienti.isNotEmpty ? klienti.first.id : null;
      });
    } finally {
      if (mounted) setState(() => _nacitavam = false);
    }
  }

  Future<void> _vyberDatum() async {
    final dnes = DateTime.now();
    final vybrany = await showDatePicker(
      context: context,
      initialDate: _datum,
      firstDate: DateTime(dnes.year - 1),
      lastDate: DateTime(dnes.year + 2),
    );
    if (vybrany != null) {
      setState(() => _datum = vybrany);
    }
  }

  Future<void> _vyberCas() async {
    final vybrany = await showTimePicker(
      context: context,
      initialTime: _cas,
    );
    if (vybrany != null) {
      setState(() => _cas = vybrany);
    }
  }

  DateTime _zlozZaciatok() {
    return DateTime(
      _datum.year,
      _datum.month,
      _datum.day,
      _cas.hour,
      _cas.minute,
    );
  }

  String? _overPovinneText(String? v) {
    if (v == null || v.trim().isEmpty) return 'Povinné pole';
    return null;
  }

  String? _overTrvanie(String? v) {
    final s = (v ?? '').trim();
    final cislo = int.tryParse(s);
    if (cislo == null || cislo <= 0) return 'Zadaj trvanie v minútach';
    if (cislo > 600) return 'Trvanie je príliš veľké';
    return null;
  }

  String? _overCenu(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null; // voliteľné
    final cislo = double.tryParse(s.replaceAll(',', '.'));
    if (cislo == null || cislo < 0) return 'Zadaj platnú cenu';
    return null;
  }

  Future<void> _uloz() async {
    final validne = _klucFormulara.currentState?.validate() ?? false;
    if (!validne) return;

    if (_idVybratehoKlienta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Najprv pridaj aspoň jedného klienta.')),
      );
      return;
    }

    setState(() => _ulozujem = true);
    try {
      final trvanie = int.parse(_trvanieCtrl.text.trim());
      final cenaText = _cenaCtrl.text.trim();
      final cena = cenaText.isEmpty
          ? null
          : double.parse(cenaText.replaceAll(',', '.'));

      final termin = Termin(
        idKlienta: _idVybratehoKlienta!,
        zaciatok: _zlozZaciatok(),
        trvanieMin: trvanie,
        nazovSluzby: _sluzbaCtrl.text.trim(),
        cena: cena,
        poznamka: _poznamkaCtrl.text.trim().isEmpty
            ? null
            : _poznamkaCtrl.text.trim(),
      );

      final idTerminu = await Databaza.instancia.vlozTermin(termin);

      if (_upozornit) {
        final idNotif = Notifikacie.noveIdNotifikacie();
        final casNotifikacie = termin.zaciatok.subtract(Duration(minutes: _minPred));

        await Notifikacie.naplanujNotifikaciu(
          idNotifikacie: idNotif,
          casNotifikacie: casNotifikacie,
          titulok: 'Pripomienka termínu',
          text: '${termin.nazovSluzby} o ${termin.zaciatok.hour.toString().padLeft(2, '0')}:${termin.zaciatok.minute.toString().padLeft(2, '0')}',
        );

        await Databaza.instancia.nastavNotifikaciuPreTermin(
          idTerminu: idTerminu,
          upozornitMinPred: _minPred,
          idNotifikacie: idNotif,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uloženie zlyhalo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _ulozujem = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pridať termín')),
      body: _nacitavam
          ? const Center(child: CircularProgressIndicator())
          : _klienti.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Najprv potrebuješ aspoň jedného klienta.',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      const Text('Choď do obrazovky Klienti a pridaj klienta.'),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Späť'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _klucFormulara,
                    child: ListView(
                      children: [
                        DropdownButtonFormField<int>(
                          value: _idVybratehoKlienta,
                          decoration: const InputDecoration(
                            labelText: 'Klient',
                            border: OutlineInputBorder(),
                          ),
                          items: _klienti
                              .where((k) => k.id != null)
                              .map(
                                (k) => DropdownMenuItem<int>(
                                  value: k.id!,
                                  child: Text(k.meno),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _idVybratehoKlienta = v),
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _sluzbaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Služba',
                            border: OutlineInputBorder(),
                          ),
                          validator: _overPovinneText,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _vyberDatum,
                                icon: const Icon(Icons.date_range),
                                label: Text(
                                  'Dátum: ${_datum.day}.${_datum.month}.${_datum.year}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _vyberCas,
                                icon: const Icon(Icons.access_time),
                                label: Text(
                                  'Čas: ${_cas.format(context)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Upozorniť pred termínom'),
                            value: _upozornit,
                            onChanged: (v) => setState(() => _upozornit = v),
                          ),
                          if (_upozornit)
                            DropdownButtonFormField<int>(
                              value: _minPred,
                              decoration: const InputDecoration(
                                labelText: 'Koľko minút vopred',
                                border: OutlineInputBorder(),
                              ),
                              items: const [1, 5, 15, 30, 60, 120, 1440]
                                  .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(m == 1440 ? '1 deň' : '$m min'),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _minPred = v ?? 60),
                            ),
                          const SizedBox(height: 12),

                        TextFormField(
                          controller: _trvanieCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Trvanie (min)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: _overTrvanie,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _cenaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Cena (voliteľné)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: _overCenu,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _poznamkaCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Poznámka (voliteľné)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _ulozujem ? null : _uloz,
                            child: _ulozujem
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Uložiť termín'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
