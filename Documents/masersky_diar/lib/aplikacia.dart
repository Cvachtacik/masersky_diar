import 'package:flutter/material.dart';
import 'router.dart';

class MaserskyDiar extends StatelessWidget {
    const MaserskyDiar({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp.router(
            title: 'Masérsky diár',
            theme: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.green,
            ),
            routerConfig: router,
        );
    }
}