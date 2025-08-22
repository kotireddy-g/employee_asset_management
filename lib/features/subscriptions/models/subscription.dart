import 'package:flutter/material.dart';

class Subscription {
  final String id;
  final String name;
  final String provider;
  final SubscriptionType type;
  final double cost;
  final BillingCycle billingCycle;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? renewalDate;
  final bool autoRenewal;
  final int maxUsers;
  final int currentUsers;
  final SubscriptionStatus status;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.name,
    required this.provider,
    required this.type,
    required this.cost,
    required this.billingCycle,
    required this.startDate,
    required this.endDate,
    this.renewalDate,
    this.autoRenewal = false,
    required this.maxUsers,
    required this.currentUsers,
    required this.status,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'].toString(),
      name: json['subscription_name'] ?? '',
      provider: json['provider'] ?? '',
      type: _parseSubscriptionType(json['subscription_type']),
      cost: double.tryParse(json['cost']?.toString() ?? '0') ?? 0.0,
      billingCycle: _parseBillingCycle(json['billing_cycle']),
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      renewalDate: json['renewal_date'] != null
          ? DateTime.parse(json['renewal_date'])
          : null,
      autoRenewal: json['auto_renewal'] == 1 || json['auto_renewal'] == true,
      maxUsers: int.tryParse(json['max_users']?.toString() ?? '0') ?? 0,
      currentUsers: int.tryParse(json['current_users']?.toString() ?? '0') ?? 0,
      status: _parseSubscriptionStatus(json['status']),
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscription_name': name,
      'provider': provider,
      'subscription_type': type.toString().split('.').last,
      'cost': cost,
      'billing_cycle': billingCycle.toString().split('.').last,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'renewal_date': renewalDate?.toIso8601String().split('T')[0],
      'auto_renewal': autoRenewal,
      'max_users': maxUsers,
      'current_users': currentUsers,
      'status': status.toString().split('.').last,
      'description': description,
    };
  }

  Subscription copyWith({
    String? id,
    String? name,
    String? provider,
    SubscriptionType? type,
    double? cost,
    BillingCycle? billingCycle,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? renewalDate,
    bool? autoRenewal,
    int? maxUsers,
    int? currentUsers,
    SubscriptionStatus? status,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      provider: provider ?? this.provider,
      type: type ?? this.type,
      cost: cost ?? this.cost,
      billingCycle: billingCycle ?? this.billingCycle,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      renewalDate: renewalDate ?? this.renewalDate,
      autoRenewal: autoRenewal ?? this.autoRenewal,
      maxUsers: maxUsers ?? this.maxUsers,
      currentUsers: currentUsers ?? this.currentUsers,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static SubscriptionType _parseSubscriptionType(String? type) {
    if (type == null) return SubscriptionType.software;
    switch (type.toLowerCase()) {
      case 'software':
        return SubscriptionType.software;
      case 'service':
        return SubscriptionType.service;
      case 'license':
        return SubscriptionType.license;
      default:
        return SubscriptionType.other;
    }
  }

  static BillingCycle _parseBillingCycle(String? cycle) {
    if (cycle == null) return BillingCycle.monthly;
    switch (cycle.toLowerCase()) {
      case 'monthly':
        return BillingCycle.monthly;
      case 'quarterly':
        return BillingCycle.quarterly;
      case 'yearly':
        return BillingCycle.yearly;
      case 'onetime':
        return BillingCycle.oneTime;
      default:
        return BillingCycle.monthly;
    }
  }

  static SubscriptionStatus _parseSubscriptionStatus(String? status) {
    if (status == null) return SubscriptionStatus.active;
    switch (status.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;
      case 'expiring':
        return SubscriptionStatus.expiring;
      case 'expired':
        return SubscriptionStatus.expired;
      case 'cancelled':
        return SubscriptionStatus.cancelled;
      default:
        return SubscriptionStatus.active;
    }
  }

  // Helper methods
  String get statusDisplayName {
    switch (status) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.expiring:
        return 'Expiring Soon';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case SubscriptionType.software:
        return 'Software';
      case SubscriptionType.service:
        return 'Service';
      case SubscriptionType.license:
        return 'License';
      case SubscriptionType.other:
        return 'Other';
    }
  }

  String get billingDisplayName {
    switch (billingCycle) {
      case BillingCycle.monthly:
        return 'Monthly';
      case BillingCycle.quarterly:
        return 'Quarterly';
      case BillingCycle.yearly:
        return 'Yearly';
      case BillingCycle.oneTime:
        return 'One Time';
    }
  }

  Color get statusColor {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.expiring:
        return Colors.orange;
      case SubscriptionStatus.expired:
        return Colors.red;
      case SubscriptionStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case SubscriptionType.software:
        return Icons.computer;
      case SubscriptionType.service:
        return Icons.cloud;
      case SubscriptionType.license:
        return Icons.verified;
      case SubscriptionType.other:
        return Icons.category;
    }
  }

  bool get isActive => status == SubscriptionStatus.active;
  bool get isExpiring => status == SubscriptionStatus.expiring;
  bool get isExpired => status == SubscriptionStatus.expired;
  bool get isCancelled => status == SubscriptionStatus.cancelled;

  int get availableSlots => maxUsers - currentUsers;
  double get usagePercentage => maxUsers > 0 ? (currentUsers / maxUsers) * 100 : 0;

  int get daysUntilExpiry {
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  String get formattedCost {
    return '\$${cost.toStringAsFixed(2)}';
  }

  String get fullDisplayName => '$name by $provider';
}

enum SubscriptionType {
  software,
  service,
  license,
  other
}

enum BillingCycle {
  monthly,
  quarterly,
  yearly,
  oneTime
}

enum SubscriptionStatus {
  active,
  expiring,
  expired,
  cancelled
}