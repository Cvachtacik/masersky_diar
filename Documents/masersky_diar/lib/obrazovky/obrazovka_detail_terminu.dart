import 'package:flutter/material.dart';

class ObrazovkaDetailTerminu extends StatelessWidget {
  final int idTerminu;

  const ObrazovkaDetailTerminu({super.key, required this.idTerminu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Termín #$idTerminu')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Detail termínu doplniť'),
      ),
    );
  }
}
