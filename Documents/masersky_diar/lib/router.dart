import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'obrazovky/obrazovka_dnes.dart';
import 'obrazovky/obrazovka_kalendar.dart';
import 'obrazovky/obrazovka_klienti.dart';
import 'obrazovky/obrazovka_nastavenia.dart';
import 'obrazovky/obrazovka_detail_klienta.dart';
import 'obrazovky/obrazovka_pridat_upravit_klienta.dart';
import 'obrazovky/obrazovka_detail_terminu.dart';
import 'obrazovky/obrazovka_pridat_upravit_termin.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HlavnaNavigacia(),
    ),
    GoRoute(
      path: '/klienti/pridat',
      builder: (context, state) => const ObrazovkaPridatAleboUpravitKlienta(),
    ),
    GoRoute(
      path: '/klienti/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ObrazovkaDetailKlienta(idKlienta: id);
      },
    ),
    GoRoute(
      path: '/terminy/pridat',
      builder: (context, state) => const ObrazovkaPridatAleboUpravitTermin(),
    ),
    GoRoute(
      path: '/terminy/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ObrazovkaDetailTerminu(idTerminu: id);
      },
    ),
  ],
);

class HlavnaNavigacia extends StatefulWidget {
  const HlavnaNavigacia({super.key});

  @override
  State<HlavnaNavigacia> createState() => _HlavnaNavigaciaState();
}

class _HlavnaNavigaciaState extends State<HlavnaNavigacia> {
  int _vybratyIndex = 0;

  final List<Widget> _obrazovky = const [
    ObrazovkaDnes(),
    ObrazovkaKalendar(),
    ObrazovkaKlienti(),
    ObrazovkaNastavenia(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _obrazovky[_vybratyIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _vybratyIndex,
        onDestinationSelected: (i) => setState(() => _vybratyIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Dnes'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Kalendár'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Klienti'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Nastavenia'),
        ],
      ),
    );
  }
}
