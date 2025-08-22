// lib/core/providers/employees_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../features/employees/models/employee.dart';

final employeesProvider = StateNotifierProvider<EmployeesNotifier, EmployeesState>((ref) {
  return EmployeesNotifier();
});

class EmployeesNotifier extends StateNotifier<EmployeesState> {
  EmployeesNotifier() : super(EmployeesState.initial());

  Future<void> loadEmployees({String search = '', int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final response = await ApiService.getEmployees(
      page: page,
      limit: 20,
      search: search,
    );

    if (response.success && response.data != null) {
      final employees = response.data!
          .map((json) => Employee.fromJson(json))
          .toList();

      state = state.copyWith(
        isLoading: false,
        employees: page == 1 ? employees : [...state.employees, ...employees],
        hasMore: employees.length == 20,
        currentPage: page,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load employees',
      );
    }
  }

  Future<bool> createEmployee(Map<String, dynamic> employeeData) async {
    final response = await ApiService.createEmployee(employeeData);

    if (response.success) {
      // Reload employees to get the updated list
      await loadEmployees();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to create employee',
      );
      return false;
    }
  }

  Future<bool> updateEmployee(String id, Map<String, dynamic> employeeData) async {
    final response = await ApiService.updateEmployee(id, employeeData);

    if (response.success) {
      await loadEmployees();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to update employee',
      );
      return false;
    }
  }

  Future<bool> deleteEmployee(String id) async {
    final response = await ApiService.deleteEmployee(id);

    if (response.success) {
      // Remove from local state immediately for better UX
      final updatedEmployees = state.employees.where((emp) => emp.id != id).toList();
      state = state.copyWith(employees: updatedEmployees);
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to delete employee',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setFilter(String search) {
    loadEmployees(search: search);
  }
}

class EmployeesState {
  final bool isLoading;
  final List<Employee> employees;
  final String? error;
  final bool hasMore;
  final int currentPage;

  EmployeesState({
    required this.isLoading,
    required this.employees,
    this.error,
    required this.hasMore,
    required this.currentPage,
  });

  factory EmployeesState.initial() {
    return EmployeesState(
      isLoading: false,
      employees: [],
      hasMore: true,
      currentPage: 1,
    );
  }

  EmployeesState copyWith({
    bool? isLoading,
    List<Employee>? employees,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return EmployeesState(
      isLoading: isLoading ?? this.isLoading,
      employees: employees ?? this.employees,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}