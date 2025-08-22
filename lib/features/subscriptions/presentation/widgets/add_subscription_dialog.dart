// lib/features/subscriptions/presentation/widgets/add_subscription_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/subscription.dart';

class AddSubscriptionDialog extends StatefulWidget {
  final Function(Subscription) onSubscriptionAdded;
  final Subscription? subscription; // Add this for editing

  const AddSubscriptionDialog({
    super.key,
    required this.onSubscriptionAdded,
    this.subscription, // Add this
  });

  @override
  State<AddSubscriptionDialog> createState() => _AddSubscriptionDialogState();
}

class _AddSubscriptionDialogState extends State<AddSubscriptionDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _providerController = TextEditingController();
  final _costController = TextEditingController();
  final _maxUsersController = TextEditingController();
  final _descriptionController = TextEditingController();

  SubscriptionType _selectedType = SubscriptionType.software;
  BillingCycle _selectedBilling = BillingCycle.monthly;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  bool _autoRenewal = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Pre-fill form if editing existing subscription
    if (widget.subscription != null) {
      _populateFormFromSubscription(widget.subscription!);
    }

    _animationController.forward();
  }

  void _populateFormFromSubscription(Subscription subscription) {
    _nameController.text = subscription.name;
    _providerController.text = subscription.provider;
    _costController.text = subscription.cost.toString();
    _maxUsersController.text = subscription.maxUsers.toString();
    _descriptionController.text = subscription.description ?? '';

    _selectedType = subscription.type;
    _selectedBilling = subscription.billingCycle;
    _startDate = subscription.startDate;
    _endDate = subscription.endDate;
    _autoRenewal = subscription.autoRenewal;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _providerController.dispose();
    _costController.dispose();
    _maxUsersController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subscription != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        height: MediaQuery.of(context).size.height * 0.85,
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
            isEditing ? Iconsax.edit : Icons.subscriptions,
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
                isEditing ? 'Edit Subscription' : 'Add New Subscription',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                isEditing ? 'Update subscription details' : 'Fill in the subscription details',
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

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subscription Name *',
                  prefixIcon: Icon(Icons.subscriptions),
                  hintText: 'e.g., Adobe Creative Suite',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter subscription name';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _providerController,
                decoration: const InputDecoration(
                  labelText: 'Provider *',
                  prefixIcon: Icon(Iconsax.building),
                  hintText: 'e.g., Adobe, Microsoft',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter provider';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideX(begin: 0.3, end: 0),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<SubscriptionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  prefixIcon: Icon(Iconsax.category),
                ),
                items: SubscriptionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
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
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<BillingCycle>(
                value: _selectedBilling,
                decoration: const InputDecoration(
                  labelText: 'Billing Cycle *',
                  prefixIcon: Icon(Iconsax.refresh),
                ),
                items: BillingCycle.values.map((cycle) {
                  String displayName;
                  switch (cycle) {
                    case BillingCycle.monthly:
                      displayName = 'Monthly';
                      break;
                    case BillingCycle.quarterly:
                      displayName = 'Quarterly';
                      break;
                    case BillingCycle.yearly:
                      displayName = 'Yearly';
                      break;
                    case BillingCycle.oneTime:
                      displayName = 'One Time';
                      break;
                  }
                  return DropdownMenuItem(
                    value: cycle,
                    child: Text(displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBilling = value!;
                  });
                },
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideX(begin: 0.3, end: 0),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Pricing & Users Section
        _buildSectionHeader('Pricing & Users'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _costController,
                decoration: const InputDecoration(
                  labelText: 'Cost *',
                  prefixIcon: Icon(Iconsax.dollar_circle),
                  prefixText: '\$ ',
                  hintText: '0.00',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid cost';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _maxUsersController,
                decoration: const InputDecoration(
                  labelText: 'Max Users *',
                  prefixIcon: Icon(Iconsax.people),
                  hintText: 'e.g., 10',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter max users';
                  }
                  final intValue = int.tryParse(value);
                  if (intValue == null || intValue <= 0) {
                    return 'Please enter valid number greater than 0';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 400.ms)
                  .slideX(begin: 0.3, end: 0),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Subscription Period Section
        _buildSectionHeader('Subscription Period'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectStartDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start Date *',
                    prefixIcon: Icon(Iconsax.calendar),
                  ),
                  child: Text(
                    '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectEndDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'End Date *',
                    prefixIcon: Icon(Iconsax.calendar),
                  ),
                  child: Text(
                    '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        CheckboxListTile(
          title: const Text('Auto Renewal'),
          subtitle: const Text('Automatically renew this subscription'),
          value: _autoRenewal,
          onChanged: (bool? value) {
            setState(() {
              _autoRenewal = value ?? false;
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        const SizedBox(height: 32),

        // Additional Information Section
        _buildSectionHeader('Additional Information'),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            prefixIcon: Icon(Iconsax.note),
            hintText: 'Any additional notes or description',
          ),
          maxLines: 3,
        ),
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
          onPressed: _saveSubscription,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(isEditing ? 'Update Subscription' : 'Add Subscription'),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 800.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, adjust it
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 365));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveSubscription() {
    if (_formKey.currentState!.validate()) {
      // Validate that end date is after start date
      if (_endDate.isBefore(_startDate) || _endDate.isAtSameMomentAs(_startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('End date must be after start date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final subscription = Subscription(
        id: widget.subscription?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        provider: _providerController.text.trim(),
        type: _selectedType,
        cost: double.parse(_costController.text.trim()),
        billingCycle: _selectedBilling,
        startDate: _startDate,
        endDate: _endDate,
        autoRenewal: _autoRenewal,
        status: widget.subscription?.status ?? SubscriptionStatus.active,
        maxUsers: int.parse(_maxUsersController.text.trim()),
        currentUsers: widget.subscription?.currentUsers ?? 0,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: widget.subscription?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubscriptionAdded(subscription);
      Navigator.of(context).pop();
    }
  }
}