import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../screens/dashboard_screen.dart';

class StatsCard extends StatefulWidget {
  final StatsData data;

  const StatsCard({super.key, required this.data});

  @override
  State<StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<StatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? 1.05 : 1.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? widget.data.color.withOpacity(0.2)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: _isHovered
                  ? widget.data.color.withOpacity(0.3)
                  : Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.data.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.color,
                      size: 24,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.data.isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.data.isPositive
                              ? Iconsax.arrow_up_3
                              : Iconsax.arrow_down,
                          color: widget.data.isPositive
                              ? Colors.green
                              : Colors.red,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.data.change,
                          style: TextStyle(
                            color: widget.data.isPositive
                                ? Colors.green
                                : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.data.value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 4),
              Text(
                widget.data.title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }
}