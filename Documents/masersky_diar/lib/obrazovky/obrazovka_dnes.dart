import 'package:flutter/material.dart';

class ObrazovkaDnes extends StatelessWidget {
  const ObrazovkaDnes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dnešné termíny')),
      body: const Center(child: Text('Tu bude zoznam dnešných termínov.')),
    );
  }
}
