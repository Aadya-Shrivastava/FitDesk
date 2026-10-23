import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:gymtrainee/widgets/localStorage/PrefConst.dart';
import 'package:gymtrainee/widgets/localStorage/localstorage.dart';
import 'package:gymtrainee/widgets/routes/page_constants.dart';

/// Error with a message that is safe to show to the user.
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Single place for every trainee API call: base URL, auth header, timeouts,
/// and turning HTTP / network / parsing failures into readable messages.
class Api {
  Api._();

  static const String host = 'https://fitdesk.theapexinnovation.com';
  static const String base = '$host/api/v1';
  static const Duration _timeout = Duration(seconds: 20);

  /// Shows the raw error in a snackbar while testing. Set to false to remove.
  static bool debugErrors = true; // DEBUG-LOG

  static Future<Map<String, String>> _headers() async {
    final token = await PrefManager().readValue(key: PrefConst.token) ?? '';
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token.toString().isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path) async {
    final uri = Uri.parse('$base$path');
    return _send(path, () async => http.get(uri, headers: await _headers()));
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$base$path');
    return _send(
      path,
      () async => http.post(uri, headers: await _headers(), body: json.encode(body)),
    );
  }

  static Future<dynamic> _send(
      String path, Future<http.Response> Function() call) async {
    final http.Response res;
    try {
      res = await call().timeout(_timeout);
    } on SocketException {
      throw ApiException('No internet connection. Check your network and try again.');
    } on TimeoutException {
      throw ApiException('The server is taking too long to respond. Please try again.');
    } on http.ClientException {
      throw ApiException('Could not reach the server. Please try again.');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.trim().isEmpty) return <String, dynamic>{};
      try {
        return json.decode(res.body);
      } on FormatException {
        _debug(path, 'Invalid JSON (HTTP ${res.statusCode}): ${res.body}');
        throw ApiException('Unexpected response from the server.',
            statusCode: res.statusCode);
      }
    }

    _debug(path, 'HTTP ${res.statusCode}: ${res.body}');
    final serverMsg = _serverMessage(res.body);

    switch (res.statusCode) {
      case 401:
        _sessionExpired();
        throw ApiException('Your session has expired. Please log in again.',
            statusCode: 401);
      case 403:
        throw ApiException(
            serverMsg ??
                'This account does not have access. Please log in with a trainee account.',
            statusCode: 403);
      case 404:
        throw ApiException(serverMsg ?? 'Nothing found.', statusCode: 404);
      case 422:
        throw ApiException(serverMsg ?? 'Some details are invalid.',
            statusCode: 422);
      default:
        if (res.statusCode >= 500) {
          throw ApiException('Server error. Please try again in a moment.',
              statusCode: res.statusCode);
        }
        throw ApiException(serverMsg ?? 'Request failed (${res.statusCode}).',
            statusCode: res.statusCode);
    }
  }

  static String? _serverMessage(String body) {
    try {
      final m = json.decode(body);
      if (m is Map) {
        final errors = m['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          return first.toString();
        }
        if (m['message'] != null && m['message'].toString().isNotEmpty) {
          return m['message'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  static bool _redirecting = false;
  static Future<void> _sessionExpired() async {
    if (_redirecting || Get.currentRoute == RouteName.signin) return;
    _redirecting = true;
    await PrefManager().writeValue(key: PrefConst.login, value: false);
    await PrefManager().writeValue(key: PrefConst.token, value: '');
    Get.offAllNamed(RouteName.signin);
    _redirecting = false;
  }

  /// Message to show on screen for any caught error.
  static String message(Object e) {
    if (e is ApiException) return e.message;
    return 'Something went wrong while loading. Please try again.';
  }

  /// Logs an unexpected error (e.g. a parsing bug) while testing.
  static void report(String where, Object e) {
    if (e is ApiException) return; // already shown by _debug
    _debug(where, e.toString());
  }

  static void _debug(String where, String text) {
    if (!debugErrors) return; // DEBUG-LOG
    Get.snackbar(where, text,
        duration: const Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM); // DEBUG-LOG
  }

  /// Turns a relative storage path from the API into a full URL.
  static String fileUrl(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '';
    if (v.startsWith('http')) return v;
    return v.startsWith('/') ? '$host$v' : '$host/$v';
  }

  /// Finds the list in responses shaped like {data: {key: [...]}},
  /// {data: [...]}, {data: {data: [...]}} (paginated) or a bare list.
  static List<Map<String, dynamic>> findList(dynamic body, List<String> keys) {
    List<dynamic>? pick(dynamic node) {
      if (node is List) return node;
      if (node is Map) {
        for (final k in keys) {
          final v = node[k];
          if (v is List) return v;
          if (v is Map && v['data'] is List) return v['data'];
        }
        if (node['data'] is List) return node['data'];
      }
      return null;
    }

    final data = body is Map ? body['data'] : null;
    final list = pick(data) ?? pick(data is Map ? data['data'] : null) ?? pick(body) ?? const [];
    return list
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}
