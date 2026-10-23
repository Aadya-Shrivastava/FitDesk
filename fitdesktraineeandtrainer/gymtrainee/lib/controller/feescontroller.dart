import 'package:get/get.dart';
import 'package:gymtrainee/Model/extramodels.dart';
import 'package:gymtrainee/widgets/api_client.dart';

class FeesController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final fees = <FeeItem>[].obs;

  double get total => fees.fold(0, (s, f) => s + f.amount);
  double get paid => fees.fold(0, (s, f) => s + f.paidAmount);
  double get balance =>
      fees.fold(0, (s, f) => s + (f.balanceAmount > 0 ? f.balanceAmount : 0));
  int get pendingCount => fees.where((f) => !f.isPaid).length;

  /// Earliest unpaid due date, for the dashboard reminder.
  FeeItem? get nextDue {
    final unpaid = fees.where((f) => !f.isPaid).toList()
      ..sort((a, b) => (a.dueDate ?? '9999').compareTo(b.dueDate ?? '9999'));
    return unpaid.isEmpty ? null : unpaid.first;
  }

  @override
  void onInit() {
    super.onInit();
    fetchFees();
  }

  Future<void> fetchFees() async {
    isLoading.value = true;
    error.value = '';
    try {
      final body = await Api.get('/trainee/fees');
      fees.assignAll(
          Api.findList(body, ['fees', 'payments']).map(FeeItem.fromJson));
    } catch (e) {
      Api.report('Fees.fetchFees', e);
      error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }
}
