import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/asset.dart';

class AssetCard extends StatefulWidget {
  final Asset asset;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAssign;
  final VoidCallback? onReturn;

  const AssetCard({
    super.key,
    required this.asset,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onAssign,
    this.onReturn,
  });

  @override
  State<AssetCard> createState() => _AssetCardState();
}

class _AssetCardState extends State<AssetCard>
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
                _buildAssetIcon(),
                const SizedBox(height: 16),
                _buildAssetInfo(),
                const Spacer(),
                _buildAssetDetails(),
                const SizedBox(height: 12),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssetInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.asset.deviceId,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${widget.asset.brand} ${widget.asset.model}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          widget.asset.type.toString().split('.').last.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // Status indicator row
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _getStatusText(),
              style: TextStyle(
                fontSize: 12,
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (widget.asset.status) {
      case AssetStatus.available:
        return const Color(0xFF10B981);
      case AssetStatus.assigned:
        return const Color(0xFF3B82F6);
      case AssetStatus.maintenance:
        return const Color(0xFFF59E0B);
      case AssetStatus.disposed:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (widget.asset.status) {
      case AssetStatus.available:
        return 'Available';
      case AssetStatus.assigned:
        return 'Assigned';
      case AssetStatus.maintenance:
        return 'Maintenance';
      case AssetStatus.disposed:
        return 'Disposed';
    }
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;

    switch (widget.asset.status) {
      case AssetStatus.available:
        statusColor = const Color(0xFF10B981);
        statusText = 'Available';
        break;
      case AssetStatus.assigned:
        statusColor = const Color(0xFF3B82F6);
        statusText = 'Assigned';
        break;
      case AssetStatus.maintenance:
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Maintenance';
        break;
      case AssetStatus.disposed:
        statusColor = Colors.grey;
        statusText = 'Disposed';
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
          case 'return':
            widget.onReturn?.call();
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
        if (widget.asset.status == AssetStatus.available && widget.onAssign != null)
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
        if (widget.asset.status == AssetStatus.assigned && widget.onReturn != null)
          PopupMenuItem(
            value: 'return',
            child: Row(
              children: [
                Icon(Iconsax.undo, size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text('Return', style: TextStyle(color: Colors.orange.shade600)),
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

  Widget _buildAssetIcon() {
    IconData icon;
    Color iconColor;

    switch (widget.asset.type) {
      case AssetType.laptop:
        icon = Icons.laptop;
        iconColor = const Color(0xFF3B82F6);
        break;
      case AssetType.desktop:
        icon = Iconsax.monitor;
        iconColor = const Color(0xFF10B981);
        break;
      case AssetType.mobile:
        icon = Iconsax.mobile;
        iconColor = const Color(0xFF8B5CF6);
        break;
      case AssetType.tablet:
        icon = Icons.tablet;
        iconColor = const Color(0xFFF59E0B);
        break;
      case AssetType.other:
        icon = Iconsax.box;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 28,
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildAssetDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Iconsax.code,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'S/N: ${widget.asset.serialNo}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (widget.asset.assignedTo != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Iconsax.user,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Assigned to: ${widget.asset.assignedTo}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          if (widget.asset.assignedDate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Iconsax.calendar,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  'Since: ${widget.asset.assignedDate!.day}/${widget.asset.assignedDate!.month}/${widget.asset.assignedDate!.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.asset.status == AssetStatus.disposed) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (widget.asset.status == AssetStatus.available && widget.onAssign != null)
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
        if (widget.asset.status == AssetStatus.assigned && widget.onReturn != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: widget.onReturn,
              icon: const Icon(Iconsax.undo, size: 14),
              label: const Text('Return'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        if (widget.asset.status == AssetStatus.maintenance)
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
                  Icon(Icons.pan_tool, size: 14, color: Colors.orange.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'In Maintenance',
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