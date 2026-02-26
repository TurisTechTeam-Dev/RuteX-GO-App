import 'package:intl/intl.dart';

class FormateadorFechas {
  static String fechaCorta(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }
}
