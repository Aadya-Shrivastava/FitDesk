import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/Model/payfeesmodel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';

class Payfeescontroller extends GetxController {
  // -------- API --------
  final String _base = "https://fitdesk.theapexinnovation.com/";
  final String detailEndpoint = "api/v1/gym-owner/trainee-fees"; // + /{id}

  // ⚠️ YOU DIDN'T PROVIDE PAY API. Change this when you know it.
  final String markPaidEndpoint = "api/v1/gym-owner/trainee-fees"; // + /{id}/payment

  // -------- State --------
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = "".obs;

  final fee = Rxn<PayFeesData>();

  late final int feeId;

  // -------- Form --------
  final amountCtrl = TextEditingController();
  final referenceCtrl = TextEditingController();
  final paidDateCtrl = TextEditingController();

  static const methodOptions = <_PaymentMethodOption>[
    _PaymentMethodOption("cash", "Cash"),
    _PaymentMethodOption("card", "Card"),
    _PaymentMethodOption("bank_transfer", "Bank Transfer"),
    _PaymentMethodOption("cheque", "Cheque"),
    _PaymentMethodOption("upi", "UPI"),
    _PaymentMethodOption("other", "Other"),
  ];

  final selectedMethod = "cash".obs;

  DateTime? paidDate;

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is int) {
      feeId = arg;
    } else if (arg is String) {
      feeId = int.tryParse(arg) ?? -1;
    } else {
      feeId = -1;
    }

    if (feeId <= 0) {
      errorMessage.value = "Invalid fee id.";
      return;
    }

    fetchFeeDetail();
  }

  @override
  void onClose() {
    amountCtrl.dispose();
    referenceCtrl.dispose();
    paidDateCtrl.dispose();
    super.onClose();
  }

  Future<void> fetchFeeDetail() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = "";

    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        errorMessage.value = "Token missing. Please login again.";
        return;
      }

      final url = Uri.parse("$_base$detailEndpoint/$feeId");
      final resp = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        errorMessage.value = _prettyApiError(resp.body, resp.statusCode);
        return;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final model = PayFeesModel.fromJson(decoded);

      final d = model.data;
      if (d == null) {
        errorMessage.value = model.message ?? "No data found.";
        return;
      }

      fee.value = d;

      // Pre-fill form from API:
      final balance = _toDoubleSafe(d.balanceAmount);
      amountCtrl.text = balance > 0 ? balance.toStringAsFixed(2) : _toDoubleSafe(d.amount).toStringAsFixed(2);

      // method/date if provided
      final m = (d.paymentMethod ?? "").trim();
      if (m.isNotEmpty && methodOptions.any((opt) => opt.value == m)) {
        selectedMethod.value = m;
      }

      if ((d.paidDate ?? "").trim().isNotEmpty) {
        paidDate = _parseDateSafe(d.paidDate);
        if (paidDate != null) {
          paidDateCtrl.text = DateFormat("dd-MM-yyyy").format(paidDate!);
        }
      }
    } catch (e) {
      errorMessage.value = "Failed to load fee detail: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickPaidDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: paidDate ?? DateTime.now(),
    );
    if (picked != null) {
      paidDate = picked;
      paidDateCtrl.text = DateFormat("dd-MM-yyyy").format(picked);
    }
  }

  Future<void> markAsPaid() async {
    final d = fee.value;
    if (d == null) return;

    final amount = _toDoubleSafe(amountCtrl.text);
    if (amount <= 0) {
      Get.snackbar("Invalid", "Payment amount must be > 0");
      return;
    }

    if (isSaving.value) return;
    isSaving.value = true;

    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        Get.snackbar("Auth", "Token missing. Please login again.");
        return;
      }

      if ((selectedMethod.value != "cash") && referenceCtrl.text.trim().isEmpty) {
        Get.snackbar("Missing", "Reference is required for non-cash payments");
        return;
      }

      final url = Uri.parse("$_base$markPaidEndpoint/${d.id}/payment");

      final body = <String, dynamic>{
        "payment_amount": amount,
        "payment_method": selectedMethod.value,
      };

      final ref = referenceCtrl.text.trim();
      if (ref.isNotEmpty) {
        body["payment_reference"] = ref;
      }

      final resp = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        Get.snackbar("Failed", _prettyApiError(resp.body, resp.statusCode));
        return;
      }

      Get.snackbar("Success", "Payment updated");
      await fetchFeeDetail();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  // -------- Helpers --------
  double _toDoubleSafe(String? s) {
    if (s == null) return 0;
    final cleaned = s.replaceAll(",", "").trim();
    return double.tryParse(cleaned) ?? 0;
  }

  DateTime? _parseDateSafe(String? s) {
    if (s == null) return null;
    final t = s.trim();
    if (t.isEmpty) return null;
    final iso = DateTime.tryParse(t);
    if (iso != null) return iso;
    try {
      return DateFormat("yyyy-MM-dd").parseStrict(t);
    } catch (_) {}
    return null;
  }

  String money(String? amount) {
    final v = _toDoubleSafe(amount);
    return NumberFormat.currency(locale: "en_IN", symbol: "₹", decimalDigits: 2).format(v);
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

class _PaymentMethodOption {
  final String value;
  final String label;

  const _PaymentMethodOption(this.value, this.label);
}
