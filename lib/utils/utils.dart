import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  final formatter = DateFormat('dd-MM-yyyy'); // Specify the desired format
  return formatter.format(date); // Format the date using the formatter
}

double parseStringToDouble(String input) {
  return double.parse(input);
}

String intToString(double input) {
  final format = NumberFormat.currency(locale: "fr_FR", symbol: "XOF");
  return format.format(input); // Use the built-in 'toString' method of int
}
