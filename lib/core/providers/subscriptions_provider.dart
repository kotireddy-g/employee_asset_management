// lib/core/providers/subscriptions_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../features/subscriptions/models/subscription.dart';

final subscriptionsProvider = StateNotifierProvider<SubscriptionsNotifier, SubscriptionsState>((ref) {
  return SubscriptionsNotifier();
});

class SubscriptionsNotifier extends StateNotifier<SubscriptionsState> {
  SubscriptionsNotifier() : super(SubscriptionsState.initial());

  Future<void> loadSubscriptions({String search = '', int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final response = await ApiService.getSubscriptions(
      page: page,
      limit: 20,
      search: search,
    );

    if (response.success && response.data != null) {
      final subscriptions = response.data!
          .map((json) => Subscription.fromJson(json))
          .toList();

      state = state.copyWith(
        isLoading: false,
        subscriptions: page == 1 ? subscriptions : [...state.subscriptions, ...subscriptions],
        hasMore: subscriptions.length == 20,
        currentPage: page,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load subscriptions',
      );
    }
  }

  Future<bool> createSubscription(Map<String, dynamic> subscriptionData) async {
    final response = await ApiService.createSubscription(subscriptionData);

    if (response.success) {
      // Reload subscriptions to get the updated list
      await loadSubscriptions();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to create subscription',
      );
      return false;
    }
  }

