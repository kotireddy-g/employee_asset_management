import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/subscription.dart';

class SubscriptionCard extends StatefulWidget {
  final Subscription subscription;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAssign;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onAssign,
  });

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard>
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(),
                    _buildActionMenu(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSubscriptionIcon(),
                const SizedBox(height: 16),
                _buildSubscriptionInfo(),
                const Spacer(),
                _buildUsageInfo(),
                const SizedBox(height: 12),
                _buildCostInfo(),
                const SizedBox(height: 12),
                _buildActionButtons(),
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

    switch (widget.subscription.status) {
      case SubscriptionStatus.active:
        statusColor = const Color(0xFF10B981);
        statusText = 'Active';
        break;
      case SubscriptionStatus.expiring:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Expiring';
        break;
      case SubscriptionStatus.expired:
        statusColor = const Color(0xFFEF4444);
        statusText = 'Expired';
        break;
      case SubscriptionStatus.cancelled:
        statusColor = Colors.grey;
        statusText = 'Cancelled';
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
          case 'assign':
            widget.onAssign?.call();
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
        if (widget.subscription.availableSlots > 0 && widget.onAssign != null)
          PopupMenuItem(
            value: 'assign',
            child: Row(
              children: [
                Icon(Iconsax.user_add, size: 16, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text('Assign', style: TextStyle(color: Colors.blue.shade600)),
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

  Widget _buildSubscriptionIcon() {
    IconData icon;
    Color iconColor;

    switch (widget.subscription.type) {
      case SubscriptionType.software:
        icon = Iconsax.code;
        iconColor = const Color(0xFF3B82F6);
        break;
      case SubscriptionType.service:
        icon = Iconsax.global;
        iconColor = const Color(0xFF10B981);
        break;
      case SubscriptionType.license:
        icon = Iconsax.security_card;
        iconColor = const Color(0xFF8B5CF6);
        break;
      default:
        icon = Iconsax.box;
        iconColor = const Color(0xFFF59E0B);
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 24,
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildSubscriptionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.subscription.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.subscription.provider,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.subscription.type.toString().split('.').last.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageInfo() {
    final percentage = widget.subscription.maxUsers > 0
        ? (widget.subscription.currentUsers / widget.subscription.maxUsers) * 100
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usage',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              '${widget.subscription.currentUsers}/${widget.subscription.maxUsers}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              percentage > 80 ? Colors.red : const Color(0xFF6366F1),
            ),
            minHeight: 6,
          ),
        ),
        if (widget.subscription.availableSlots > 0) ...[
          const SizedBox(height: 4),
          Text(
            '${widget.subscription.availableSlots} slots available',
            style: TextStyle(
              fontSize: 11,
              color: Colors.green.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCostInfo() {
    String billingText;
    switch (widget.subscription.billingCycle) {
      case BillingCycle.monthly:
        billingText = '/month';
        break;
      case BillingCycle.quarterly:
        billingText = '/quarter';
        break;
      case BillingCycle.yearly:
        billingText = '/year';
        break;
      case BillingCycle.oneTime:
        billingText = 'one-time';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Cost',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            '\$${widget.subscription.cost.toStringAsFixed(2)}$billingText',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.subscription.status == SubscriptionStatus.cancelled ||
        widget.subscription.status == SubscriptionStatus.expired) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (widget.subscription.availableSlots > 0 && widget.onAssign != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onAssign,
              icon: const Icon(Iconsax.user_add, size: 14),
              label: const Text('Assign'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (widget.subscription.availableSlots <= 0)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.user, size: 14, color: Colors.orange.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Full',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
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