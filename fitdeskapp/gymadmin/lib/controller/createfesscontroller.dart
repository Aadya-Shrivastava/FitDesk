import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:gymadmin/controller/takefeescontroller.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';

class Createfesscontroller extends GetxController {
  final GetConnect _client = GetConnect();
  final GetStorage _storage = GetStorage();

  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> members = <Map<String, dynamic>>[].obs;

  final RxnInt selectedMemberId = RxnInt();
  final RxString durationType = 'monthly'.obs;
  final RxnInt selectedMonth = RxnInt();

  final amount = ''.obs;
  final dueDate = ''.obs;
  final notes = ''.obs;

  final Rxn<DateTime> membershipStartDate = Rxn<DateTime>();

  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  final List<Map<String, dynamic>> durationTypes = [
    {'key': 'monthly', 'label': 'Monthly'},
    {'key': 'quarterly', 'label': 'Quarterly'},
    {'key': 'half_yearly', 'label': 'Half Yearly'},
    {'key': 'yearly', 'label': 'Yearly'},
    {'key': 'one-time', 'label': 'One-time'},
  ];

  final List<Map<String, dynamic>> months = [
    {'key': 1, 'label': 'January'},
    {'key': 2, 'label': 'February'},
    {'key': 3, 'label': 'March'},
    {'key': 4, 'label': 'April'},
    {'key': 5, 'label': 'May'},
    {'key': 6, 'label': 'June'},
    {'key': 7, 'label': 'July'},
    {'key': 8, 'label': 'August'},
    {'key': 9, 'label': 'September'},
    {'key': 10, 'label': 'October'},
    {'key': 11, 'label': 'November'},
    {'key': 12, 'label': 'December'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
  }

  String get _token => _storage.read('token') ?? '';
  String get _baseUrl => 'https://fitdesk.theapexinnovation.com/api/v1';

  void clearError(String key) {
    if (fieldErrors.containsKey(key)) {
      fieldErrors.remove(key);
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchMembers() async {
    isLoading.value = true;
    try {
      final response = await _client.get(
        '$_baseUrl/gym-owner/trainees',
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.isOk) {
        final data = response.body;
        final list = (data['data']?['trainees'] ?? data['data'] ?? []) as List;
        members.value = list
            .map((e) => {
                  'id': e['id'],
                  'name': e['name'],
                  // try common shapes
                  'membership_start_date':
                      e['trainee']?['membership_start_date'] ??
                      e['trainee_detail']?['membership_start_date'] ??
                      e['membership_start_date'],
                })
            .toList()
            .cast<Map<String, dynamic>>();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onMemberChanged(int? id) {
    selectedMemberId.value = id;
    clearError('member');

    final member = members.firstWhereOrNull((m) => m['id'] == id);
    membershipStartDate.value = _parseDate(member?['membership_start_date']);

    if (durationType.value != 'one-time') {
      _setDueDateFromDuration();
    }
  }

  void onDurationChanged(String value) {
    durationType.value = value;
    clearError('duration');
    if (value == 'one-time') {
      dueDate.value = '';
      return;
    }
    _setDueDateFromDuration();
  }

  void onMonthChanged(int? value) {
    selectedMonth.value = value;
    clearError('month');
    if (durationType.value == 'monthly') {
      _setDueDateFromMonth();
    }
  }

  void _setDueDateFromDuration() {
    final joinDate = membershipStartDate.value;
    if (joinDate == null) return;

    final monthsToAdd = switch (durationType.value) {
      'monthly' => 1,
      'quarterly' => 3,
      'half_yearly' => 6,
      'yearly' => 12,
      _ => 0,
    };

    if (monthsToAdd == 0) return;

    final target = _addMonthsNoOverflow(joinDate, monthsToAdd);
    dueDate.value = DateFormat('yyyy-MM-dd').format(target);
  }

  void _setDueDateFromMonth() {
    final joinDate = membershipStartDate.value;
    final month = selectedMonth.value;
    if (joinDate == null || month == null) return;

    final now = DateTime.now();
    var year = now.year;
    if (month < now.month) {
      year += 1;
    }

    final day = joinDate.day;
    final lastDay = DateTime(year, month + 1, 0).day;
    final safeDay = day > lastDay ? lastDay : day;

    final target = DateTime(year, month, safeDay);
    dueDate.value = DateFormat('yyyy-MM-dd').format(target);
  }

  DateTime _addMonthsNoOverflow(DateTime date, int months) {
    final newMonth = date.month + months;
    final year = date.year + ((newMonth - 1) ~/ 12);
    final month = ((newMonth - 1) % 12) + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDay ? lastDay : date.day;
    return DateTime(year, month, day);
  }

  bool _validate() {
    fieldErrors.clear();

    if (selectedMemberId.value == null) {
      fieldErrors['member'] = 'Please select a member';
    }
    if (durationType.value.isEmpty) {
      fieldErrors['duration'] = 'Please select duration';
    }
    if (durationType.value == 'monthly' && selectedMonth.value == null) {
      fieldErrors['month'] = 'Please select month';
    }
    if (amount.value.trim().isEmpty) {
      fieldErrors['amount'] = 'Please enter amount';
    }
    if (durationType.value == 'one-time' && dueDate.value.trim().isEmpty) {
      fieldErrors['dueDate'] = 'Please select due date';
    }

    return fieldErrors.isEmpty;
  }

  Future<void> createFee() async {
    if (!_validate()) return;

    final body = {
      'trainee_id': selectedMemberId.value,
      'duration_type': durationType.value,
      'amount': double.tryParse(amount.value) ?? 0,
      'due_date': durationType.value == 'one-time' ? dueDate.value : null,
      'notes': notes.value.trim().isEmpty ? null : notes.value.trim(),
    };

    isLoading.value = true;
    try {
      final response = await _client.post(
        '$_baseUrl/gym-owner/trainee-fees',
        body,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (response.isOk) {
        Get.snackbar('Success', 'Fee created');
        if (Get.isRegistered<Takefeescontroller>()) {
          await Get.find<Takefeescontroller>().fetchFees(reset: true);
        }
        Get.offNamed(RouteName.viewfees);
      } else {
        Get.snackbar('Error', response.body?['message'] ?? 'Failed to create fee');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await Get.dialog<DateTime>(
      DatePickerDialog(
        initialDate: now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      ),
    );
    if (picked != null) {
      dueDate.value = DateFormat('yyyy-MM-dd').format(picked);
      clearError('dueDate');
    }
  }
}