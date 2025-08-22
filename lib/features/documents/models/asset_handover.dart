// lib/features/documents/models/asset_handover.dart
import 'package:equatable/equatable.dart';

class AssetHandover extends Equatable {
  final String? id;
  final String employeeName;
  final String employeeCode;
  final String role;
  final DateTime handoverDate;
  final String handoverBy;
  final List<HandoverAsset> assets;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? notes;
  final HandoverStatus status;

  const AssetHandover({
    this.id,
    required this.employeeName,
    required this.employeeCode,
    required this.role,
    required this.handoverDate,
    required this.handoverBy,
    required this.assets,
    this.createdAt,
    this.updatedAt,
    this.notes,
    this.status = HandoverStatus.pending,
  });

  factory AssetHandover.fromJson(Map<String, dynamic> json) {
    return AssetHandover(
      id: json['id']?.toString() ?? '',
      employeeName: json['employee_name'] ?? '',
      employeeCode: json['employee_code'] ?? '',
      role: json['role'] ?? '',
      handoverDate: json['handover_date'] != null
          ? DateTime.parse(json['handover_date'])
          : DateTime.now(),
      handoverBy: json['handover_by'] ?? '',
      assets: (json['assets'] as List<dynamic>?)
          ?.map((asset) => HandoverAsset.fromJson(asset as Map<String, dynamic>))
          .toList() ?? [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      notes: json['notes'],
      status: _parseHandoverStatus(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_name': employeeName,
      'employee_code': employeeCode,
      'role': role,
      'handover_date': handoverDate.toIso8601String().split('T')[0],
      'handover_by': handoverBy,
      'assets': assets.map((asset) => asset.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'notes': notes,
      'status': status.toString().split('.').last,
    };
  }

  static HandoverStatus _parseHandoverStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return HandoverStatus.completed;
      case 'pending':
        return HandoverStatus.pending;
      case 'cancelled':
        return HandoverStatus.cancelled;
      default:
        return HandoverStatus.pending;
    }
  }

  AssetHandover copyWith({
    String? id,
    String? employeeName,
    String? employeeCode,
    String? role,
    DateTime? handoverDate,
    String? handoverBy,
    List<HandoverAsset>? assets,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    HandoverStatus? status,
  }) {
    return AssetHandover(
      id: id ?? this.id,
      employeeName: employeeName ?? this.employeeName,
      employeeCode: employeeCode ?? this.employeeCode,
      role: role ?? this.role,
      handoverDate: handoverDate ?? this.handoverDate,
      handoverBy: handoverBy ?? this.handoverBy,
      assets: assets ?? this.assets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeName,
    employeeCode,
    role,
    handoverDate,
    handoverBy,
    assets,
    createdAt,
    updatedAt,
    notes,
    status,
  ];

  @override
  String toString() {
    return 'AssetHandover(id: $id, employeeName: $employeeName, employeeCode: $employeeCode, '
        'role: $role, handoverDate: $handoverDate, handoverBy: $handoverBy, '
        'assets: ${assets.length}, status: $status)';
  }
}

class HandoverAsset extends Equatable {
  final String? id;
  final String particulars;
  final String assetCode;
  final String serialNo;
  final String condition;
  final String? brand;
  final String? model;
  final String? assetType;
  final String? ram;
  final String? storage;
  final String? processor;
  final String? operatingSystem;
  final String? macAddress;
  final double? purchaseCost;
  final DateTime? billDate;
  final String? additionalNotes;

  const HandoverAsset({
    this.id,
    required this.particulars,
    required this.assetCode,
    required this.serialNo,
    required this.condition,
    this.brand,
    this.model,
    this.assetType,
    this.ram,
    this.storage,
    this.processor,
    this.operatingSystem,
    this.macAddress,
    this.purchaseCost,
    this.billDate,
    this.additionalNotes,
  });

  factory HandoverAsset.fromJson(Map<String, dynamic> json) {
    return HandoverAsset(
      id: json['id']?.toString() ?? '',
      particulars: json['particulars'] ?? _generateParticulars(json),
      assetCode: json['asset_code'] ?? json['device_id'] ?? '',
      serialNo: json['serial_no'] ?? '',
      condition: json['condition'] ?? json['working_status'] ?? 'Working',
      brand: json['brand'],
      model: json['model'],
      assetType: json['asset_type'],
      ram: json['ram'],
      storage: json['storage'],
      processor: json['processor'],
      operatingSystem: json['operating_system'],
      macAddress: json['mac_address'],
      purchaseCost: json['purchase_cost'] != null
          ? double.tryParse(json['purchase_cost'].toString())
          : null,
      billDate: json['bill_date'] != null
          ? DateTime.parse(json['bill_date'])
          : null,
      additionalNotes: json['additional_notes'] ?? json['other_details'],
    );
  }

  static String _generateParticulars(Map<String, dynamic> json) {
    final type = json['asset_type'] ?? 'Asset';
    final brand = json['brand'] ?? '';
    final model = json['model'] ?? '';

    if (brand.isNotEmpty && model.isNotEmpty) {
      return '$type - $brand $model';
    } else if (brand.isNotEmpty) {
      return '$type - $brand';
    } else {
      return type;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'particulars': particulars,
      'asset_code': assetCode,
      'serial_no': serialNo,
      'condition': condition,
      'brand': brand,
      'model': model,
      'asset_type': assetType,
      'ram': ram,
      'storage': storage,
      'processor': processor,
      'operating_system': operatingSystem,
      'mac_address': macAddress,
      'purchase_cost': purchaseCost,
      'bill_date': billDate?.toIso8601String().split('T')[0],
      'additional_notes': additionalNotes,
    };
  }

  HandoverAsset copyWith({
    String? id,
    String? particulars,
    String? assetCode,
    String? serialNo,
    String? condition,
    String? brand,
    String? model,
    String? assetType,
    String? ram,
    String? storage,
    String? processor,
    String? operatingSystem,
    String? macAddress,
    double? purchaseCost,
    DateTime? billDate,
    String? additionalNotes,
  }) {
    return HandoverAsset(
      id: id ?? this.id,
      particulars: particulars ?? this.particulars,
      assetCode: assetCode ?? this.assetCode,
      serialNo: serialNo ?? this.serialNo,
      condition: condition ?? this.condition,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      assetType: assetType ?? this.assetType,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      processor: processor ?? this.processor,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      macAddress: macAddress ?? this.macAddress,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      billDate: billDate ?? this.billDate,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  String get fullDescription {
    List<String> details = [];

    if (brand != null && brand!.isNotEmpty) details.add('Brand: $brand');
    if (model != null && model!.isNotEmpty) details.add('Model: $model');
    if (ram != null && ram!.isNotEmpty) details.add('RAM: $ram');
    if (storage != null && storage!.isNotEmpty) details.add('Storage: $storage');
    if (processor != null && processor!.isNotEmpty) details.add('Processor: $processor');
    if (operatingSystem != null && operatingSystem!.isNotEmpty) details.add('OS: $operatingSystem');

    return details.join(', ');
  }

  @override
  List<Object?> get props => [
    id,
    particulars,
    assetCode,
    serialNo,
    condition,
    brand,
    model,
    assetType,
    ram,
    storage,
    processor,
    operatingSystem,
    macAddress,
    purchaseCost,
    billDate,
    additionalNotes,
  ];

  @override
  String toString() {
    return 'HandoverAsset(id: $id, particulars: $particulars, assetCode: $assetCode, '
        'serialNo: $serialNo, condition: $condition)';
  }
}

enum HandoverStatus {
  pending,
  completed,
  cancelled,
}

extension HandoverStatusExtension on HandoverStatus {
  String get displayName {
    switch (this) {
      case HandoverStatus.pending:
        return 'Pending';
      case HandoverStatus.completed:
        return 'Completed';
      case HandoverStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get description {
    switch (this) {
      case HandoverStatus.pending:
        return 'Asset handover is pending completion';
      case HandoverStatus.completed:
        return 'Asset handover has been completed';
      case HandoverStatus.cancelled:
        return 'Asset handover was cancelled';
    }
  }
}