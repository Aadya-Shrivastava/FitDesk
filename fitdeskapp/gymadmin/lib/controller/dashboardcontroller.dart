import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:gymadmin/Model/Dashboardmodel.dart';
import 'package:gymadmin/widgets/onboarding/showcase_keys.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:http/http.dart' as http;

import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';

// ✅ import your dashboard model
// import 'package:gymadmin/models/dashboardmodel.dart';

class HomeController extends GetxController {
  // UI state
  RxBool isLoading = false.obs;
  // True once the first fetch (success or failure) has completed — lets the
  // UI tell "first load" (full-screen spinner) apart from a pull-to-refresh
  // (keep showing the old content, with the RefreshIndicator's own spinner).
  bool hasLoadedOnce = false;
var name = ''.obs;
  // Summary
  RxString totalTrainers = "0".obs;
  RxString totalTrainees = "0".obs;
  RxString todayIncome = "₹0".obs;
  RxString todayExpense = "₹0".obs;

  // Chart data
  RxList<FlSpot> incomeData = <FlSpot>[].obs;
  RxList<FlSpot> expenseData = <FlSpot>[].obs;

  // Months shown on x-axis
  final List<String> months = const [
    "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"
  ];

  // ✅ Put your real dashboard endpoint here
  // Example placeholder:
  static const String _dashboardUrl =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/dashboard-stats";

  @override
  void onInit() async{
    super.onInit();
    name.value = await PrefManager().readValue(key: PrefConst.userName) ?? '';
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    isLoading.value = true;

    try {
      final token = await PrefManager().readValue(key: PrefConst.token);

      if (token == null || token.toString().isEmpty) {
        // Token missing => force login
        Get.offAllNamed(RouteName.signin);
        return;
      }

      final res = await http.get(
        Uri.parse(_dashboardUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (res.body.isEmpty) {
        Get.snackbar("Error", "Empty response from server");
        return;
      }

      final Map<String, dynamic> decoded = jsonDecode(res.body);
      final dash = dashboardmodel.fromJson(decoded);

      if (res.statusCode == 200 && dash.success == true) {
        _applyDashboard(dash);
      } else if (res.statusCode == 401) {
        // Token invalid/expired
        await PrefManager().writeValue(key: PrefConst.login, value: false);
        await PrefManager().writeValue(key: PrefConst.token, value: "");
        Get.offAllNamed(RouteName.signin);
      } else {
        Get.snackbar("Error", dash.message ?? "Failed to load dashboard");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
      hasLoadedOnce = true;
    }
  }

  // ------------------ FIRST-TIME APP TOUR ------------------
  // Guards against the dashboard's Obx rebuilding more than once while the
  // controller is alive (isLoading only flips false->true once per visit,
  // but this keeps startFirstTimeTour safe to call from anywhere).
  bool _tourAttempted = false;

  /// Opens the drawer and walks a first-time user through its main menu
  /// items (Classes, Membership, Category, Workout Activity, Trainer,
  /// Trainee, Workouts, Fees, Attendance), in that order. Does nothing if
  /// the tour has already been completed before.
  Future<void> startFirstTimeTourIfNeeded(
    BuildContext context,
    GlobalKey<ScaffoldState> scaffoldKey,
  ) async {
    if (_tourAttempted) return;
    _tourAttempted = true;

    final seen = await PrefManager().readValue(key: PrefConst.hasSeenAppTour);
    if (seen == true) return;

    scaffoldKey.currentState?.openDrawer();

    // Give the drawer's open animation time to finish before measuring
    // and highlighting its items.
    await Future.delayed(const Duration(milliseconds: 400));
    if (!context.mounted) return;

    ShowCaseWidget.of(context).startShowCase(ShowcaseKeys.walkthroughOrder);
  }

  Future<void> markAppTourSeen() async {
    await PrefManager().writeValue(key: PrefConst.hasSeenAppTour, value: true);
  }

  void _applyDashboard(dashboardmodel dash) {
    final stats = dash.data?.stats;

    totalTrainers.value = (stats?.totalTrainers ?? 0).toString();
    totalTrainees.value = (stats?.totalTrainees ?? 0).toString();

    todayIncome.value = "₹${dash.data?.todayIncome ?? 0}";
    todayExpense.value = "₹${dash.data?.todayExpense ?? 0}";

    // Convert analysis report to FlSpot series
    final report = dash.data?.analysisReport;
    final incomes = report?.income ?? [];
    final expenses = report?.expense ?? [];

    // If API returns < 12 points, we still render whatever it gives.
    incomeData.assignAll(_toSpots(incomes));
    expenseData.assignAll(_toSpots(expenses));

    // If API gives nothing, show zeros instead of crashing
    if (incomeData.isEmpty) incomeData.assignAll(_zeroSpots());
    if (expenseData.isEmpty) expenseData.assignAll(_zeroSpots());
  }

  List<FlSpot> _toSpots(List<int> values) {
    final List<FlSpot> spots = [];
    for (int i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), (values[i]).toDouble()));
    }
    return spots;
  }

  List<FlSpot> _zeroSpots() {
    return List.generate(12, (i) => FlSpot(i.toDouble(), 0));
  }
}
