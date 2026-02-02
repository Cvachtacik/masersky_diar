class Termin {
  final int? id;
  final int idKlienta;
  final DateTime zaciatok;
  final int trvanieMin;
  final String nazovSluzby;
  final double? cena;
  final String? poznamka;
  final String stav; // planned/done/canceled
  final int? upozornitMinPred;
  final int? idNotifikacie;

  const Termin({
    this.id,
    required this.idKlienta,
    required this.zaciatok,
    required this.trvanieMin,
    required this.nazovSluzby,
    this.cena,
    this.poznamka,
    this.stav = 'planned',
    this.upozornitMinPred,
    this.idNotifikacie,
  });

  Map<String, Object?> naMapu() {
    return {
      'id': id,
      'id_klienta': idKlienta,
      'zaciatok_ms': zaciatok.millisecondsSinceEpoch,
      'trvanie_min': trvanieMin,
      'nazov_sluzby': nazovSluzby,
      'cena': cena,
      'poznamka': poznamka,
      'stav': stav,
      'upozornit_min_pred':upozornitMinPred,
      'id_notifikacie': idNotifikacie,
    };
  }

  factory Termin.zMapy(Map<String, Object?> mapa) {
    return Termin(
      id: mapa['id'] as int?,
      idKlienta: mapa['id_klienta'] as int,
      zaciatok: DateTime.fromMillisecondsSinceEpoch(mapa['zaciatok_ms'] as int),
      trvanieMin: mapa['trvanie_min'] as int,
      nazovSluzby: mapa['nazov_sluzby'] as String,
      cena: (mapa['cena'] as num?)?.toDouble(),
      poznamka: mapa['poznamka'] as String?,
      stav: (mapa['stav'] as String?) ?? 'planned',
      upozornitMinPred: (mapa['upozornit_min_pred'] as int?),
      idNotifikacie: (mapa['id_notifikacie'] as int?),
    );
  }
}
