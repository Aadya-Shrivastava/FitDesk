/// Safely reads a JSON value that should be an int, even when the backend
/// sends it as a numeric string (a common Laravel quirk — e.g. `"amount":
/// "500"` instead of `"amount": 500`). Assigning such a value directly to an
/// `int?` field crashes at runtime with "type 'String' is not a subtype of
/// type 'int'", so every int field parsed from the API should go through
/// this instead of a raw `json['field']` assignment.
int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  return null;
}

/// Same idea as [asInt] but for a JSON list — used for numeric arrays such
/// as the dashboard's month-by-month income/expense figures.
List<int> asIntList(dynamic value) {
  if (value is! List) return <int>[];
  return value.map((e) => asInt(e) ?? 0).toList();
}
