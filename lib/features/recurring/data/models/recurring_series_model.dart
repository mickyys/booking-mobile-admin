import 'package:intl/intl.dart';
import '../../domain/entities/recurring_series.dart';

String formatPrice(double price) {
  final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  return formatter.format(price);
}

double parsePrice(dynamic price) {
  if (price == null) return 0.0;
  if (price is double) return price;
  if (price is int) return price.toDouble();
  return double.tryParse(price.toString()) ?? 0.0;
}

String formatDayOfWeek(dynamic day) {
  if (day == null) return '';
  const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  int dayNum = 0;
  if (day is int) {
    dayNum = day - 1; // DateTime.weekday es 1-7
  } else {
    dayNum = (int.tryParse(day.toString()) ?? 1) - 1;
  }
  return days[dayNum.clamp(0, 6)];
}

String formatHour(dynamic hour) {
  if (hour == null) return '';
  final hourNum = hour is int ? hour : int.tryParse(hour.toString()) ?? 0;
  return '${hourNum.toString().padLeft(2, '0')}:00';
}

int getDayFromDate(String dateStr) {
  try {
    if (dateStr.isEmpty) return 0;
    
    // Limpiar string: quitar T y Z si hay formato ISO
    final cleanStr = dateStr.replaceAll('T', ' ').replaceAll('Z', '').split('.').first;
    
    // Intentar formato ISO: 2024-03-15 o 2024-03-15 22:48:10
    if (cleanStr.contains('-') && cleanStr.length >= 10) {
      final parts = cleanStr.split('-');
      int year = 0, month = 1, day = 1;
      
      // Formato YYYY-MM-DD
      if (parts[0].length == 4) {
        year = int.tryParse(parts[0]) ?? 0;
        month = int.tryParse(parts[1]) ?? 1;
        // Obtener solo el día (antes de cualquier espacio)
        final dayPart = parts[2].split(' ').first;
        day = int.tryParse(dayPart) ?? 1;
      } 
      // Formato DD-MM-YYYY
      else if (parts[2].length == 4) {
        day = int.tryParse(parts[0]) ?? 1;
        month = int.tryParse(parts[1]) ?? 1;
        year = int.tryParse(parts[2]) ?? 0;
      }
      
      if (year > 0 && month > 0 && day > 0) {
        final date = DateTime(year, month, day);
        return date.weekday;
      }
    }
    return 0;
  } catch (e) {
    return 0;
  }
}

class RecurringSeriesModel extends RecurringSeries {
  const RecurringSeriesModel({
    required super.id,
    required super.customerName,
    required super.customerPhone,
    required super.courtName,
    required super.dayOfWeek,
    required super.time,
    required super.totalBookings,
    required super.confirmedBookings,
    required super.status,
    required super.type,
    required super.price,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
  });

  factory RecurringSeriesModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString() ?? '';
    final isWeekly = typeStr == 'weekly';
    
    dynamic dayOfWeek = json['day_of_week'] ?? json['day'];
    dynamic hour = json['hour'] ?? json['start_time'] ?? json['time'];
    final totalBookings = json['total_bookings'] ?? json['total'] ?? 0;
    final confirmedBookings = json['confirmed_bookings'] ?? 0;
    double price = 0;
    if (json['price'] != null) {
      price = parsePrice(json['price']);
    } else if (json['amount'] != null) {
      price = parsePrice(json['amount']);
    }
    final courtName = json['court_name'] ?? json['court'] ?? '';
    final customerName = json['customer_name'] ?? json['name'] ?? json['client_name'] ?? '';
    final customerPhone = json['customer_phone'] ?? json['phone'] ?? json['client_phone'] ?? '';
    final status = json['status'] ?? 'active';
    final startDate = json['start_date'] ?? json['startDate'] ?? '';
    final endDate = json['end_date'] ?? json['endDate'] ?? '';
    
    // Para series, si no hay dayOfWeek, intentar obtenerlo de start_date o created_at
    if (!isWeekly && (dayOfWeek == null || dayOfWeek == '')) {
      if (startDate.isNotEmpty) {
        dayOfWeek = getDayFromDate(startDate);
      } else if (json['created_at'] != null && json['created_at'].toString().isNotEmpty) {
        dayOfWeek = getDayFromDate(json['created_at']);
      } else if (json['createdAt'] != null && json['createdAt'].toString().isNotEmpty) {
        dayOfWeek = getDayFromDate(json['createdAt']);
      }
      // Si aún no hay día, intentar de otros campos
      if (dayOfWeek == null || dayOfWeek == '') {
        dayOfWeek = json['date'] ?? json['booking_date'] ?? '';
      }
    }
    
    final type = isWeekly ? RecurringType.weekly : RecurringType.series;
    
    return RecurringSeriesModel(
      id: (json['id'] ?? '').toString(),
      customerName: customerName,
      customerPhone: customerPhone,
      courtName: courtName,
      dayOfWeek: formatDayOfWeek(dayOfWeek),
      time: formatHour(hour),
      totalBookings: totalBookings,
      confirmedBookings: confirmedBookings,
      status: status,
      type: type,
      price: price,
      startDate: startDate,
      endDate: endDate,
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
    );
  }
}