import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/documents_provider.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../employees/models/employee.dart';
import '../../models/no_dues_certificate.dart';

class NoDuesDialog extends ConsumerStatefulWidget {
  final Employee employee;

  const NoDuesDialog({
    super.key,
    required this.employee,
  });

  @override
  ConsumerState<NoDuesDialog> createState() => _NoDuesDialogState();
}

class _NoDuesDialogState extends ConsumerState<NoDuesDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  DateTime _resignationDate = DateTime.now();
  DateTime _lastWorkingDay = DateTime.now();
  List<ExitChecklistItem> _checklist = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
    _initializeChecklist();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeChecklist() {
    _checklist = [
      ExitChecklistItem(
        particular: 'Laptop Submission\n- Condition: Working/Not Working\n- Laptop Model:\n- Serial Number:\n- RAM & Storage:',
        status: ChecklistStatus.pending,
        responsiblePerson: 'IT Department',
      ),
      ExitChecklistItem(
        particular: 'Password Handover\n- Gmail - password recovered\n- Microsoft Office\n- Skype',
        status: ChecklistStatus.pending,
        responsiblePerson: 'IT Department',
      ),
      ExitChecklistItem(
        particular: 'Account Deactivation\n- Gmail - N/a\n- Microsoft Office - Completed\n- Skype - password recovered',
        status: ChecklistStatus.pending,
        responsiblePerson: 'IT Department',
      ),
      ExitChecklistItem(
        particular: 'Other Devices: (Mobile, Hard Drive, etc.)',
        status: ChecklistStatus.pending,
        responsiblePerson: 'IT Department',
      ),
      ExitChecklistItem(
        particular: 'Biometric Deactivation\nSubmission of Employee ID card',
        status: ChecklistStatus.pending,
        responsiblePerson: 'HR Department',
      ),
      ExitChecklistItem(
        particular: 'Termination Contract (Document Signature)',
        status: ChecklistStatus.pending,
        responsiblePerson: 'HR Department',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final documentsState = ref.watch(documentsProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 800),
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
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildContent(documentsState),
              ),
            ),
            _buildActions(documentsState),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.document_text_1,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Dues Certificate',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.3, end: 0),
                Text(
                  'Generate exit clearance document for ${widget.employee.name}',
                  style: TextStyle(
                    fontSize: 14,
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

  Widget _buildContent(DocumentsState documentsState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmployeeInfo(),
          const SizedBox(height: 24),
          _buildExitDetails(),
          const SizedBox(height: 24),
          _buildExitChecklist(),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employee Information',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Name', widget.employee.name),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem('Employee Code', widget.employee.employeeId),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem('Department', widget.employee.department),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoItem('Role', widget.employee.designation),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildExitDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exit Details',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Resignation Date',
                  _resignationDate,
                      (date) => setState(() => _resignationDate = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  'Last Working Day',
                  _lastWorkingDay,
                      (date) => setState(() => _lastWorkingDay = date),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(date, onChanged),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy').format(date)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExitChecklist() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exit Formalities Checklist',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ..._checklist.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildChecklistItem(index, item);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0);
  }

  Widget _buildChecklistItem(int index, ExitChecklistItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.status == ChecklistStatus.completed
              ? Colors.green.shade200
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: item.status == ChecklistStatus.completed
                      ? Colors.green
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.status == ChecklistStatus.completed
                      ? Icons.check
                      : Icons.circle_outlined,
                  size: 16,
                  color: item.status == ChecklistStatus.completed
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${item.particular}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Iconsax.user,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.responsiblePerson,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<ChecklistStatus>(
                value: item.status,
                onChanged: (ChecklistStatus? newStatus) {
                  if (newStatus != null) {
                    setState(() {
                      _checklist[index] = ExitChecklistItem(
                        particular: item.particular,
                        status: newStatus,
                        responsiblePerson: item.responsiblePerson,
                        details: item.details,
                      );
                    });
                  }
                },
                items: ChecklistStatus.values.map((status) {
                  return DropdownMenuItem<ChecklistStatus>(
                    value: status,
                    child: Text(_getStatusText(status)),
                  );
                }).toList(),
                underline: Container(),
              ),
            ],
          ),
          if (item.details != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.details!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(ChecklistStatus status) {
    switch (status) {
      case ChecklistStatus.completed:
        return 'Completed';
      case ChecklistStatus.pending:
        return 'Pending';
      case ChecklistStatus.notApplicable:
        return 'N/A';
    }
  }

  Widget _buildActions(DocumentsState documentsState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: documentsState.isLoading
                ? null
                : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: documentsState.isLoading ? null : _saveChecklist,
            icon: const Icon(Iconsax.tick_square),
            label: const Text('Save Progress'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: documentsState.isLoading || !_isChecklistComplete()
                ? null
                : _generateCertificate,
            icon: documentsState.isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Iconsax.document_download),
            label: Text(documentsState.isLoading ? 'Generating...' : 'Generate PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  bool _isChecklistComplete() {
    return _checklist.every((item) =>
    item.status == ChecklistStatus.completed ||
        item.status == ChecklistStatus.notApplicable);
  }

  Future<void> _selectDate(DateTime currentDate, Function(DateTime) onChanged) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != currentDate) {
      onChanged(picked);
    }
  }

  Future<void> _saveChecklist() async {
    final success = await ref.read(documentsProvider.notifier)
        .updateExitChecklist(widget.employee.id, _checklist);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exit checklist saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save checklist'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateCertificate() async {
    if (!_formKey.currentState!.validate()) return;

    final certificate = NoDuesCertificate(
      employeeName: widget.employee.name,
      employeeCode: widget.employee.employeeId,
      role: widget.employee.designation,
      resignationDate: _resignationDate,
      lastWorkingDay: _lastWorkingDay,
      certificateDate: DateTime.now(),
      checklist: _checklist,
    );

    try {
      // Generate and show PDF
      await PdfGeneratorService.printNoDuesCertificate(certificate);

      // Save document record
      await ref.read(documentsProvider.notifier).saveGeneratedDocument({
        'employee_id': widget.employee.id,
        'document_type': 'no_dues_certificate',
        'document_data': certificate.toJson(),
        'generated_at': DateTime.now().toIso8601String(),
      });

      // Mark employee exit as complete
      await ref.read(documentsProvider.notifier)
          .completeEmployeeExit(widget.employee.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No dues certificate generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating certificate: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}