import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/providers/employees_provider.dart';
import '../../models/employee.dart';
import '../widgets/employee_card.dart';
import '../widgets/add_employee_dialog.dart';
import '../../../../shared/presentation/widgets/search_filter_bar.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = 'All';
  String _currentSearch = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Load employees when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(employeesProvider.notifier).loadEmployees();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterEmployees() {
    final search = _searchController.text.trim();
    if (search != _currentSearch) {
      _currentSearch = search;
      ref.read(employeesProvider.notifier).setFilter(search);
    }
  }

  void _showAddEmployeeDialog() {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(
        onEmployeeAdded: (employeeData) async {
          final success = await ref.read(employeesProvider.notifier).createEmployee(employeeData);

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Employee "${employeeData['first_name']} ${employeeData['last_name']}" added successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employeesState = ref.watch(employeesProvider);

    // Show error if any
    ref.listen(employeesProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ref.read(employeesProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(employeesState),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(employeesProvider.notifier).loadEmployees(),
              child: employeesState.isLoading && employeesState.employees.isEmpty
                  ? _buildLoadingState()
                  : _buildEmployeesList(employeesState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(EmployeesState employeesState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Team Members',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),
                      if (employeesState.isLoading && employeesState.employees.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${employeesState.employees.length} employees found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showAddEmployeeDialog,
                icon: const Icon(Iconsax.user_add),
                label: const Text('Add Employee'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
          const SizedBox(height: 20),
          SearchFilterBar(
            searchController: _searchController,
            selectedFilter: _selectedDepartment,
            filterOptions: const ['All', 'Engineering', 'Design', 'Marketing', 'HR', 'IT'],
            onSearchChanged: (value) => _filterEmployees(),
            onFilterChanged: (value) {
              setState(() {
                _selectedDepartment = value;
                _filterEmployees();
              });
            },
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading employees...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeesList(EmployeesState employeesState) {
    if (employeesState.employees.isEmpty && !employeesState.isLoading) {
      return _buildEmptyState();
    }

    final filteredEmployees = _applyLocalFilters(employeesState.employees);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: filteredEmployees.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: 3,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: EmployeeCard(
                    employee: filteredEmployees[index],
                    onTap: () => _showEmployeeDetails(filteredEmployees[index]),
                    onEdit: () => _editEmployee(filteredEmployees[index]),
                    onDelete: () => _deleteEmployee(filteredEmployees[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.user_search,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No employees found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Add your first employee to get started',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddEmployeeDialog,
            icon: const Icon(Iconsax.user_add),
            label: const Text('Add First Employee'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  List<Employee> _applyLocalFilters(List<Employee> employees) {
    return employees.where((employee) {
      // Apply department filter
      if (_selectedDepartment != 'All' && employee.department != _selectedDepartment) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showEmployeeDetails(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee ID: ${employee.employeeId}'),
            Text('Email: ${employee.email}'),
            Text('Phone: ${employee.phone}'),
            Text('Department: ${employee.department}'),
            Text('Position: ${employee.designation}'),
            Text('Join Date: ${employee.joiningDate.day}/${employee.joiningDate.month}/${employee.joiningDate.year}'),
            Text('Status: ${employee.status.toString().split('.').last.toUpperCase()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editEmployee(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AddEmployeeDialog(
        employee: employee,
        onEmployeeAdded: (employeeData) async {
          final success = await ref.read(employeesProvider.notifier)
              .updateEmployee(employee.id, employeeData);

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Employee "${employee.name}" updated successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteEmployee(Employee employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await ref.read(employeesProvider.notifier)
                  .deleteEmployee(employee.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Employee "${employee.name}" deleted successfully!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}