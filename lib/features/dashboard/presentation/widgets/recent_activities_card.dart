import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/providers/dashboard_provider.dart';

class RecentActivitiesCard extends ConsumerWidget {
  const RecentActivitiesCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activities',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideX(begin: -0.2, end: 0),
              Row(
                children: [
                  if (dashboardState.recentActivities.isEmpty && !dashboardState.isLoading)
                    TextButton.icon(
                      onPressed: () => ref.read(dashboardProvider.notifier).loadDashboardData(),
                      icon: const Icon(Iconsax.refresh, size: 16),
                      label: const Text('Refresh'),
                    ),
                  TextButton(
                    onPressed: () {
                      // Navigate to full activities page
                    },
                    child: const Text('View All'),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
          const SizedBox(height: 20),
          _buildActivitiesList(dashboardState.recentActivities, dashboardState.isLoading),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(List<RecentActivity> activities, bool isLoading) {
    if (isLoading && activities.isEmpty) {
      return _buildLoadingState();
    }

    if (activities.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: activities.take(5).map((activity) => _buildActivityItem(activity, activities.indexOf(activity))).toList(),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) =>
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Iconsax.activity,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activities',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Activities will appear here when users interact with the system',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity, int index) {
    // Helper method to get icon and color based on activity type
    IconData getActivityIcon(String type) {
      switch (type.toLowerCase()) {
        case 'employee_added':
          return Iconsax.user_add;
        case 'asset_assigned':
          return Iconsax.arrow_right_3;
        case 'asset_returned':
          return Iconsax.undo;
        case 'subscription_added':
          return Iconsax.add_circle;
        case 'reminder_created':
          return Iconsax.notification;
        default:
          return Iconsax.activity;
      }
    }

    Color getActivityColor(String type) {
      switch (type.toLowerCase()) {
        case 'employee_added':
          return const Color(0xFF10B981);
        case 'asset_assigned':
          return const Color(0xFF3B82F6);
        case 'asset_returned':
          return const Color(0xFFF59E0B);
        case 'subscription_added':
          return const Color(0xFF8B5CF6);
        case 'reminder_created':
          return const Color(0xFFEF4444);
        default:
          return const Color(0xFF6B7280);
      }
    }

    String getTimeAgo(DateTime timestamp) {
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    }

    final activityIcon = getActivityIcon(activity.type);
    final activityColor = getActivityColor(activity.type);
    final timeAgo = getTimeAgo(activity.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activityIcon,
              color: activityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (activity.employeeName != null || activity.assetName != null)
                  Text(
                    [
                      if (activity.employeeName != null) 'Employee: ${activity.employeeName}',
                      if (activity.assetName != null) 'Asset: ${activity.assetName}',
                    ].join(' • '),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 500 + (index * 100)))
        .slideX(begin: 0.3, end: 0);
  }
}