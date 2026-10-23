import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// your local storage
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';

// import your model file path (update import as per your project)
import 'package:gymadmin/Model/traineemodel.dart';

class TraineeListController extends GetxController {
  final String endpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/trainees";

  final trainees = <Trainees>[].obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = "".obs;

  final currentPage = 1.obs;
  final lastPage = 1.obs;

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();
    fetchTrainees(reset: true);
  }

  Future<void> fetchTrainees({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      currentPage.value = 1;
      lastPage.value = 1;
      trainees.clear();
      errorMessage.value = "";
    }

    isLoading.value = true;

    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        errorMessage.value = "Token missing. Please login again.";
        return;
      }

      final url = Uri.parse("$endpoint?page=${currentPage.value}");
      final resp = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      );

      debugPrint("GET $url");
      debugPrint("STATUS: ${resp.statusCode}");
      debugPrint("BODY: ${resp.body}");

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        errorMessage.value = _prettyApiError(resp.body, resp.statusCode);
        return;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final model = traineemodel.fromJson(decoded);

      final newList = model.data?.trainees ?? <Trainees>[];
      final pagination = model.data?.pagination;

      if (pagination != null) {
        currentPage.value = pagination.currentPage ?? currentPage.value;
        lastPage.value = pagination.lastPage ?? lastPage.value;
      }

      trainees.addAll(newList);
      errorMessage.value = "";
    } catch (e) {
      errorMessage.value = "Failed to load trainees: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (currentPage.value >= lastPage.value) return;

    isLoadingMore.value = true;
    try {
      currentPage.value = currentPage.value + 1;
      await fetchTrainees(reset: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshList() async {
    await fetchTrainees(reset: true);
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

  // -------- Helpers for URLs --------
  String toAbsoluteUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final u = url.trim();
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return "https://fitdesk.theapexinnovation.com/$u";
  }

  // -------- Document download / open / share --------
  Future<void> downloadAndOpenDocument(Trainees t) async {
    final docUrl = toAbsoluteUrl(t.document?.toString());
    if (docUrl.isEmpty) {
      Get.snackbar("No Document", "This trainee has no document uploaded.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final token = await _getToken();

      final resp = await http.get(
        Uri.parse(docUrl),
        headers: {
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        Get.snackbar("Download Failed", "HTTP ${resp.statusCode}",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final bytes = resp.bodyBytes;
      final ext = _guessExtension(docUrl);
      final safeName = (t.name ?? "trainee")
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
          .trim()
          .replaceAll(' ', '_');

      final fileName = "TraineeDoc_${safeName}_${t.id ?? ""}.$ext";
      final dir = await _getDownloadDir();
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path);
      if (result.type != ResultType.done) {
        Get.snackbar("Downloaded", "Saved to: ${file.path}",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> downloadAndShareDocument(Trainees t) async {
    final docUrl = toAbsoluteUrl(t.document?.toString());
    if (docUrl.isEmpty) {
      Get.snackbar("No Document", "This trainee has no document uploaded.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final token = await _getToken();
      final resp = await http.get(
        Uri.parse(docUrl),
        headers: {
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        Get.snackbar("Download Failed", "HTTP ${resp.statusCode}",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      final ext = _guessExtension(docUrl);
      final safeName = (t.name ?? "trainee")
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
          .trim()
          .replaceAll(' ', '_');

      final fileName = "TraineeDoc_${safeName}_${t.id ?? ""}.$ext";
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(resp.bodyBytes, flush: true);

      await Share.shareXFiles([XFile(file.path)],
          text: "Trainee document: ${t.name ?? ""}");
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _guessExtension(String url) {
    final u = url.toLowerCase();
    if (u.contains('.pdf')) return 'pdf';
    if (u.contains('.docx')) return 'docx';
    if (u.contains('.doc')) return 'doc';
    if (u.contains('.png')) return 'png';
    if (u.contains('.jpg') || u.contains('.jpeg')) return 'jpg';
    return "dat";
  }

  Future<Directory> _getDownloadDir() async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir != null) return dir;
    }
    return getApplicationDocumentsDirectory();
  }
}
