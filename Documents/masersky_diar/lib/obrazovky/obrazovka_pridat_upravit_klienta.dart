import 'package:flutter/material.dart';

import '../modely/klient.dart';
import '../sluzby/databaza.dart';

class ObrazovkaPridatAleboUpravitKlienta extends StatefulWidget {
  final int? idKlienta;

  const ObrazovkaPridatAleboUpravitKlienta({super.key, this.idKlienta});

  @override
  State<ObrazovkaPridatAleboUpravitKlienta> createState() =>
      _ObrazovkaPridatAleboUpravitKlientaState();
}

class _ObrazovkaPridatAleboUpravitKlientaState
    extends State<ObrazovkaPridatAleboUpravitKlienta> {
  final _klucFormulara = GlobalKey<FormState>();

  final _menoCtrl = TextEditingController();
  final _telefonCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _poznamkaCtrl = TextEditingController();

  bool _nacitavam = false;
  bool _ulozujem = false;

  @override
  void initState() {
    super.initState();
    _nacitajAkTreba();
  }

  @override
  void dispose() {
    _menoCtrl.dispose();
    _telefonCtrl.dispose();
    _emailCtrl.dispose();
    _poznamkaCtrl.dispose();
    super.dispose();
  }

  Future<void> _nacitajAkTreba() async {
    final id = widget.idKlienta;
    if (id == null) return;

    setState(() => _nacitavam = true);
    try {
      final klient = await Databaza.instancia.nacitajKlientaPodlaId(id);
      if (klient == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Klient sa nenašiel.')),
          );
          Navigator.of(context).pop();
        }
        return;
      }

      _menoCtrl.text = klient.meno;
      _telefonCtrl.text = klient.telefon;
      _emailCtrl.text = klient.email ?? '';
      _poznamkaCtrl.text = klient.poznamka ?? '';
    } finally {
      if (mounted) setState(() => _nacitavam = false);
    }
  }

  String? _overMeno(String? hodnota) {
    final v = (hodnota ?? '').trim();
    if (v.isEmpty) return 'Zadaj meno klienta.';
    if (v.length < 2) return 'Meno je príliš krátke.';
    return null;
  }

  String? _overTelefon(String? hodnota) {
    final v = (hodnota ?? '').trim();
    if (v.isEmpty) return 'Zadaj telefónne číslo.';
    if (v.length < 6) return 'Telefón vyzerá príliš krátky.';
    return null;
  }

  String? _overEmail(String? hodnota) {
    final v = (hodnota ?? '').trim();
    if (v.isEmpty) return null; // email je voliteľný
    // jednoduché overenie (na školský projekt stačí)
    final ok = v.contains('@') && v.contains('.');
    if (!ok) return 'Zadaj platný e-mail alebo nechaj prázdne.';
    return null;
  }

  Future<void> _uloz() async {
    final validne = _klucFormulara.currentState?.validate() ?? false;
    if (!validne) return;

    setState(() => _ulozujem = true);
    try {
      final klient = Klient(
        id: widget.idKlienta,
        meno: _menoCtrl.text.trim(),
        telefon: _telefonCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        poznamka:
            _poznamkaCtrl.text.trim().isEmpty ? null : _poznamkaCtrl.text.trim(),
      );

      if (widget.idKlienta == null) {
        await Databaza.instancia.vlozKlienta(klient);
      } else {
        await Databaza.instancia.upravKlienta(klient);
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
    final jeUprava = widget.idKlienta != null;

    return Scaffold(
      appBar: AppBar(title: Text(jeUprava ? 'Upraviť klienta' : 'Pridať klienta')),
      body: _nacitavam
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _klucFormulara,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _menoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Meno',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      validator: _overMeno,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _telefonCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Telefón',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: _overTelefon,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'E-mail (voliteľné)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: _overEmail,
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
                            : Text(jeUprava ? 'Uložiť zmeny' : 'Uložiť'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
