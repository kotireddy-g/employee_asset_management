class NoDuesCertificate {
  final String employeeName;
  final String employeeCode;
  final String role;
  final DateTime resignationDate;
  final DateTime lastWorkingDay;
  final DateTime certificateDate;
  final List<ExitChecklistItem> checklist;

  NoDuesCertificate({
    required this.employeeName,
    required this.employeeCode,
    required this.role,
    required this.resignationDate,
    required this.lastWorkingDay,
    required this.certificateDate,
    required this.checklist,
  });

  factory NoDuesCertificate.fromJson(Map<String, dynamic> json) {
    return NoDuesCertificate(
      employeeName: json['employee_name'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      role: json['role'] ?? '',
      resignationDate: DateTime.parse(json['resignation_date']),
      lastWorkingDay: DateTime.parse(json['last_working_day']),
      certificateDate: DateTime.parse(json['certificate_date']),
      checklist: (json['checklist'] as List<dynamic>?)
          ?.map((item) => ExitChecklistItem.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'role': role,
      'resignation_date': resignationDate.toIso8601String().split('T')[0],
      'last_working_day': lastWorkingDay.toIso8601String().split('T')[0],
      'certificate_date': certificateDate.toIso8601String().split('T')[0],
      'checklist': checklist.map((item) => item.toJson()).toList(),
    };
  }
}

class ExitChecklistItem {
  final String particular;
  final ChecklistStatus status;
  final String responsiblePerson;
  final String? details;

  ExitChecklistItem({
    required this.particular,
    required this.status,
    required this.responsiblePerson,
    this.details,
  });

  factory ExitChecklistItem.fromJson(Map<String, dynamic> json) {
    return ExitChecklistItem(
      particular: json['particular'] ?? '',
      status: _parseStatus(json['status']),
      responsiblePerson: json['responsible_person'] ?? '',
      details: json['details'],
    );
  }

  static ChecklistStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return ChecklistStatus.completed;
      case 'pending':
        return ChecklistStatus.pending;
      case 'not_applicable':
        return ChecklistStatus.notApplicable;
      default:
        return ChecklistStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'particular': particular,
      'status': status.toString().split('.').last,
      'responsible_person': responsiblePerson,
      'details': details,
    };
  }
}

enum ChecklistStatus { completed, pending, notApplicable }