// lib/controller/takefeescontroller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/Model/feesmodel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';

// ✅ your trainees model (already in project)
import 'package:gymadmin/Model/traineemodel.dart';

// ✅ fees model from above

class Takefeescontroller extends GetxController {
  // ------------------- API -------------------
  final String _base = "https://fitdesk.theapexinnovation.com/";
  final String feesEndpoint = "api/v1/gym-owner/trainee-fees";
  final String traineesEndpoint = "api/v1/gym-owner/trainees";

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  // ------------------- Filters -------------------
  final selectedMember = "All Members".obs;
  final selectedStatus = "All Status".obs;
  final selectedDuration = "All Durations".obs;
  final selectedMonth = "All Months".obs;

  DateTime? fromDate;
  DateTime? toDate;
  final searchCtrl = TextEditingController();

  // member name -> trainee id (needed for API)
  final Map<String, int> _memberIdByName = {};

  // ------------------- Options -------------------
  final memberOptions = <String>["All Members"].obs;

  final statusOptions = <String>[
    "All Status",
    "Paid",
    "Pending",
    "Overdue", // optional, depends on your backend; if backend doesn't support, remove.
  ];

  final durationOptions = <String>[
    "All Durations",
    "Monthly",
    "Quarterly",
    "Yearly",
  ];

  final monthOptions = <String>[
    "All Months",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];
void resetFilters() {
  selectedMember.value = "All Members";
  selectedStatus.value = "All Status";
  selectedDuration.value = "All Durations";
  selectedMonth.value = "All Months";
  fromDate = null;
  toDate = null;
  searchCtrl.clear();
  applyFilters();
}

  // ------------------- Data -------------------
  final invoices = <InvoiceVM>[].obs;
  final filteredInvoices = <InvoiceVM>[].obs; // we keep this for UI, but it's now API result
  final isLoading = false.obs;
  final errorMessage = "".obs;

  final currentPage = 1.obs;
  final lastPage = 1.obs;

  // formatting
  final _fmt = NumberFormat.currency(locale: "en_IN", symbol: "₹", decimalDigits: 2);
  final _dateFmt = DateFormat("MMM dd, yyyy");
  final _monthFmt = DateFormat("MMM");

  @override
  void onInit() {
    super.onInit();
    initLoad();
  }

  Future<void> initLoad() async {
    await fetchMembers();     // ✅ dropdown options from trainees
    await fetchFees(reset: true); // ✅ fees list
  }

  // ------------------- UI helpers -------------------
  String get fromDateText => fromDate == null ? "" : DateFormat("dd-MM-yyyy").format(fromDate!);
  String get toDateText => toDate == null ? "" : DateFormat("dd-MM-yyyy").format(toDate!);

  // ------------------- Stats -------------------
  String get totalFeesText => _fmt.format(_sumAll());
  String get paidText => _fmt.format(_sumByStatus("Paid"));
  String get pendingText => _fmt.format(_sumByStatus("Pending"));
  String get overdueText => _fmt.format(_sumOverdue());

  double _sumAll() {
    double sum = 0;
    for (final i in invoices) sum += i.amount;
    return sum;
  }

  double _sumByStatus(String status) {
    double sum = 0;
    for (final i in invoices) {
      if (i.status.toLowerCase() == status.toLowerCase()) sum += i.amount;
    }
    return sum;
  }

  double _sumOverdue() {
    final now = DateTime.now();
    double sum = 0;
    for (final i in invoices) {
      final overdue = i.status.toLowerCase() != "paid" && i.dueDate.isBefore(now);
      if (overdue) sum += i.amount;
    }
    return sum;
  }

