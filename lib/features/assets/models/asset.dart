import 'package:flutter/material.dart';

class Asset {
  final String id;
  final String deviceId;
  final AssetType type;
  final String brand;
  final String model;
  final String serialNo;
  final AssetStatus status;
  final String? assignedTo;
  final DateTime? assignedDate;

  // Additional fields from database
  final String? ram;
  final String? storage;
  final String? processor;
  final String? operatingSystem;
  final String? macAddress;
  final bool crowdstrikeInstalled;
  final bool vpnConfigured;
  final String? workingStatus;
  final DateTime? billDate;
  final double? purchaseCost;
  final String? password;
  final String? otherDetails;
  final String? issueNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  Asset({
    required this.id,
    required this.deviceId,
    required this.type,
    required this.brand,
    required this.model,
    required this.serialNo,
    required this.status,
    this.assignedTo,
    this.assignedDate,
    this.ram,
    this.storage,
    this.processor,
    this.operatingSystem,
    this.macAddress,
    this.crowdstrikeInstalled = false,
    this.vpnConfigured = false,
    this.workingStatus,
    this.billDate,
    this.purchaseCost,
    this.password,
    this.otherDetails,
    this.issueNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'].toString(),
      deviceId: json['device_id'] ?? '',
      type: _parseAssetType(json['asset_type']),
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      serialNo: json['serial_no'] ?? '',
      status: _parseAssetStatus(json['status']),
      assignedTo: json['assigned_to'],
      assignedDate: json['assigned_date'] != null
          ? DateTime.parse(json['assigned_date'])
          : null,
      ram: json['ram'],
      storage: json['storage'],
      processor: json['processor'],
      operatingSystem: json['operating_system'],
      macAddress: json['mac_address'],
      crowdstrikeInstalled: json['crowdstrike_installed'] == 1 || json['crowdstrike_installed'] == true,
      vpnConfigured: json['vpn_configured'] == 1 || json['vpn_configured'] == true,
      workingStatus: json['working_status'],
      billDate: json['bill_date'] != null
          ? DateTime.parse(json['bill_date'])
          : null,
      purchaseCost: json['purchase_cost'] != null
          ? double.tryParse(json['purchase_cost'].toString())
          : null,
      password: json['password'],
      otherDetails: json['other_details'],
      issueNote: json['issue_note'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'asset_type': type.toString().split('.').last,
      'brand': brand,
      'model': model,
      'serial_no': serialNo,
      'status': status.toString().split('.').last,
      'assigned_to': assignedTo,
      'assigned_date': assignedDate?.toIso8601String(),
      'ram': ram,
      'storage': storage,
      'processor': processor,
      'operating_system': operatingSystem,
      'mac_address': macAddress,
      'crowdstrike_installed': crowdstrikeInstalled,
      'vpn_configured': vpnConfigured,
      'working_status': workingStatus,
      'bill_date': billDate?.toIso8601String(),
      'purchase_cost': purchaseCost,
      'password': password,
      'other_details': otherDetails,
      'issue_note': issueNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Asset copyWith({
    String? id,
    String? deviceId,
    AssetType? type,
    String? brand,
    String? model,
    String? serialNo,
    AssetStatus? status,
    String? assignedTo,
    DateTime? assignedDate,
    String? ram,
    String? storage,
    String? processor,
    String? operatingSystem,
    String? macAddress,
    bool? crowdstrikeInstalled,
    bool? vpnConfigured,
    String? workingStatus,
    DateTime? billDate,
    double? purchaseCost,
    String? password,
    String? otherDetails,
    String? issueNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNo: serialNo ?? this.serialNo,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedDate: assignedDate ?? this.assignedDate,
      ram: ram ?? this.ram,
      storage: storage ?? this.storage,
      processor: processor ?? this.processor,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      macAddress: macAddress ?? this.macAddress,
      crowdstrikeInstalled: crowdstrikeInstalled ?? this.crowdstrikeInstalled,
      vpnConfigured: vpnConfigured ?? this.vpnConfigured,
      workingStatus: workingStatus ?? this.workingStatus,
      billDate: billDate ?? this.billDate,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      password: password ?? this.password,
      otherDetails: otherDetails ?? this.otherDetails,
      issueNote: issueNote ?? this.issueNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static AssetType _parseAssetType(String? type) {
    if (type == null) return AssetType.other;
    switch (type.toLowerCase()) {
      case 'laptop':
        return AssetType.laptop;
      case 'desktop':
        return AssetType.desktop;
      case 'mobile':
        return AssetType.mobile;
      case 'tablet':
        return AssetType.tablet;
      default:
        return AssetType.other;
    }
  }

  static AssetStatus _parseAssetStatus(String? status) {
    if (status == null) return AssetStatus.available;
    switch (status.toLowerCase()) {
      case 'available':
        return AssetStatus.available;
      case 'assigned':
        return AssetStatus.assigned;
      case 'maintenance':
        return AssetStatus.maintenance;
      case 'disposed':
        return AssetStatus.disposed;
      default:
        return AssetStatus.available;
    }
  }

  // Helper methods
  String get statusDisplayName {
    switch (status) {
      case AssetStatus.available:
        return 'Available';
      case AssetStatus.assigned:
        return 'Assigned';
      case AssetStatus.maintenance:
        return 'Maintenance';
      case AssetStatus.disposed:
        return 'Disposed';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case AssetType.laptop:
        return 'Laptop';
      case AssetType.desktop:
        return 'Desktop';
      case AssetType.mobile:
        return 'Mobile';
      case AssetType.tablet:
        return 'Tablet';
      case AssetType.other:
        return 'Other';
    }
  }

  Color get statusColor {
    switch (status) {
      case AssetStatus.available:
        return Colors.green;
      case AssetStatus.assigned:
        return Colors.blue;
      case AssetStatus.maintenance:
        return Colors.orange;
      case AssetStatus.disposed:
        return Colors.red;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case AssetType.laptop:
        return Icons.laptop;
      case AssetType.desktop:
        return Icons.computer;
      case AssetType.mobile:
        return Icons.phone_android;
      case AssetType.tablet:
        return Icons.tablet;
      case AssetType.other:
        return Icons.devices_other;
    }
  }

  bool get isAssigned => status == AssetStatus.assigned;
  bool get isAvailable => status == AssetStatus.available;
  bool get isInMaintenance => status == AssetStatus.maintenance;
  bool get isDisposed => status == AssetStatus.disposed;

  String get fullDisplayName => '$brand $model ($deviceId)';
}

enum AssetType {
  laptop,
  desktop,
  mobile,
  tablet,
  other
}

enum AssetStatus {
  available,
  assigned,
  maintenance,
  disposed
}