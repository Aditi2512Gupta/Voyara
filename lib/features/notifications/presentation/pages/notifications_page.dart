import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/data/models/notification_model.dart';
import '../../../../core/providers/notification_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
        actions: [
          notificationsAsync.maybeWhen(
            data: (notifications) {
              final hasUnread = notifications.any((n) => !n.read);
              if (!hasUnread) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Center(
                  child: InkWell(
                    onTap: () {
                      ref.read(notificationRepositoryProvider).markAllAsRead();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.secondary.withValues(alpha: 0.15)
                            : AppColors.secondaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.done_all_rounded,
                            size: 15,
                            color: isDark
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Mark all read',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.secondary
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: ResponsiveContentWrapper(
        child: notificationsAsync.when(
          loading: () => _buildLoadingState(isDark),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                error.toString(),
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return _buildEmptyState(context, isDark);
            }

            final grouped = _groupNotifications(notifications);

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: grouped.keys.length,
              itemBuilder: (context, groupIndex) {
                final groupTitle = grouped.keys.elementAt(groupIndex);
                final items = grouped[groupTitle]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Date Group Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      child: Row(
                        children: [
                          Text(
                            groupTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.chipDark
                                  : AppColors.chipLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${items.length}',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Notification Cards in Group
                    ...items.map(
                      (notification) => _buildNotificationCard(
                        context: context,
                        ref: ref,
                        notification: notification,
                        isDark: isDark,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required WidgetRef ref,
    required NotificationModel notification,
    required bool isDark,
  }) {
    final unread = !notification.read;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: Dismissible(
        key: ValueKey(notification.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        onDismissed: (_) {
          ref
              .read(notificationRepositoryProvider)
              .deleteNotification(notification.id);
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (unread) {
                ref
                    .read(notificationRepositoryProvider)
                    .markAsRead(notification.id);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: unread
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                      : (isDark ? AppColors.cardDark : AppColors.cardLight),
                  border: Border.all(
                    color: unread
                        ? (isDark
                              ? AppColors.secondary.withValues(alpha: 0.45)
                              : AppColors.secondary.withValues(alpha: 0.6))
                        : (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight),
                    width: unread ? 1.4 : 1.0,
                  ),
                  boxShadow: unread && !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    if (unread)
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3.5,
                          color: AppColors.secondary,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Leading Contextual Icon
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: unread
                                  ? AppColors.secondary.withValues(alpha: 0.14)
                                  : (isDark
                                        ? AppColors.inputDark
                                        : AppColors.inputLight),
                              border: Border.all(
                                color: unread
                                    ? AppColors.secondary.withValues(alpha: 0.3)
                                    : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.borderLight),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              _getNotificationIcon(
                                notification.title,
                                notification.body,
                              ),
                              size: 20,
                              color: unread
                                  ? AppColors.secondary
                                  : (isDark
                                        ? AppColors.textTertiaryDark
                                        : AppColors.textTertiaryLight),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Notification Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title & Time Row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notification.title,
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: unread
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: isDark
                                              ? (unread
                                                    ? AppColors.textPrimaryDark
                                                    : AppColors
                                                          .textSecondaryDark)
                                              : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime(notification.createdAt),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: unread
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: unread
                                            ? AppColors.secondary
                                            : (isDark
                                                  ? AppColors.textTertiaryDark
                                                  : AppColors
                                                        .textTertiaryLight),
                                      ),
                                    ),
                                    if (unread) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 7,
                                        height: 7,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.tertiary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 5),

                                // Body text
                                Text(
                                  notification.body,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: isDark
                                        ? (unread
                                              ? AppColors.textSecondaryDark
                                              : AppColors.textTertiaryDark)
                                        : (unread
                                              ? AppColors.textPrimaryLight
                                              : AppColors.textSecondaryLight),
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.secondary : AppColors.primary)
                    .withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 38,
                color: isDark ? AppColors.secondary : AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "All Caught Up!",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any notifications right now. Travel updates, booking alerts, and trip reminders will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text('Discover Destinations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? AppColors.cardDark : Colors.white,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.chipDark : AppColors.chipLight,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isDark
                              ? AppColors.chipDark
                              : AppColors.chipLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: isDark
                              ? AppColors.chipDark
                              : AppColors.chipLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<String, List<NotificationModel>> _groupNotifications(
    List<NotificationModel> notifications,
  ) {
    final sorted = List<NotificationModel>.from(notifications)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final groups = <String, List<NotificationModel>>{};

    for (final n in sorted) {
      final key = _formatDateGroup(n.createdAt);
      groups.putIfAbsent(key, () => []).add(n);
    }

    return groups;
  }

  String _formatDateGroup(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(itemDate).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return 'This Week';
    return 'Earlier';
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';

    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$formattedHour:$minute $period';
  }

  IconData _getNotificationIcon(String title, String body) {
    final text = '${title.toLowerCase()} ${body.toLowerCase()}';
    if (text.contains('book') ||
        text.contains('flight') ||
        text.contains('hotel') ||
        text.contains('ticket')) {
      return Icons.airplane_ticket_outlined;
    }
    if (text.contains('trip') ||
        text.contains('travel') ||
        text.contains('itinerary')) {
      return Icons.luggage_outlined;
    }
    if (text.contains('offer') ||
        text.contains('discount') ||
        text.contains('sale')) {
      return Icons.local_offer_outlined;
    }
    if (text.contains('review') ||
        text.contains('rate') ||
        text.contains('star')) {
      return Icons.star_outline_rounded;
    }
    if (text.contains('reminder') ||
        text.contains('alarm') ||
        text.contains('time')) {
      return Icons.alarm_outlined;
    }
    return Icons.notifications_none_rounded;
  }
}
