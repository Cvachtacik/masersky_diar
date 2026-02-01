import 'package:url_launcher/url_launcher.dart';

class SpustacOdkazov {
  static Future<void> zavolat(String telefon) async {
    final uri = Uri(scheme: 'tel', path: telefon);
    await _spust(uri);
  }

  static Future<void> poslatSms(String telefon, {String? text}) async {
    final uri = Uri(
      scheme: 'sms',
      path: telefon,
      queryParameters: (text == null || text.isEmpty) ? null : {'body': text},
    );
    await _spust(uri);
  }

  static Future<void> poslatEmail(String email, {String? predmet, String? telo}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        if (predmet != null && predmet.isNotEmpty) 'subject': predmet,
        if (telo != null && telo.isNotEmpty) 'body': telo,
      },
    );
    await _spust(uri);
  }

  static Future<void> _spust(Uri uri) async {
    if (!await canLaunchUrl(uri)) {
      throw Exception('Nepodarilo sa otvoriť: $uri');
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
