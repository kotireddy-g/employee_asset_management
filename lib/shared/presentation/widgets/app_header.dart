import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class AppHeader extends StatelessWidget {
  final VoidCallback onMenuPressed;
  final bool isSidebarExpanded;

  const AppHeader({
    super.key,
    required this.onMenuPressed,
    required this.isSidebarExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuPressed,
            icon: AnimatedRotation(
              turns: isSidebarExpanded ? 0 : 0.5,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Iconsax.menu_1),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _getPageTitle(context),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.2, end: 0),
          ),
          _buildSearchBox(),
          const SizedBox(width: 16),
          _buildNotificationButton(),
          const SizedBox(width: 16),
          _buildUserMenu(),
        ],
      ),
    );
  }

  String _getPageTitle(BuildContext context) {
    final currentPath = ModalRoute.of(context)?.settings.name ?? '';
    if (currentPath.contains('dashboard')) return 'Dashboard';
    if (currentPath.contains('employees')) return 'Employees';
    if (currentPath.contains('assets')) return 'Assets';
    if (currentPath.contains('subscriptions')) return 'Subscriptions';
    if (currentPath.contains('reminders')) return 'Reminders';
    return 'Dashboard';
  }

  Widget _buildSearchBox() {
    return Container(
      width: 300,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Iconsax.notification),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Center(
              child: Text(
                '3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2))
              .then()
              .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0)),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 150.ms, duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }

  Widget _buildUserMenu() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF6366F1),
            child: const Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Admin',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Iconsax.arrow_down_1,
            size: 16,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 300.ms)
        .slideX(begin: 0.2, end: 0);
  }
}