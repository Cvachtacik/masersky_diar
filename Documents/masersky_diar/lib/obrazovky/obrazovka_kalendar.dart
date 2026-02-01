import 'package:flutter/material.dart';

class ObrazovkaKalendar extends StatelessWidget {
  const ObrazovkaKalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalendár')),
      body: const Center(child: Text('Tu bude kalendár a termíny podľa dňa.')),
    );
  }
}
