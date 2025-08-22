// lib/features/employees/presentation/widgets/add_employee_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/employee.dart';
import '../screens/employees_screen.dart';

class AddEmployeeDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onEmployeeAdded;
  final Employee? employee; // Add this for editing

  const AddEmployeeDialog({
    super.key,
    required this.onEmployeeAdded,
    this.employee, // Add this
  });

  @override
  State<AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<AddEmployeeDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _positionController = TextEditingController();

  String _selectedDepartment = 'Engineering';
  late AnimationController _animationController;

  final List<String> _departments = [
    'Engineering',
    'Design',
    'Marketing',
    'HR',
    'Sales',
    'Operations'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _employeeIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500,
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildFormFields(),
              const SizedBox(height: 24),
              _buildActionButtons(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Iconsax.user_add,
            color: Color(0xFF6366F1),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Employee',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Fill in the details below',
                style: TextStyle(
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
        TextFormField(
          controller: _employeeIdController,
          decoration: const InputDecoration(
            labelText: 'Emp ID',
            prefixIcon: Icon(Iconsax.user),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter EMPID';
            }
            return null;
          },
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .slideX(begin: -0.3, end: 0),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Iconsax.user),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter full name';
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
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Iconsax.sms),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter valid email';
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
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Iconsax.call),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  prefixIcon: Icon(Iconsax.briefcase),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter position';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideX(begin: 0.3, end: 0),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedDepartment,
          decoration: const InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Iconsax.building),
          ),
          items: _departments.map((String department) {
            return DropdownMenuItem<String>(
              value: department,
              child: Text(department),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDepartment = newValue!;
            });
          },
        )
            .animate()
            .fadeIn(delay: 600.ms, duration: 400.ms)
            .slideY(begin: 0.3, end: 0),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveEmployee,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Add Employee'),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  void _saveEmployee() {
    if (_formKey.currentState!.validate()) {
      final employee = Employee(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        employeeId: _employeeIdController.text,
        firstName: _nameController.text.split(' ').first,
        lastName: _nameController.text.split(' ').skip(1).join(' '),
        email: _emailController.text,
        department: _selectedDepartment,
        designation: _positionController.text,
        joiningDate: DateTime.now(),
        phone: _phoneController.text,
        status: EmployeeStatus.active,
      );

      widget.onEmployeeAdded(employee.toJson());
      Navigator.of(context).pop();
    }
  }
}