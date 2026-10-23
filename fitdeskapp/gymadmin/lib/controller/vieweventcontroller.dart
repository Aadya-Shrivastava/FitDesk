import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// local storage
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';

// your model
import 'package:gymadmin/Model/eventmodel.dart';

class Vieweventcontroller extends GetxController {
  final String endpoint = "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/events";

  // calendar state
  final focusedDay = DateTime.now().obs;
  final selectedDay = DateTime.now().obs;

  // API state
  final isLoading = false.obs;
  final error = ''.obs;

  final currentPage = 1.obs;
  final lastPage = 1.obs;

  // flat list (optional, useful for debugging)
  final allEvents = <Events>[].obs;

  // calendar map (THIS is what TableCalendar uses)
  final eventsByDay = <DateTime, List<Events>>{}.obs;

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();
    fetchEvents(reset: true);
  }

  Future<void> fetchEvents({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      currentPage.value = 1;
      lastPage.value = 1;
      allEvents.clear();
      eventsByDay.clear();
      error.value = '';
    }

    isLoading.value = true;

    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        error.value = "Token missing. Please login again.";
        return;
      }

      // ---- Fetch page 1 and keep going (capped to avoid infinite heavy load) ----
      int page = currentPage.value;
      int safetyCap = 10; // don’t load endless pages blindly

      while (page <= lastPage.value && safetyCap > 0) {
        final url = Uri.parse("$endpoint?page=$page");

        final resp = await http.get(
          url,
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer ${token.trim()}",
          },
        );

        debugPrint("GET $url");
        debugPrint("STATUS: ${resp.statusCode}");
        // debugPrint("BODY: ${resp.body}");

        if (resp.statusCode < 200 || resp.statusCode >= 300) {
          error.value = _prettyApiError(resp.body, resp.statusCode);
          return;
        }

        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final model = eventmodel.fromJson(decoded);

        final list = model.data?.events ?? <Events>[];
        final pg = model.data?.pagination;

        if (pg != null) {
          currentPage.value = pg.currentPage ?? page;
          lastPage.value = pg.lastPage ?? lastPage.value;
        }

        // append
        allEvents.addAll(list);

        // next
        page++;
        safetyCap--;
      }

      _rebuildCalendarMap();
      error.value = '';
    } catch (e) {
      error.value = "Failed to load events: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void _rebuildCalendarMap() {
    final map = <DateTime, List<Events>>{};

    for (final e in allEvents) {
      final start = _safeParseDate(e.startDate);
      final end = _safeParseDate(e.endDate);

      if (start == null) continue;

      // If event spans multiple days, add it to each day
      final startDay = DateTime.utc(start.year, start.month, start.day);
      final endDay = end == null
          ? startDay
          : DateTime.utc(end.year, end.month, end.day);

      DateTime d = startDay;
      while (!d.isAfter(endDay)) {
        map.putIfAbsent(d, () => <Events>[]).add(e);
        d = d.add(const Duration(days: 1));
      }
    }

    eventsByDay.assignAll(map);
    eventsByDay.refresh();
  }

  List<Events> getEventsForDay(DateTime day) {
    final key = DateTime.utc(day.year, day.month, day.day);
    return eventsByDay[key] ?? <Events>[];
  }

  // ---------- helpers ----------
  DateTime? _safeParseDate(String? s) {
    if (s == null) return null;
    final v = s.trim();
    if (v.isEmpty) return null;
    return DateTime.tryParse(v); // expects yyyy-MM-dd (your API has this)
  }

  String _prettyApiError(String body, int status) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final msg = decoded["message"]?.toString();
        final errors = decoded["errors"];
        if (errors is Map) {
          final b = StringBuffer();
          b.writeln(msg ?? "Request failed ($status)");
          errors.forEach((k, v) => b.writeln("$k: $v"));
          return b.toString();
        }
        return msg ?? decoded.toString();
      }
      return body;
    } catch (_) {
      return body.isNotEmpty ? body : "Request failed ($status)";
    }
  }
}
