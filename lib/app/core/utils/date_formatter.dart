// date_formatter.dart
import 'package:intl/intl.dart';

class DateFormatter {
  // Formatear fecha como DD/MM/YYYY
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formatear fecha como DD/MM/YYYY HH:mm
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Formatear fecha como "Hace X días/horas/minutos"
  static String timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return "${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? "año" : "años"} atrás";
    } else if (difference.inDays > 30) {
      return "${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? "mes" : "meses"} atrás";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} ${difference.inDays == 1 ? "día" : "días"} atrás";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} ${difference.inHours == 1 ? "hora" : "horas"} atrás";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? "minuto" : "minutos"} atrás";
    } else {
      return "Ahora";
    }
  }

  // Obtener formato relativo de una fecha (Hoy, Ayer, Mañana)
  static String getRelativeDateFormat(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (dateOnly == today) {
      return "Hoy";
    } else if (dateOnly == yesterday) {
      return "Ayer";
    } else if (dateOnly == tomorrow) {
      return "Mañana";
    } else {
      return formatDate(date);
    }
  }

  // Obtener nombre del mes
  static String getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Enero';
      case 2:
        return 'Febrero';
      case 3:
        return 'Marzo';
      case 4:
        return 'Abril';
      case 5:
        return 'Mayo';
      case 6:
        return 'Junio';
      case 7:
        return 'Julio';
      case 8:
        return 'Agosto';
      case 9:
        return 'Septiembre';
      case 10:
        return 'Octubre';
      case 11:
        return 'Noviembre';
      case 12:
        return 'Diciembre';
      default:
        return '';
    }
  }
}
