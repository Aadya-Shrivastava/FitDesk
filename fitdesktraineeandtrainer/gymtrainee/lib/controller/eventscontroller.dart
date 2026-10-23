import 'package:get/get.dart';
import 'package:gymtrainee/Model/extramodels.dart';
import 'package:gymtrainee/widgets/api_client.dart';

class EventsController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final events = <EventItem>[].obs;

  List<EventItem> get upcoming =>
      events.where((e) => e.isUpcomingOrOngoing).toList();

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    error.value = '';
    try {
      final body = await Api.get('/trainee/events');
      final list = Api.findList(body, ['events']).map(EventItem.fromJson).toList()
        ..sort((a, b) => (a.startDate ?? '').compareTo(b.startDate ?? ''));
      events.assignAll(list);
    } catch (e) {
      Api.report('Events.fetch', e);
      error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }
}
