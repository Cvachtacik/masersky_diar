import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../modely/klient.dart';

class Databaza {
  Databaza._();
  static final Databaza instancia = Databaza._();

  static const _nazovDb = 'masersky_diar.db';
  static const _verzia = 1;

  Database? _db;

  Future<Database> get db async {
    final existuje = _db;
    if (existuje != null) return existuje;

    _db = await _otvorDb();
    return _db!;
  }

  Future<Database> _otvorDb() async {
    final cesta = await getDatabasesPath();
    final plnaCesta = p.join(cesta, _nazovDb);

    return openDatabase(
      plnaCesta,
      version: _verzia,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE klienti (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            meno TEXT NOT NULL,
            telefon TEXT NOT NULL,
            email TEXT,
            poznamka TEXT
          )
        ''');
      },
    );
  }

  // CRUD: Klienti
  Future<int> vlozKlienta(Klient klient) async {
    final databaza = await db;
    return databaza.insert('klienti', klient.naMapu());
  }

  Future<List<Klient>> nacitajKlientov() async {
    final databaza = await db;
    final vysledok = await databaza.query(
      'klienti',
      orderBy: 'meno COLLATE NOCASE ASC',
    );
    return vysledok.map((m) => Klient.zMapy(m)).toList();
  }

  Future<Klient?> nacitajKlientaPodlaId(int id) async {
    final databaza = await db;
    final vysledok = await databaza.query(
      'klienti',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (vysledok.isEmpty) return null;
    return Klient.zMapy(vysledok.first);
  }

  Future<int> upravKlienta(Klient klient) async {
    if (klient.id == null) {
      throw ArgumentError('Klient musí mať id pri úprave.');
    }
    final databaza = await db;
    return databaza.update(
      'klienti',
      klient.naMapu(),
      where: 'id = ?',
      whereArgs: [klient.id],
    );
  }

  Future<int> vymazKlienta(int id) async {
    final databaza = await db;
    return databaza.delete('klienti', where: 'id = ?', whereArgs: [id]);
  }
}
