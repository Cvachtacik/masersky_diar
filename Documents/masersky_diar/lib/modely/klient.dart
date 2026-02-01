class Klient {
  final int? id;
  final String meno;
  final String telefon;
  final String? email;
  final String? poznamka;

  const Klient({
    this.id,
    required this.meno,
    required this.telefon,
    this.email,
    this.poznamka,
  });

  Map<String, Object?> naMapu() {
    return {
      'id': id,
      'meno': meno,
      'telefon': telefon,
      'email': email,
      'poznamka': poznamka,
    };
  }

  factory Klient.zMapy(Map<String, Object?> mapa) {
    return Klient(
      id: mapa['id'] as int?,
      meno: mapa['meno'] as String,
      telefon: mapa['telefon'] as String,
      email: mapa['email'] as String?,
      poznamka: mapa['poznamka'] as String?,
    );
  }
}
