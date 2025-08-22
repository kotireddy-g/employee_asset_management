// lib/features/employees/presentation/widgets/employee_card.dart (Fixed)
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/employee.dart';
import 'employee_actions_widget.dart';

class EmployeeCard extends StatefulWidget {
  final Employee employee;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EmployeeCard({
    super.key,
    required this.employee,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard>
    with TickerProviderStateMixin {
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
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_hoverController.value * 0.02),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05 + (_hoverController.value * 0.05)),
                      blurRadius: 10 + (_hoverController.value * 10),
                      offset: Offset(0, 5 + (_hoverController.value * 5)),
                    ),
                  ],
                ),
                child: _buildMainCard(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(child: _buildEmployeeInfo()),
              _buildStatusBadge(),
              const SizedBox(width: 12),
              _buildActionButton(),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1),
            const Color(0xFF6366F1).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.employee.name
              .split(' ')
              .map((name) => name.isNotEmpty ? name[0] : '')
              .take(2)
              .join()
              .toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildEmployeeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.employee.name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0),
        const SizedBox(height: 4),
        Text(
          widget.employee.designation,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3, end: 0),
        const SizedBox(height: 2),
        Text(
          widget.employee.department,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3, end: 0),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;

    switch (widget.employee.status) {
      case EmployeeStatus.active:
        statusColor = Colors.green;
        statusText = 'Active';
        break;
      case EmployeeStatus.inactive:
        statusColor = Colors.orange;
        statusText = 'Inactive';
        break;
      case EmployeeStatus.terminated:
        statusColor = Colors.red;
        statusText = 'Terminated';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).scale(begin: Offset(0.8, 0.8), end: Offset(1, 1));
  }

  Widget _buildActionButton() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Iconsax.more,
          size: 20,
          color: Colors.grey.shade600,
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 'actions':
            _showActionsDialog();
            break;
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: 'actions',
          child: Row(
            children: [
              Icon(
                Iconsax.setting_2,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              const Text('Actions & Documents'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Iconsax.edit,
                size: 16,
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 8),
              const Text('Edit Employee'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Iconsax.trash,
                size: 16,
                color: Colors.red.shade600,
              ),
              const SizedBox(width: 8),
              const Text('Delete Employee'),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).scale(begin: Offset(0.8, 0.8), end: Offset(1, 1));
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
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
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Iconsax.call,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                widget.employee.phone,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Icon(
                Iconsax.user_tag,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                'ID: ${widget.employee.employeeId}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0);
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

  void _showActionsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EmployeeActionsDialog(
        employee: widget.employee,
        onEdit: widget.onEdit,
        onDelete: widget.onDelete,
      ),
    );
  }
}