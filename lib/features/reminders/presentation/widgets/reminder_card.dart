// lib/features/reminders/presentation/widgets/reminder_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/reminder.dart';

class ReminderCard extends StatefulWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDismiss;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onDismiss,
  });

  @override
  State<ReminderCard> createState() => _ReminderCardState();
}

class _ReminderCardState extends State<ReminderCard>
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
            ..scale(_isHovered ? 1.02 : 1.0),
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
                    ? widget.reminder.priorityColor.withOpacity(0.3)
                    : Colors.grey.shade200,
                width: _isHovered ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                _buildPriorityIndicator(),
                const SizedBox(width: 16),
                _buildReminderIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildReminderContent(),
                ),
                const SizedBox(width: 16),
                _buildTimeInfo(),
                const SizedBox(width: 16),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    return Container(
      width: 4,
      height: 60,
      decoration: BoxDecoration(
        color: widget.reminder.priorityColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildReminderIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: widget.reminder.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        widget.reminder.typeIcon,
        color: widget.reminder.statusColor,
        size: 24,
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildReminderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.reminder.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.reminder.description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Iconsax.category,
              size: 14,
              color: Colors.grey.shade500,
            ),
            const SizedBox(width: 4),
            Text(
              widget.reminder.typeDisplayName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.reminder.isRecurring) ...[
              const SizedBox(width: 12),
              Icon(
                Iconsax.refresh,
                size: 14,
                color: Colors.blue.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                'Recurring',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.reminder.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.reminder.statusDisplayName,
        style: TextStyle(
          color: widget.reminder.statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTimeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.reminder.formattedReminderDate.split(' ')[0], // Date only
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.reminder.formattedReminderDate.split(' ')[1], // Time only
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: widget.reminder.priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.reminder.timeUntilDue,
            style: TextStyle(
              fontSize: 11,
              color: widget.reminder.priorityColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            widget.onEdit();
            break;
          case 'dismiss':
            widget.onDismiss();
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
        if (widget.reminder.status == ReminderStatus.pending)
          PopupMenuItem(
            value: 'dismiss',
            child: Row(
              children: [
                Icon(Iconsax.close_circle, size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text('Dismiss', style: TextStyle(color: Colors.orange.shade600)),
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.more_vert,
          size: 16,
          color: Colors.grey.shade600,
        ),
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