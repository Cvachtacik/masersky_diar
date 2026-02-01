class TerminDetail {
  final int idTerminu;
  final DateTime zaciatok;
  final int trvanieMin;
  final String nazovSluzby;
  final double? cena;
  final String? poznamka;
  final String stav;

  final int idKlienta;
  final String menoKlienta;
  final String telefonKlienta;
  final String? emailKlienta;

  const TerminDetail({
    required this.idTerminu,
    required this.zaciatok,
    required this.trvanieMin,
    required this.nazovSluzby,
    required this.cena,
    required this.poznamka,
    required this.stav,
    required this.idKlienta,
    required this.menoKlienta,
    required this.telefonKlienta,
    required this.emailKlienta,
  });

  factory TerminDetail.zMapy(Map<String, Object?> m) {
    return TerminDetail(
      idTerminu: m['id'] as int,
      idKlienta: m['id_klienta'] as int,
      zaciatok: DateTime.fromMillisecondsSinceEpoch(m['zaciatok_ms'] as int),
      trvanieMin: m['trvanie_min'] as int,
      nazovSluzby: m['nazov_sluzby'] as String,
      cena: (m['cena'] as num?)?.toDouble(),
      poznamka: m['poznamka'] as String?,
      stav: (m['stav'] as String?) ?? 'planned',
      menoKlienta: m['meno'] as String,
      telefonKlienta: m['telefon'] as String,
      emailKlienta: m['email'] as String?,
    );
  }
}
