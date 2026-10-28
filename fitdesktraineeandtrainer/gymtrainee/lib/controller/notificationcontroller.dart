import 'package:get/get.dart';
import 'package:gymtrainee/Model/extramodels.dart';
import 'package:gymtrainee/widgets/api_client.dart';
import 'package:gymtrainee/widgets/localStorage/PrefConst.dart';
import 'package:gymtrainee/widgets/localStorage/localstorage.dart';

class NotificationController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final items = <NotificationItem>[].obs;
  final _seen = <String>{}.obs;

  /// Unread = the server says unread, or (when it doesn't say) not opened yet
  /// on this phone. There is no "mark as read" API, so it's tracked locally.
  bool isUnread(NotificationItem n) =>
      n.serverRead == null ? !_seen.contains(n.id) : n.serverRead == false && !_seen.contains(n.id);

  int get unreadCount => items.where(isUnread).length;

  @override
  void onInit() {
    super.onInit();
    _loadSeen().then((_) => fetchNotifications());
  }

  Future<void> _loadSeen() async {
    final raw = await PrefManager().readValue(key: PrefConst.seenNotifications);
    if (raw is List) _seen.addAll(raw.map((e) => e.toString()));
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    error.value = '';
    try {
      final body = await Api.get('/trainee/notifications');
      final list = Api.findList(body, ['notifications'])
          .map(NotificationItem.fromJson)
          .toList()
        ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      // The API sends the same notification twice (different ids and slightly
      // different timestamps), so keep only the newest per title + message.
      final unique = <String>{};
      items.assignAll(list.where((n) =>
          unique.add('${n.title.trim().toLowerCase()}|${n.message.trim().toLowerCase()}')));
    } catch (e) {
      Api.report('Notifications.fetch', e);
      error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllSeen() async {
    _seen.addAll(items.map((e) => e.id));
    await PrefManager()
        .writeValue(key: PrefConst.seenNotifications, value: _seen.toList());
  }
}
