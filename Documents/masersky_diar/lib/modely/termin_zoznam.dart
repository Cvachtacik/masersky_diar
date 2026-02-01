class TerminZoznam {
  final int idTerminu;
  final DateTime zaciatok;
  final int trvanieMin;
  final String nazovSluzby;

  final int idKlienta;
  final String menoKlienta;
  final String telefonKlienta;
  final String? emailKlienta;

  final double? cena;

  const TerminZoznam({
    required this.idTerminu,
    required this.zaciatok,
    required this.trvanieMin,
    required this.nazovSluzby,
    required this.idKlienta,
    required this.menoKlienta,
    required this.telefonKlienta,
    required this.emailKlienta,
    required this.cena,
  });

  factory TerminZoznam.zMapy(Map<String, Object?> m) {
    return TerminZoznam(
      idTerminu: m['id'] as int,
      zaciatok: DateTime.fromMillisecondsSinceEpoch(m['zaciatok_ms'] as int),
      trvanieMin: m['trvanie_min'] as int,
      nazovSluzby: m['nazov_sluzby'] as String,
      idKlienta: m['id_klienta'] as int,
      menoKlienta: m['meno'] as String,
      telefonKlienta: m['telefon'] as String,
      emailKlienta: m['email'] as String?,
      cena: (m['cena'] as num?)?.toDouble(),
    );
  }
}
