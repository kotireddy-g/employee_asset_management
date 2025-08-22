// lib/features/employees/presentation/widgets/employee_actions_dialog.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../documents/presentation/widgets/asset_handover_dialog.dart';
import '../../../documents/presentation/widgets/no_dues_dialog.dart';
import '../../models/employee.dart';

class EmployeeActionsDialog extends StatelessWidget {
  final Employee employee;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EmployeeActionsDialog({
    super.key,
    required this.employee,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildContent(context),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Text(
              employee.name.split(' ').map((n) => n[0]).take(2).join(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0),
                Text(
                  '${employee.designation} • ${employee.department}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.3, end: 0),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employee Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(context),
          const SizedBox(height: 24),
          Text(
            'Documents & Reports',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          _buildDocumentButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Iconsax.edit,
            label: 'Edit Employee',
            color: Colors.blue,
            onTap: () {
              Navigator.of(context).pop();
              onEdit?.call();
            },
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.3, end: 0),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Iconsax.trash,
            label: 'Delete Employee',
            color: Colors.red,
            onTap: () {
              Navigator.of(context).pop();
              onDelete?.call();
            },
          ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.3, end: 0),
        ),
      ],
    );
  }

  Widget _buildDocumentButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDocumentButton(
                icon: Iconsax.document_text,
                label: 'Asset Handover',
                subtitle: 'Generate handover report',
                color: const Color(0xFF6366F1),
                onTap: () => _showAssetHandoverDialog(context),
              ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDocumentButton(
                icon: Iconsax.document_text_1,
                label: 'No Dues Certificate',
                subtitle: 'Generate exit clearance',
                color: const Color(0xFFEF4444),
                onTap: () => _showNoDuesDialog(context),
              ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.3, end: 0),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDocumentButton(
                icon: Iconsax.folder_2,
                label: 'Document History',
                subtitle: 'View all documents',
                color: Colors.orange,
                onTap: () => _showDocumentHistory(context),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, end: 0),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDocumentButton(
                icon: Iconsax.export,
                label: 'Exit Process',
                subtitle: 'Initiate employee exit',
                color: Colors.purple,
                onTap: () => _initiateExitProcess(context),
              ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, end: 0),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAssetHandoverDialog(BuildContext context) {
    Navigator.of(context).pop(); // Close current dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AssetHandoverDialog(employee: employee),
    );
  }

  void _showNoDuesDialog(BuildContext context) {
    Navigator.of(context).pop(); // Close current dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NoDuesDialog(employee: employee),
    );
  }

  void _showDocumentHistory(BuildContext context) {
    Navigator.of(context).pop(); // Close current dialog
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Document History',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Employee: ${employee.name}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.document,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No documents generated yet',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initiateExitProcess(BuildContext context) {
    Navigator.of(context).pop(); // Close current dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initiate Exit Process'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to initiate the exit process for ${employee.name}?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This will:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text('• Mark employee for exit'),
                  Text('• Initialize exit checklist'),
                  Text('• Send notifications to relevant departments'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showNoDuesDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}