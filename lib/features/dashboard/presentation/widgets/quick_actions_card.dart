import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      QuickAction(
        icon: Iconsax.user_add,
        title: 'Add Employee',
        subtitle: 'Register new team member',
        color: const Color(0xFF10B981),
        onTap: () => context.go('/employees'),
      ),
      QuickAction(
        icon: Iconsax.monitor,
        title: 'Add Asset',
        subtitle: 'Register new equipment',
        color: const Color(0xFF3B82F6),
        onTap: () => context.go('/assets'),
      ),
      QuickAction(
        icon: Icons.subscriptions,
        title: 'New Subscription',
        subtitle: 'Add software license',
        color: const Color(0xFF8B5CF6),
        onTap: () => context.go('/subscriptions'),
      ),
      QuickAction(
        icon: Iconsax.notification,
        title: 'Set Reminder',
        subtitle: 'Create new alert',
        color: const Color(0xFFF59E0B),
        onTap: () => context.go('/reminders'),
      ),
    ];

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
          Text(
            'Quick Actions',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideX(begin: -0.2, end: 0),
          const SizedBox(height: 20),
          ...actions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: action.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: action.color.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: action.color.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: action.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            action.icon,
                            color: action.color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                action.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                action.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Iconsax.arrow_right_3,
                          color: Colors.grey.shade400,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 500 + (index * 100)))
                .slideX(begin: 0.3, end: 0);
          }).toList(),
        ],
      ),
    );
  }
}

class QuickAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}