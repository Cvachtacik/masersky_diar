import 'package:flutter/material.dart';
import 'aplikacia.dart';
import 'sluzby/notifikacie.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifikacie.inicializuj();
  runApp(const MaserskyDiar());
}
