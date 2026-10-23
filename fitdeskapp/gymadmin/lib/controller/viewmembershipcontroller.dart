import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/Model/membershipmodel.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:http/http.dart' as http;


class ViewMembershipController extends GetxController {
  // Endpoint
  final String membershipsEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/memberships";

  // State
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final memberships = <Memberships>[].obs;

  // Pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;
var token = "".obs;
  @override
  void onInit() {
    super.onInit();
    fetchMemberships(reset: true);
  }

  /// Replace with your real token getter
  Future<String?> getToken() async {
    // TODO: implement your token read.
    token.value = await PrefManager().readValue(key: PrefConst.token) ?? "";
    return token.value;
  }

  Future<void> fetchMemberships({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      currentPage.value = 1;
      lastPage.value = 1;
      memberships.clear();
    }

    isLoading.value = true;

    try {
      final token = await getToken();

      final uri = Uri.parse(membershipsEndpoint).replace(queryParameters: {
        "page": "${currentPage.value}",
      });

      final resp = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final model = membershipmodel.fromJson(decoded);

        final list = model.data?.memberships ?? <Memberships>[];
        final pag = model.data?.pagination;

        if (reset) {
          memberships.assignAll(list);
        } else {
          memberships.addAll(list);
        }

        total.value = pag?.total ?? memberships.length;
        lastPage.value = pag?.lastPage ?? 1;
      } else {
        _showError("Failed to load memberships (${resp.statusCode}).\n${resp.body}");
      }
    } catch (e) {
      _showError("Failed to load memberships: $e");
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
      await fetchMemberships(reset: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshList() async {
    await fetchMemberships(reset: true);
  }

  void viewMembershipDetails(Memberships m) {
    final classes = (m.classes ?? [])
        .map((c) => c.title ?? "-")
        .where((t) => t.trim().isNotEmpty)
        .join(", ");

    Get.defaultDialog(
      title: m.title ?? "Membership",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Package: ${m.packageLabel ?? m.package ?? '-'}"),
          if (m.withTrainerFee != null && m.withoutTrainerFee != null) ...[
            Text("Fee (With Trainer): ₹${m.withTrainerFee}"),
            Text("Fee (Without Trainer): ₹${m.withoutTrainerFee}"),
          ] else
            Text("Amount: ₹${m.amount ?? 0}"),
          Text("Classes: ${classes.isEmpty ? '-' : classes}"),
          if ((m.notes ?? "").trim().isNotEmpty) Text("Notes: ${m.notes}"),
          if ((m.createdAt ?? "").trim().isNotEmpty) Text("Created: ${m.createdAt}"),
          Text("Total Trainees: ${m.totalTrainees ?? 0}"),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text("Close"),
      ),
    );
  }

  void _showError(String msg) {
    Get.snackbar(
      "Error",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
