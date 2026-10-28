import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtrainee/controller/notificationcontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/state_views.dart';
import 'package:gymtrainee/widgets/ui_kit.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final NotificationController c = Get.put(NotificationController());

  @override
  void dispose() {
    // Opening the screen counts as reading them; clears the bell badge.
    c.markAllSeen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: simpleAppBar('Notifications', actions: [
        Obx(() => c.unreadCount > 0
            ? TextButton(
                onPressed: () => c.markAllSeen().then((_) => setState(() {})),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Mark all read'),
              )
            : const SizedBox.shrink()),
      ]),
      body: Obx(() {
        if (c.isLoading.value && c.items.isEmpty) return const LoadingView();
        if (c.error.value.isNotEmpty && c.items.isEmpty) {
          return ErrorView(message: c.error.value, onRetry: c.fetchNotifications);
        }
        if (c.items.isEmpty) {
          return EmptyView(
            icon: Icons.notifications_off_rounded,
            title: 'You\'re all caught up',
            subtitle: 'Announcements and reminders from your gym will appear here.',
            onRefresh: c.fetchNotifications,
          );
        }
        return RefreshIndicator(
          color: AppPalette.secondary,
          onRefresh: c.fetchNotifications,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: c.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = c.items[i];
              final unread = c.isUnread(n);
              return AppCard(
                gradient: unread ? AppPalette.headerGradient : null,
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(Icons.campaign_rounded,
                        color: unread ? AppPalette.secondary : AppPalette.textSecondary,
                        size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(n.title,
                                    style: appText(14,
                                        weight: unread ? FontWeight.w700 : FontWeight.w600)),
                              ),
                              if (unread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                      color: AppPalette.secondary, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          if (n.message.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(n.message,
                                style: appText(12.5, color: AppPalette.textSecondary)),
                          ],
                          if (n.createdAt != null) ...[
                            const SizedBox(height: 8),
                            Text('${timeAgo(n.createdAt)}  •  ${fmtDate(n.createdAt, pattern: 'dd MMM, hh:mm a')}',
                                style: appText(10.5, color: AppPalette.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
