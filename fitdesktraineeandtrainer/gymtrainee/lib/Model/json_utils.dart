// Lenient JSON readers. The API sometimes sends numbers as strings ("1500.00")
// or strings as numbers (sets: 3), and a strict `x = json['k']` assignment then
// throws a TypeError, which made screens fall into their error/retry state.

int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  if (v is bool) return v ? 1 : 0;
  final s = v.toString().trim();
  return int.tryParse(s) ?? double.tryParse(s)?.round();
}

double? asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().trim());
}

String? asStr(dynamic v) {
  if (v == null) return null;
  return v.toString();
}

bool? asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  if (s == 'true' || s == '1' || s == 'yes') return true;
  if (s == 'false' || s == '0' || s == 'no') return false;
  return null;
}

Map<String, dynamic>? asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

List<dynamic> asList(dynamic v) => v is List ? v : const [];
