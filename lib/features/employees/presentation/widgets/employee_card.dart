import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/employee.dart';
import '../screens/employees_screen.dart';

class EmployeeCard extends StatefulWidget {
  final Employee employee;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.05 : 1.0),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? Colors.black.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: _isHovered ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFF6366F1).withOpacity(0.3)
                    : Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(),
                    _buildActionMenu(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildAvatar(),
                const SizedBox(height: 16),
                _buildEmployeeInfo(),
                const Spacer(),
                _buildContactInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;

    switch (widget.employee.status) {
      case EmployeeStatus.active:
        statusColor = const Color(0xFF10B981);
        statusText = 'Active';
        break;
      case EmployeeStatus.inactive:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Inactive';
        break;
      case EmployeeStatus.terminated:
        statusColor = const Color(0xFFEF4444);
        statusText = 'Terminated';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onEdit();
            break;
          case 'delete':
            widget.onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Iconsax.edit, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              const Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Iconsax.trash, size: 16, color: Colors.red.shade400),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red.shade400)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.more_horiz,
          size: 16,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Center(
        child: Text(
          widget.employee.name.split(' ').map((e) => e[0]).take(2).join(),
          style: const TextStyle(
            color: Color(0xFF6366F1),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildEmployeeInfo() {
    return Column(
      children: [
        Text(
          widget.employee.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.employee.position,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          widget.employee.department,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.sms,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.employee.email,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }
}