  Future<bool> updateSubscription(String id, Map<String, dynamic> subscriptionData) async {
    final response = await ApiService.updateSubscription(id, subscriptionData);

    if (response.success) {
      await loadSubscriptions();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to update subscription',
      );
      return false;
    }
  }

  Future<bool> deleteSubscription(String id) async {
    final response = await ApiService.deleteSubscription(id);

    if (response.success) {
      // Remove from local state immediately for better UX
      final updatedSubscriptions = state.subscriptions.where((sub) => sub.id != id).toList();
      state = state.copyWith(subscriptions: updatedSubscriptions);
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to delete subscription',
      );
      return false;
    }
  }

  Future<bool> assignSubscription(String subscriptionId, String employeeId, String loginId, String password, String? notes) async {
    final response = await ApiService.assignSubscription(
        subscriptionId,
        employeeId,
        loginId,
        password,
        notes
    );

    if (response.success) {
      // Update the current users count locally
      final updatedSubscriptions = state.subscriptions.map((subscription) {
        if (subscription.id == subscriptionId) {
          return subscription.copyWith(
            currentUsers: subscription.currentUsers + 1,
          );
        }
        return subscription;
      }).toList();

      state = state.copyWith(subscriptions: updatedSubscriptions);

      // Reload to get the complete updated data from server
      await loadSubscriptions();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to assign subscription',
      );
      return false;
    }
  }

  Future<List<Subscription>> getExpiringSubscriptions(int days) async {
    final response = await ApiService.getExpiringSubscriptions(days);

    if (response.success && response.data != null) {
      return response.data!
          .map((json) => Subscription.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<SubscriptionAssignment>> getSubscriptionAssignments(String subscriptionId) async {
    final response = await ApiService.getSubscriptionAssignments(subscriptionId);

    if (response.success && response.data != null) {
      return response.data!
          .map((json) => SubscriptionAssignment.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<SubscriptionUsage?> getSubscriptionUsage(String subscriptionId) async {
    final response = await ApiService.getSubscriptionUsage(subscriptionId);

    if (response.success && response.data != null) {
      return SubscriptionUsage.fromJson(response.data!);
    }
    return null;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setFilter(String search) {
    loadSubscriptions(search: search);
  }

  // Load more subscriptions for pagination
  Future<void> loadMoreSubscriptions() async {
    if (state.hasMore && !state.isLoading) {
      await loadSubscriptions(page: state.currentPage + 1);
    }
  }

  // Refresh subscriptions
  Future<void> refreshSubscriptions() async {
    await loadSubscriptions(page: 1);
  }

  // Filter subscriptions by type locally
  List<Subscription> getSubscriptionsByType(SubscriptionType type) {
    return state.subscriptions.where((subscription) => subscription.type == type).toList();
  }

  // Filter subscriptions by status locally
  List<Subscription> getSubscriptionsByStatus(SubscriptionStatus status) {
    return state.subscriptions.where((subscription) => subscription.status == status).toList();
  }

  // Get subscription statistics
  Map<String, int> getSubscriptionStats() {
    final stats = <String, int>{};

    // Count by status
    for (final status in SubscriptionStatus.values) {
      stats[status.toString().split('.').last] =
          state.subscriptions.where((subscription) => subscription.status == status).length;
    }

    // Count by type
    for (final type in SubscriptionType.values) {
      stats['${type.toString().split('.').last}_count'] =
          state.subscriptions.where((subscription) => subscription.type == type).length;
    }

    stats['total'] = state.subscriptions.length;
    stats['total_cost'] = state.subscriptions.fold(0, (sum, sub) => sum + sub.cost.toInt());

    return stats;
  }
}

class SubscriptionsState {
  final bool isLoading;
  final List<Subscription> subscriptions;
  final String? error;
  final bool hasMore;
  final int currentPage;

  SubscriptionsState({
    required this.isLoading,
    required this.subscriptions,
    this.error,
    required this.hasMore,
    required this.currentPage,
  });

  factory SubscriptionsState.initial() {
    return SubscriptionsState(
      isLoading: false,
      subscriptions: [],
      hasMore: true,
      currentPage: 1,
    );
  }

  SubscriptionsState copyWith({
    bool? isLoading,
    List<Subscription>? subscriptions,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return SubscriptionsState(
      isLoading: isLoading ?? this.isLoading,
      subscriptions: subscriptions ?? this.subscriptions,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Additional models for subscription management
class SubscriptionAssignment {
  final String id;
  final String subscriptionId;
  final String employeeId;
  final String employeeName;
  final String employeeEmployeeId;
  final String loginId;
  final DateTime assignedDate;
  final String status;
  final String? notes;

  SubscriptionAssignment({
    required this.id,
    required this.subscriptionId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmployeeId,
    required this.loginId,
    required this.assignedDate,
    required this.status,
    this.notes,
  });

  factory SubscriptionAssignment.fromJson(Map<String, dynamic> json) {
    return SubscriptionAssignment(
      id: json['id'].toString(),
      subscriptionId: json['subscription_id'].toString(),
      employeeId: json['employee_id'].toString(),
      employeeName: '${json['first_name']} ${json['last_name']}',
      employeeEmployeeId: json['employee_id'].toString(),
      loginId: json['login_id'] ?? '',
      assignedDate: DateTime.parse(json['assigned_date']),
      status: json['status'] ?? '',
      notes: json['notes'],
    );
  }
}

class SubscriptionUsage {
  final String subscriptionId;
  final int maxUsers;
  final int currentUsers;
  final int availableSlots;
  final double usagePercentage;
  final List<SubscriptionAssignment> activeAssignments;

  SubscriptionUsage({
    required this.subscriptionId,
    required this.maxUsers,
    required this.currentUsers,
    required this.availableSlots,
    required this.usagePercentage,
    required this.activeAssignments,
  });

  factory SubscriptionUsage.fromJson(Map<String, dynamic> json) {
    final assignments = (json['active_assignments'] as List<dynamic>?)
        ?.map((assignment) => SubscriptionAssignment.fromJson(assignment))
        .toList() ?? [];

    return SubscriptionUsage(
      subscriptionId: json['subscription_id'].toString(),
      maxUsers: json['max_users'] ?? 0,
      currentUsers: json['current_users'] ?? 0,
      availableSlots: json['available_slots'] ?? 0,
      usagePercentage: (json['usage_percentage'] ?? 0).toDouble(),
      activeAssignments: assignments,
    );
  }
}