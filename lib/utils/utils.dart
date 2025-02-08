import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final formatter = DateFormat('dd-MM-yyyy'); // Format avec date et heure
  return formatter.format(date);
}

double parseStringToDouble(String input) {
  return double.parse(input);
}

String intToString(double input) {
  final format = NumberFormat.currency(locale: "fr_FR", symbol: "XOF");
  return format.format(input); // Use the built-in 'toString' method of int
}

DateTime convertStringToDate(String dateString) {
  try {
    final DateFormat format = DateFormat('dd-MM-yyyy');
    return format.parse(dateString); // Retourne la date en format DateTime
  } catch (e) {
    throw Exception("Format de date invalide : $dateString");
  }
}
