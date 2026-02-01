import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../modely/klient.dart';
import '../modely/termin.dart';
import '../modely/termin_zoznam.dart';
import '../modely/termin_detail.dart';

class Databaza {
  Databaza._();
  static final Databaza instancia = Databaza._();

  static const _nazovDb = 'masersky_diar.db';
  static const _verzia = 3;

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
        await db.execute('''
          CREATE TABLE terminy (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_klienta INTEGER NOT NULL,
            zaciatok_ms INTEGER NOT NULL,
            trvanie_min INTEGER NOT NULL,
            nazov_sluzby TEXT NOT NULL,
            cena REAL,
            poznamka TEXT,
            stav TEXT NOT NULL,
            upozornit_min_pred INTEGER,
            id_notifikacie INTEGER,
            FOREIGN KEY (id_klienta) REFERENCES klienti (id)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE terminy (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_klienta INTEGER NOT NULL,
              zaciatok_ms INTEGER NOT NULL,
              trvanie_min INTEGER NOT NULL,
              nazov_sluzby TEXT NOT NULL,
              cena REAL,
              poznamka TEXT,
              stav TEXT NOT NULL,
              FOREIGN KEY (id_klienta) REFERENCES klienti (id)
            )
          ''');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE terminy ADD COLUMN upozornit_min_pred INTEGER');
          await db.execute('ALTER TABLE terminy ADD COLUMN id_notifikacie INTEGER');
        }
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

  Future<int> vlozTermin(Termin termin) async {
    final databaza = await db;
    return databaza.insert('terminy', termin.naMapu());
  }

  Future<List<Termin>> nacitajTerminyPreDen(DateTime den) async {
    final databaza = await db;

    final od = DateTime(den.year, den.month, den.day);
    final doDna = od.add(const Duration(days: 1));

    final vysledok = await databaza.query(
      'terminy',
      where: 'zaciatok_ms >= ? AND zaciatok_ms < ?',
      whereArgs: [od.millisecondsSinceEpoch, doDna.millisecondsSinceEpoch],
      orderBy: 'zaciatok_ms ASC',
    );

    return vysledok.map((m) => Termin.zMapy(m)).toList();
  }
  Future<List<TerminZoznam>> nacitajTerminyZoznamPreDen(DateTime den) async {
    final databaza = await db;

    final od = DateTime(den.year, den.month, den.day);
    final doDna = od.add(const Duration(days: 1));

    final vysledok = await databaza.rawQuery('''
      SELECT
        t.id,
        t.id_klienta,
        t.zaciatok_ms,
        t.trvanie_min,
        t.nazov_sluzby,
        t.cena,
        k.meno,
        k.telefon,
        k.email
      FROM terminy t
      JOIN klienti k ON k.id = t.id_klienta
      WHERE t.zaciatok_ms >= ? AND t.zaciatok_ms < ?
      ORDER BY t.zaciatok_ms ASC
    ''', [od.millisecondsSinceEpoch, doDna.millisecondsSinceEpoch]);

    return vysledok.map((m) => TerminZoznam.zMapy(m)).toList();
  }
  Future<TerminDetail?> nacitajTerminDetail(int idTerminu) async {
    final databaza = await db;

    final vysledok = await databaza.rawQuery('''
      SELECT
        t.id,
        t.id_klienta,
        t.zaciatok_ms,
        t.trvanie_min,
        t.nazov_sluzby,
        t.cena,
        t.poznamka,
        t.stav,
        k.meno,
        k.telefon,
        k.email
      FROM terminy t
      JOIN klienti k ON k.id = t.id_klienta
      WHERE t.id = ?
      LIMIT 1
    ''', [idTerminu]);

    if (vysledok.isEmpty) return null;
    return TerminDetail.zMapy(vysledok.first);
  }
  Future<int> nastavNotifikaciuPreTermin({
    required int idTerminu,
    int? upozornitMinPred,
    int? idNotifikacie,
  }) async {
    final databaza = await db;
    return databaza.update(
      'terminy',
      {
        'upozornit_min_pred': upozornitMinPred,
        'id_notifikacie': idNotifikacie,
      },
      where: 'id = ?',
      whereArgs: [idTerminu],
    );
  }
  Future<int?> nacitajIdNotifikaciePreTermin(int idTerminu) async {
    final databaza = await db;
    final vysledok = await databaza.query(
      'terminy',
      columns: ['id_notifikacie'],
      where: 'id = ?',
      whereArgs: [idTerminu],
      limit: 1,
    );
    if (vysledok.isEmpty) return null;

    final hodnota = vysledok.first['id_notifikacie'];
    if (hodnota == null) return null;
    return hodnota as int;
  }

  Future<int> vymazTermin(int idTerminu) async {
    final databaza = await db;
    return databaza.delete(
      'terminy',
      where: 'id = ?',
      whereArgs: [idTerminu],
    );
  }
}
