import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../widgets/animated_sidebar.dart';
import '../widgets/app_header.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  bool _isSidebarExpanded = true;
  late AnimationController _sidebarController;
  late AnimationController _contentController;

  @override
  void initState() {
    super.initState();
    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _sidebarController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _sidebarController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Row(
        children: [
          AnimatedSidebar(
            isExpanded: _isSidebarExpanded,
            onToggle: _toggleSidebar,
            controller: _sidebarController,
          ),
          Expanded(
            child: Column(
              children: [
                AppHeader(
                  onMenuPressed: _toggleSidebar,
                  isSidebarExpanded: _isSidebarExpanded,
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.all(16),
                    child: widget.child
                        .animate(controller: _contentController)
                        .fadeIn(duration: 300.ms)
                        .slideX(begin: 0.1, end: 0, duration: 300.ms),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}