class Employee {
  final String id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String department;
  final String designation;
  final DateTime joiningDate;
  final EmployeeStatus status;

  Employee({
    required this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    required this.joiningDate,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'].toString(),
      employeeId: json['employee_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      joiningDate: DateTime.tryParse(json['joining_date'] ?? '') ?? DateTime.now(),
      status: _parseStatus(json['status']),
    );
  }

  static EmployeeStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return EmployeeStatus.active;
      case 'inactive':
        return EmployeeStatus.inactive;
      case 'terminated':
        return EmployeeStatus.terminated;
      default:
        return EmployeeStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'department': department,
      'designation': designation,
      'joining_date': joiningDate.toIso8601String().split('T')[0],
      'status': status.toString().split('.').last,
    };
  }

  String get name => '$firstName $lastName';
  String get position => designation; // For backward compatibility
  DateTime get joinDate => joiningDate; // For backward compatibility
  String? get avatar => null; // For backward compatibility
}

enum EmployeeStatus { active, inactive, terminated }