import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final String title;
  final String description;
  final ReminderType type;
  final String? relatedId;
  final String? relatedTable;
  final DateTime reminderDate;
  final bool isRecurring;
  final String? recurringInterval;
  final ReminderStatus status;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.relatedId,
    this.relatedTable,
    required this.reminderDate,
    this.isRecurring = false,
    this.recurringInterval,
    required this.status,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseReminderType(json['reminder_type']),
      relatedId: json['related_id']?.toString(),
      relatedTable: json['related_table'],
      reminderDate: DateTime.parse(json['reminder_date']),
      isRecurring: json['is_recurring'] == 1 || json['is_recurring'] == true,
      recurringInterval: json['recurring_interval'],
      status: _parseReminderStatus(json['status']),
      createdBy: json['created_by']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'reminder_type': type.toString().split('.').last,
      'related_id': relatedId,
      'related_table': relatedTable,
      'reminder_date': reminderDate.toIso8601String(),
      'is_recurring': isRecurring,
      'recurring_interval': recurringInterval,
      'status': status.toString().split('.').last,
      'created_by': createdBy,
    };
  }

  Reminder copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    String? relatedId,
    String? relatedTable,
    DateTime? reminderDate,
    bool? isRecurring,
    String? recurringInterval,
    ReminderStatus? status,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      relatedTable: relatedTable ?? this.relatedTable,
      reminderDate: reminderDate ?? this.reminderDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static ReminderType _parseReminderType(String? type) {
    if (type == null) return ReminderType.custom;
    switch (type.toLowerCase()) {
      case 'subscription_expiry':
        return ReminderType.subscriptionExpiry;
      case 'asset_maintenance':
        return ReminderType.assetMaintenance;
      case 'license_renewal':
        return ReminderType.licenseRenewal;
      case 'custom':
      default:
        return ReminderType.custom;
    }
  }

  static ReminderStatus _parseReminderStatus(String? status) {
    if (status == null) return ReminderStatus.pending;
    switch (status.toLowerCase()) {
      case 'pending':
        return ReminderStatus.pending;
      case 'sent':
        return ReminderStatus.sent;
      case 'dismissed':
        return ReminderStatus.dismissed;
      default:
        return ReminderStatus.pending;
    }
  }

  // Helper methods
  String get statusDisplayName {
    switch (status) {
      case ReminderStatus.pending:
        return 'Pending';
      case ReminderStatus.sent:
        return 'Sent';
      case ReminderStatus.dismissed:
        return 'Dismissed';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ReminderType.subscriptionExpiry:
        return 'Subscription Expiry';
      case ReminderType.assetMaintenance:
        return 'Asset Maintenance';
      case ReminderType.licenseRenewal:
        return 'License Renewal';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  Color get statusColor {
    switch (status) {
      case ReminderStatus.pending:
        return Colors.orange;
      case ReminderStatus.sent:
        return Colors.blue;
      case ReminderStatus.dismissed:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    if (isOverdue) return Colors.red;
    if (isDueToday) return Colors.orange;
    if (isDueSoon) return Colors.yellow;
    return Colors.green;
  }

  IconData get typeIcon {
    switch (type) {
      case ReminderType.subscriptionExpiry:
        return Icons.subscriptions;
      case ReminderType.assetMaintenance:
        return Icons.build;
      case ReminderType.licenseRenewal:
        return Icons.verified;
      case ReminderType.custom:
        return Icons.notifications;
    }
  }

  bool get isPending => status == ReminderStatus.pending;
  bool get isSent => status == ReminderStatus.sent;
  bool get isDismissed => status == ReminderStatus.dismissed;

  bool get isOverdue {
    final now = DateTime.now();
    return isPending && reminderDate.isBefore(now);
  }

  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay = DateTime(reminderDate.year, reminderDate.month, reminderDate.day);
    return isPending && reminderDay.isAtSameMomentAs(today);
  }

  bool get isDueSoon {
    final now = DateTime.now();
    final diffInDays = reminderDate.difference(now).inDays;
    return isPending && diffInDays >= 0 && diffInDays <= 7;
  }

  int get daysUntilDue {
    final now = DateTime.now();
    return reminderDate.difference(now).inDays;
  }

  String get timeUntilDue {
    final now = DateTime.now();
    final difference = reminderDate.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 0) {
        return '${absDifference.inDays} days overdue';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} hours overdue';
      } else {
        return '${absDifference.inMinutes} minutes overdue';
      }
    } else {
      if (difference.inDays > 0) {
        return 'In ${difference.inDays} days';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hours';
      } else {
        return 'In ${difference.inMinutes} minutes';
      }
    }
  }

  String get formattedReminderDate {
    return '${reminderDate.day}/${reminderDate.month}/${reminderDate.year} ${reminderDate.hour.toString().padLeft(2, '0')}:${reminderDate.minute.toString().padLeft(2, '0')}';
  }

  ReminderPriority get priority {
    if (isOverdue) return ReminderPriority.urgent;
    if (isDueToday) return ReminderPriority.high;
    if (isDueSoon) return ReminderPriority.medium;
    return ReminderPriority.low;
  }
}

enum ReminderType {
  subscriptionExpiry,
  assetMaintenance,
  licenseRenewal,
  custom
}

enum ReminderStatus {
  pending,
  sent,
  dismissed
}

enum ReminderPriority {
  low,
  medium,
  high,
  urgent
}