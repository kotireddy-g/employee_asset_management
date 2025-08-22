import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class AnimatedSidebar extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final AnimationController controller;

  const AnimatedSidebar({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.controller,
  });

  @override
  State<AnimatedSidebar> createState() => _AnimatedSidebarState();
}

class _AnimatedSidebarState extends State<AnimatedSidebar> {
  String _currentRoute = '/dashboard';

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(
      icon: Iconsax.element_4,
      activeIcon: Iconsax.element_45,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    SidebarItem(
      icon: Iconsax.people,
      activeIcon: Iconsax.people5,
      label: 'Employees',
      route: '/employees',
    ),
    SidebarItem(
      icon: Iconsax.monitor,
      activeIcon: Iconsax.monitor5,
      label: 'Assets',
      route: '/assets',
    ),
    SidebarItem(
      icon: Icons.subscriptions_outlined,
      activeIcon: Icons.subscriptions_rounded,
      label: 'Subscriptions',
      route: '/subscriptions',
    ),
    SidebarItem(
      icon: Iconsax.notification,
      activeIcon: Iconsax.notification5,
      label: 'Reminders',
      route: '/reminders',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentRoute = GoRouterState.of(context).uri.path;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.isExpanded ? 280 : 80,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sidebarItems.length,
                itemBuilder: (context, index) {
                  return _buildSidebarItem(
                    _sidebarItems[index],
                    index,
                  );
                },
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    )
        .animate(controller: widget.controller)
        .slideX(begin: -1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF8B5CF6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.building,
              color: Colors.white,
              size: 24,
            ),
          ),
          if (widget.isExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asset Manager',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 100.ms, duration: 200.ms)
                      .slideX(begin: 0.2, end: 0),
                  Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 200.ms)
                      .slideX(begin: 0.2, end: 0),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSidebarItem(SidebarItem item, int index) {
    final isActive = _currentRoute == item.route;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentRoute = item.route;
            });
            context.go(item.route);
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: widget.isExpanded ? 16 : 28,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF6366F1).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: const Color(0xFF6366F1).withOpacity(0.2))
                  : null,
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    key: ValueKey(isActive),
                    color: isActive
                        ? const Color(0xFF6366F1)
                        : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                if (widget.isExpanded) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFF6366F1)
                            : Colors.grey.shade700,
                        fontSize: 15,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 50 * index))
                        .slideX(begin: 0.3, end: 0),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Handle logout
                context.go('/login');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isExpanded ? 16 : 28,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.logout,
                      color: Colors.red.shade400,
                      size: 24,
                    ),
                    if (widget.isExpanded) ...[
                      const SizedBox(width: 16),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red.shade400,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}