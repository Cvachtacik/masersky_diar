import 'package:flutter/material.dart';

class ObrazovkaPridatAleboUpravitKlienta extends StatelessWidget {
  const ObrazovkaPridatAleboUpravitKlienta({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pridať klienta')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Tu bude formulár: meno, telefón, e-mail, poznámka.'),
      ),
    );
  }
}
