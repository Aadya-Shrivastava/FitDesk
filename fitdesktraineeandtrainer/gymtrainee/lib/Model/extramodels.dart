import 'package:gymtrainee/Model/json_utils.dart';

// Lenient models for /trainee/fees, /trainee/notifications and /trainee/events.
// Field names follow the gym-owner APIs; alternates are read as fallbacks.

String? _first(Map<String, dynamic> j, List<String> keys) {
  for (final k in keys) {
    final v = j[k];
    if (v != null && v.toString().trim().isNotEmpty) return v.toString();
  }
  return null;
}

class FeeItem {
  final int? id;
  final String? invoiceNumber;
  final String? title; // membership / plan / class name if present
  final String? durationType;
  final int? monthNumber;
  final double amount;
  final double paidAmount;
  final double balanceAmount;
  final String? dueDate;
  final String? paidDate;
  final String? status;
  final String? paymentMethod;
  final String? notes;

  FeeItem.fromJson(Map<String, dynamic> j)
      : id = asInt(j['id']),
        invoiceNumber = _first(j, ['invoice_number', 'invoice_no']),
        title = _first(asMap(j['membership']) ?? {}, ['name', 'title']) ??
            _first(asMap(j['plan']) ?? {}, ['name', 'title']) ??
            _first(j, ['title', 'fee_type', 'description']),
        durationType = _first(j, ['duration_type']),
        monthNumber = asInt(j['month_number']),
        amount = asDouble(j['amount'] ?? j['total_amount']) ?? 0,
        paidAmount = asDouble(j['paid_amount']) ?? 0,
        balanceAmount = asDouble(j['balance_amount'] ?? j['due_amount']) ??
            ((asDouble(j['amount']) ?? 0) - (asDouble(j['paid_amount']) ?? 0)),
        dueDate = _first(j, ['due_date']),
        paidDate = _first(j, ['paid_date', 'payment_date']),
        status = _first(j, ['status', 'payment_status']),
        paymentMethod = _first(j, ['payment_method', 'payment_mode']),
        notes = _first(j, ['notes', 'remarks']);

  bool get isPaid {
    final s = (status ?? '').toLowerCase();
    if (s.contains('unpaid') || s.contains('pending') || s.contains('due')) return false;
    if (s.contains('paid')) return true;
    return balanceAmount <= 0 && amount > 0;
  }

  bool get isPartial =>
      (status ?? '').toLowerCase().contains('partial') ||
      (paidAmount > 0 && balanceAmount > 0);
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String? createdAt;
  final bool? serverRead; // null when the API doesn't tell us

  NotificationItem.fromJson(Map<String, dynamic> j)
      : id = (j['id'] ?? '${j['title']}${j['created_at']}').toString(),
        title = _first(j, ['title', 'subject', 'heading']) ??
            _first(asMap(j['data']) ?? {}, ['title']) ??
            'Notification',
        message = _first(j, ['message', 'body', 'description', 'content']) ??
            _first(asMap(j['data']) ?? {}, ['message', 'body']) ??
            '',
        createdAt = _first(j, ['created_at', 'date', 'sent_at']),
        serverRead = j.containsKey('read_at')
            ? j['read_at'] != null
            : asBool(j['is_read'] ?? j['read']);
}

class EventItem {
  final int? id;
  final String title;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? type;

  EventItem.fromJson(Map<String, dynamic> j)
      : id = asInt(j['id']),
        title = _first(j, ['title', 'name']) ?? 'Event',
        description = _first(j, ['description', 'notes']),
        startDate = _first(j, ['start_date', 'date']),
        endDate = _first(j, ['end_date']),
        status = _first(j, ['status_label', 'status']),
        type = _first(asMap(j['event_type']) ?? {}, ['name']);

  DateTime? get start => DateTime.tryParse(startDate ?? '');
  DateTime? get end => DateTime.tryParse(endDate ?? '');

  bool get isUpcomingOrOngoing {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final e = end ?? start;
    return e == null || !e.isBefore(today);
  }
}
