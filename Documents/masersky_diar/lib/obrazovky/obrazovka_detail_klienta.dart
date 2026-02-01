import 'package:flutter/material.dart';

class ObrazovkaDetailKlienta extends StatelessWidget {
  final int idKlienta;

  const ObrazovkaDetailKlienta({super.key, required this.idKlienta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Klient #$idKlienta')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Tu bude detail klienta + tlačidlá Zavolať/SMS/E-mail.'),
      ),
    );
  }
}
