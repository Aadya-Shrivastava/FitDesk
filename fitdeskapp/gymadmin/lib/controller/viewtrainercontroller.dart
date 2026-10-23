import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:gymadmin/Model/viewtrainermodel.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

 // <-- put your model here

class ViewTrainerController extends GetxController {
  final String endpoint =
      'https://fitdesk.theapexinnovation.com/api/v1/gym-owner/trainers';

  // state
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
var token = "".obs;
  // data
  final RxList<Trainers> trainers = <Trainers>[].obs;

  // pagination (optional use)
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt total = 0.obs;

  // TODO: implement token retrieval
  Future<String?> getToken() async {
    // return GetStorage().read('token');
    token.value = await PrefManager().readValue(key: PrefConst.token);
    return token.value;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTrainers(page: 1);
  }

  Future<void> fetchTrainers({int page = 1}) async {
    isLoading.value = true;
    error.value = '';

    try {
      final token = await getToken();
      final uri = Uri.parse(endpoint).replace(queryParameters: {
        "page": page.toString(),
      });

      final resp = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final model = viewtrainer.fromJson(decoded);

        final list = model.data?.trainers ?? <Trainers>[];
        trainers.assignAll(list);

        // pagination
        currentPage.value = model.data?.pagination?.currentPage ?? page;
        lastPage.value = model.data?.pagination?.lastPage ?? 1;
        total.value = model.data?.pagination?.total ?? list.length;
      } else {
        error.value = _extractError(resp);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String _extractError(http.Response resp) {
    try {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map) {
        if (decoded["message"] != null) return decoded["message"].toString();
        if (decoded["error"] != null) return decoded["error"].toString();
        if (decoded["errors"] != null) return decoded["errors"].toString();
      }
      return "Failed (${resp.statusCode}): ${resp.body}";
    } catch (_) {
      return "Failed (${resp.statusCode}): ${resp.body}";
    }
  }

  // -------- Helpers for URLs --------
  // Backend might return relative paths; we normalize to absolute.
  String toAbsoluteUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final u = url.trim();
    if (u.startsWith('http://') || u.startsWith('https://')) return u;

    // adjust base if your backend uses different host/path
    return "https://fitdesk.theapexinnovation.com/$u";
  }

  // -------- Document download / open / share --------
  Future<void> downloadAndOpenDocument(Trainers t) async {
    final docUrl = toAbsoluteUrl(t.document);
    if (docUrl.isEmpty) {
      Get.snackbar("No Document", "This trainer has no document uploaded.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      // No runtime storage permission needed for app-specific directories.

      final token = await getToken();

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

      // Professional filename
      final ext = _guessExtension(t.document);
      final safeName = (t.name ?? "trainer")
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
          .trim()
          .replaceAll(' ', '_');

      final fileName = "TrainerDoc_${safeName}_${t.id ?? ""}.$ext";

      final dir = await _getDownloadDir();
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(bytes, flush: true);

      // Open it
      final result = await OpenFilex.open(file.path);

      if (result.type != ResultType.done) {
        Get.snackbar("Downloaded", "Saved to: ${file.path}",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> downloadAndShareDocument(Trainers t) async {
    final docUrl = toAbsoluteUrl(t.document);
    if (docUrl.isEmpty) {
      Get.snackbar("No Document", "This trainer has no document uploaded.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      final token = await getToken();
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

      final ext = _guessExtension(t.document);
      final safeName = (t.name ?? "trainer")
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\- ]'), '')
          .trim()
          .replaceAll(' ', '_');

      final fileName = "TrainerDoc_${safeName}_${t.id ?? ""}.$ext";

      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/$fileName");
      await file.writeAsBytes(resp.bodyBytes, flush: true);

      await Share.shareXFiles([XFile(file.path)],
          text: "Trainer document: ${t.name ?? ""}");
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _guessExtension(String? url) {
    if (url == null) return "dat";
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
      // app-specific external directory (safe, no messy OS downloads folder issues)
      final dir = await getExternalStorageDirectory();
      if (dir != null) return dir;
    }
    return getApplicationDocumentsDirectory();
  }
}