  // ------------------- Date pickers -------------------
  Future<void> pickFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: fromDate ?? DateTime.now(),
    );
    if (picked != null) {
      fromDate = picked;
      await fetchFees(reset: true);
    }
  }

  Future<void> pickToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: toDate ?? DateTime.now(),
    );
    if (picked != null) {
      toDate = picked;
      await fetchFees(reset: true);
    }
  }

  // ------------------- Member list from Trainees API -------------------
  Future<void> fetchMembers() async {
    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        errorMessage.value = "Token missing. Please login again.";
        return;
      }

      // NOTE: if you have pagination and many trainees, you may need looping.
      // For now: fetch first page and populate dropdown.
      final url = Uri.parse("$_base$traineesEndpoint?page=1");

      final resp = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return; // don't block fees page if member list fails
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final model = traineemodel.fromJson(decoded);

      final list = model.data?.trainees ?? <Trainees>[];

      _memberIdByName.clear();
      final names = <String>["All Members"];

      for (final t in list) {
        final name = (t.name ?? "").trim();
        final id = t.id;
        if (name.isNotEmpty && id != null) {
          _memberIdByName[name] = id;
          names.add(name);
        }
      }

      // set options
      memberOptions.assignAll(names);

      // keep selected value valid
      if (!memberOptions.contains(selectedMember.value)) {
        selectedMember.value = "All Members";
      }
    } catch (_) {
      // ignore silently; not worth crashing UI
    }
  }

  // ------------------- Fees API -------------------
  Future<void> fetchFees({required bool reset}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        errorMessage.value = "Token missing. Please login again.";
        return;
      }

      if (reset) {
        currentPage.value = 1;
        lastPage.value = 1;
        invoices.clear();
        filteredInvoices.clear();
      }

      final uri = _buildFeesUri(page: currentPage.value);

      final resp = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      );

      debugPrint("GET $uri");
      debugPrint("STATUS ${resp.statusCode}");
      debugPrint("BODY ${resp.body}");

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        errorMessage.value = _prettyApiError(resp.body, resp.statusCode);
        return;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final model = FeesModel.fromJson(decoded);

      final items = model.data?.fees ?? <FeeItem>[];
      final pagination = model.data?.pagination;

      if (pagination != null) {
        currentPage.value = pagination.currentPage ?? currentPage.value;
        lastPage.value = pagination.lastPage ?? lastPage.value;
      }

      final mapped = items.map(_mapFeeToVM).toList();
      if (reset) {
        invoices.assignAll(mapped);
      } else {
        invoices.addAll(mapped);
      }

      // UI reads this list, so keep it updated
      filteredInvoices.assignAll(invoices);
    } catch (e) {
      errorMessage.value = "Failed to load fees: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Uri _buildFeesUri({required int page}) {
    final params = <String, String>{
      "page": page.toString(),
    };

    // member -> trainee_id (most backends use id, not name)
    final mem = selectedMember.value;
    if (mem != "All Members") {
      final id = _memberIdByName[mem];
      if (id != null) params["trainee_id"] = id.toString(); // ✅ adjust if backend uses different key
    }

    final st = selectedStatus.value;
    if (st != "All Status") params["status"] = st; // ✅ adjust if backend expects lowercase etc.

    final dur = selectedDuration.value;
    if (dur != "All Durations") params["duration_type"] = dur;

    final mon = selectedMonth.value;
    if (mon != "All Months") {
      // Convert "Jan" -> 1, "Feb" -> 2...
      final monthNo = _monthNameToNumber(mon);
      if (monthNo != null) params["month_number"] = monthNo.toString();
    }

    if (fromDate != null) {
      params["from_date"] = DateFormat("yyyy-MM-dd").format(fromDate!);
    }
    if (toDate != null) {
      params["to_date"] = DateFormat("yyyy-MM-dd").format(toDate!);
    }

    final q = searchCtrl.text.trim();
    if (q.isNotEmpty) params["search"] = q; // ✅ adjust if backend uses "q"

    return Uri.parse("$_base$feesEndpoint").replace(queryParameters: params);
  }

  int? _monthNameToNumber(String mon) {
    const map = {
      "Jan": 1, "Feb": 2, "Mar": 3, "Apr": 4, "May": 5, "Jun": 6,
      "Jul": 7, "Aug": 8, "Sep": 9, "Oct": 10, "Nov": 11, "Dec": 12,
    };
    return map[mon];
  }

  // Keep your UI button calling this
  Future<void> applyFilters() async {
    await fetchFees(reset: true);
  }

  Future<void> loadMore() async {
    if (isLoading.value) return;
    if (currentPage.value >= lastPage.value) return;
    currentPage.value = currentPage.value + 1;
    await fetchFees(reset: false);
  }

  // ------------------- Actions -------------------
  void viewInvoice(InvoiceVM inv) {
    final feeId = inv.id ?? 0;
    if (feeId <= 0) {
      Get.snackbar("Unable to open", "Missing fee id.");
      return;
    }

    Get.snackbar("Opening", "Payfees screen");
    Get.toNamed(RouteName.payfees, arguments: feeId);
  }

  void deleteInvoice(InvoiceVM inv) {
    // Right now you delete locally; real delete needs DELETE endpoint.
    invoices.removeWhere((e) => e.invoiceNo == inv.invoiceNo);
    filteredInvoices.assignAll(invoices);
    Get.snackbar("Deleted", "${inv.invoiceNo} removed");
  }

  // ------------------- Mapping + parsing -------------------
  InvoiceVM _mapFeeToVM(FeeItem f) {
    final amount = _toDoubleSafe(f.amount);
    final due = _parseDateSafe(f.dueDate) ?? DateTime.now();
    final member = f.trainee?.name ?? "-";
    final status = (f.status ?? "Pending").trim().isEmpty ? "Pending" : (f.status ?? "Pending");

    // duration: prefer API durationType; fallback to monthNumber if needed
    final duration = (f.durationType ?? "").trim().isNotEmpty
        ? f.durationType!.trim()
        : "Monthly";

    return InvoiceVM(
      id: f.id,
      invoiceNo: f.invoiceNumber ?? (f.id != null ? "INV-${f.id}" : "-"),
      member: member,
      duration: duration,
      amount: amount,
      dueDate: due,
      status: status,
      phone: "-", // API doesn't provide phone in fees payload; keep placeholder
    );
  }

  double _toDoubleSafe(String? s) {
    if (s == null) return 0;
    final cleaned = s.replaceAll(",", "").trim();
    return double.tryParse(cleaned) ?? 0;
  }

  DateTime? _parseDateSafe(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;

    // ISO?
    final iso = DateTime.tryParse(t);
    if (iso != null) return iso;

    // common backend format: yyyy-MM-dd
    try {
      return DateFormat("yyyy-MM-dd").parseStrict(t);
    } catch (_) {}

    return null;
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

// ✅ ViewModel used by your UI DataTable
class InvoiceVM {
  final int? id;
  final String invoiceNo;
  final String member;
  final String duration;
  final double amount;
  final DateTime dueDate;
  final String status;
  final String phone;

  InvoiceVM({
    required this.id,
    required this.invoiceNo,
    required this.member,
    required this.duration,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.phone,
  });

  String get amountText =>
      NumberFormat.currency(locale: "en_IN", symbol: "₹", decimalDigits: 2).format(amount);

  String get dueDateText => DateFormat("MMM dd, yyyy").format(dueDate);
}
