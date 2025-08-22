// lib/features/reminders/presentation/widgets/add_reminder_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/reminder.dart';

class AddReminderDialog extends StatefulWidget {
  final Function(Reminder) onReminderAdded;
  final Reminder? reminder; // For editing existing reminders

  const AddReminderDialog({
    super.key,
    required this.onReminderAdded,
    this.reminder,
  });

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _relatedIdController = TextEditingController();

  ReminderType _selectedType = ReminderType.custom;
  String? _relatedTable;
  DateTime _reminderDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _reminderTime = TimeOfDay.now();
  bool _isRecurring = false;
  String _recurringInterval = 'monthly';

  late AnimationController _animationController;

  final List<String> _recurringOptions = [
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'yearly'
  ];

  final List<String> _relatedTables = [
    'subscriptions',
    'assets',
    'employees'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Pre-fill form if editing existing reminder
    if (widget.reminder != null) {
      _populateFormFromReminder(widget.reminder!);
    }

    _animationController.forward();
  }

  void _populateFormFromReminder(Reminder reminder) {
    _titleController.text = reminder.title;
    _descriptionController.text = reminder.description;
    _relatedIdController.text = reminder.relatedId ?? '';

    _selectedType = reminder.type;
    _relatedTable = reminder.relatedTable;
    _reminderDate = DateTime(reminder.reminderDate.year, reminder.reminderDate.month, reminder.reminderDate.day);
    _reminderTime = TimeOfDay.fromDateTime(reminder.reminderDate);
    _isRecurring = reminder.isRecurring;
    _recurringInterval = reminder.recurringInterval ?? 'monthly';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _relatedIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.reminder != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 600,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isEditing),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildFormFields(),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(isEditing),
            ],
          ),
        ),
      )
          .animate(controller: _animationController)
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
          .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isEditing ? Iconsax.edit : Iconsax.notification,
            color: const Color(0xFF6366F1),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Reminder' : 'Add New Reminder',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                isEditing ? 'Update reminder details' : 'Create a new reminder notification',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Basic Information Section
        _buildSectionHeader('Basic Information'),
        const SizedBox(height: 16),

        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title *',
            prefixIcon: Icon(Iconsax.notification),
            hintText: 'Enter reminder title',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter reminder title';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideX(begin: -0.3, end: 0),

        const SizedBox(height: 16),

        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description *',
            prefixIcon: Icon(Iconsax.note),
            hintText: 'Enter reminder description',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter reminder description';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .slideX(begin: -0.3, end: 0),

        const SizedBox(height: 16),

        DropdownButtonFormField<ReminderType>(
          value: _selectedType,
          decoration: const InputDecoration(
            labelText: 'Type *',
            prefixIcon: Icon(Iconsax.category),
          ),
          items: ReminderType.values.map((type) {
            String displayName;
            switch (type) {
              case ReminderType.subscriptionExpiry:
                displayName = 'Subscription Expiry';
                break;
              case ReminderType.assetMaintenance:
                displayName = 'Asset Maintenance';
                break;
              case ReminderType.licenseRenewal:
                displayName = 'License Renewal';
                break;
              case ReminderType.custom:
                displayName = 'Custom';
                break;
            }
            return DropdownMenuItem(
              value: type,
              child: Text(displayName),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
            });
          },
        )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideX(begin: -0.3, end: 0),

        const SizedBox(height: 32),

        // Date & Time Section
        _buildSectionHeader('Date & Time'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Reminder Date *',
                    prefixIcon: Icon(Iconsax.calendar),
                  ),
                  child: Text(
                    '${_reminderDate.day}/${_reminderDate.month}/${_reminderDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Reminder Time *',
                    prefixIcon: Icon(Iconsax.clock),
                  ),
                  child: Text(
                    _reminderTime.format(context),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Related Information Section
        _buildSectionHeader('Related Information (Optional)'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _relatedTable,
                decoration: const InputDecoration(
                  labelText: 'Related To',
                  prefixIcon: Icon(Iconsax.link),
                ),
                items: _relatedTables.map((table) {
                  return DropdownMenuItem(
                    value: table,
                    child: Text(table.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _relatedTable = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _relatedIdController,
                decoration: const InputDecoration(
                  labelText: 'Related ID',
                  prefixIcon: Icon(Iconsax.code),
                  hintText: 'Enter related item ID',
                ),
                enabled: _relatedTable != null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Recurring Section
        _buildSectionHeader('Recurring Options'),
        const SizedBox(height: 16),

        CheckboxListTile(
          title: const Text('Make this reminder recurring'),
          subtitle: const Text('Automatically create new reminders'),
          value: _isRecurring,
          onChanged: (bool? value) {
            setState(() {
              _isRecurring = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        if (_isRecurring) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _recurringInterval,
            decoration: const InputDecoration(
              labelText: 'Recurring Interval',
              prefixIcon: Icon(Iconsax.refresh),
            ),
            items: _recurringOptions.map((interval) {
              return DropdownMenuItem(
                value: interval,
                child: Text(interval.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _recurringInterval = value!;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveReminder,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(isEditing ? 'Update Reminder' : 'Add Reminder'),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _reminderDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _reminderDate) {
      setState(() {
        _reminderDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      final reminderDateTime = DateTime(
        _reminderDate.year,
        _reminderDate.month,
        _reminderDate.day,
        _reminderTime.hour,
        _reminderTime.minute,
      );

      // Validate that reminder date is in the future
      if (reminderDateTime.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder date must be in the future'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final reminder = Reminder(
        id: widget.reminder?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        relatedId: _relatedIdController.text.trim().isEmpty ? null : _relatedIdController.text.trim(),
        relatedTable: _relatedTable,
        reminderDate: reminderDateTime,
        isRecurring: _isRecurring,
        recurringInterval: _isRecurring ? _recurringInterval : null,
        status: widget.reminder?.status ?? ReminderStatus.pending,
        createdAt: widget.reminder?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onReminderAdded(reminder);
      Navigator.of(context).pop();
    }
  }
}