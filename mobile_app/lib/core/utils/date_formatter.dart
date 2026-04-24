import 'package:intl/intl.dart';

class DateFormatter {
  static String shortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
