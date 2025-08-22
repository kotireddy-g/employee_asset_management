import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(DashboardState.initial());

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load dashboard stats
      print('Loading dashboard stats...');
      final statsResponse = await ApiService.getDashboardStats();
      print('Stats response: ${statsResponse.success}, data: ${statsResponse.data}');

      // Load asset distribution
      final assetDistributionResponse = await ApiService.getAssetDistribution();

      // Load recent activities
      final activitiesResponse = await ApiService.getRecentActivities(limit: 5);

      if (statsResponse.success && statsResponse.data != null) {
        final statsData = statsResponse.data!;

        // Parse dashboard stats
        final stats = DashboardStats.fromJson(statsData);

        // Parse asset distribution
        AssetDistribution? assetDistribution;
        if (assetDistributionResponse.success && assetDistributionResponse.data != null) {
          assetDistribution = AssetDistribution.fromJson(assetDistributionResponse.data!);
        }

        // Parse recent activities
        List<RecentActivity> activities = [];
        if (activitiesResponse.success && activitiesResponse.data != null) {
          final activitiesData = activitiesResponse.data as List<dynamic>;
          activities = activitiesData
              .map((json) => RecentActivity.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        state = state.copyWith(
          isLoading: false,
          stats: stats,
          assetDistribution: assetDistribution,
          recentActivities: activities,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: statsResponse.error ?? 'Failed to load dashboard data',
        );
      }
    } catch (e) {
      print('Error loading dashboard: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data: ${e.toString()}',
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

class DashboardState {
  final bool isLoading;
  final DashboardStats? stats;
  final AssetDistribution? assetDistribution;
  final List<RecentActivity> recentActivities;
  final String? error;

  DashboardState({
    required this.isLoading,
    this.stats,
    this.assetDistribution,
    required this.recentActivities,
    this.error,
  });

  factory DashboardState.initial() {
    return DashboardState(
      isLoading: false,
      recentActivities: [],
    );
  }

  DashboardState copyWith({
    bool? isLoading,
    DashboardStats? stats,
    AssetDistribution? assetDistribution,
    List<RecentActivity>? recentActivities,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      assetDistribution: assetDistribution ?? this.assetDistribution,
      recentActivities: recentActivities ?? this.recentActivities,
      error: error, // Note: Always use the passed error value, don't fall back to existing
    );
  }
}

class DashboardStats {
  final int totalEmployees;
  final int totalAssets;
  final int assignedAssets;
  final int availableAssets;
  final int activeSubscriptions;
  final int expiringSubscriptions;
  final int pendingReminders;

  // Trend data (you might need to calculate these or get from API)
  final String employeeTrend;
  final String assetTrend;
  final String subscriptionTrend;
  final String reminderTrend;

  DashboardStats({
    required this.totalEmployees,
    required this.totalAssets,
    required this.assignedAssets,
    required this.availableAssets,
    required this.activeSubscriptions,
    required this.expiringSubscriptions,
    required this.pendingReminders,
    required this.employeeTrend,
    required this.assetTrend,
    required this.subscriptionTrend,
    required this.reminderTrend,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    // Handle both direct stats object and nested stats object
    final stats = json.containsKey('stats') ? json['stats'] as Map<String, dynamic>? ?? {} : json;

    return DashboardStats(
      totalEmployees: _parseIntSafely(stats['total_employees']),
      totalAssets: _parseIntSafely(stats['total_assets']),
      assignedAssets: _parseIntSafely(stats['assigned_assets']),
      availableAssets: _parseIntSafely(stats['available_assets']),
      activeSubscriptions: _parseIntSafely(stats['active_subscriptions']),
      expiringSubscriptions: _parseIntSafely(stats['expiring_subscriptions']),
      pendingReminders: _parseIntSafely(stats['pending_reminders']),
      // For now, using placeholder trends - you can enhance this later
      employeeTrend: stats['employee_trend']?.toString() ?? '+12%',
      assetTrend: stats['asset_trend']?.toString() ?? '+8%',
      subscriptionTrend: stats['subscription_trend']?.toString() ?? '+3%',
      reminderTrend: stats['reminder_trend']?.toString() ?? '+5%',
    );
  }

  // Helper method to safely parse integers
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }
}

class AssetDistribution {
  final int laptops;
  final int desktops;
  final int mobiles;
  final int tablets;
  final int others;
  final int total;

  AssetDistribution({
    required this.laptops,
    required this.desktops,
    required this.mobiles,
    required this.tablets,
    required this.others,
  }) : total = laptops + desktops + mobiles + tablets + others;

  double get laptopsPercent => total > 0 ? (laptops / total) * 100 : 0;
  double get desktopsPercent => total > 0 ? (desktops / total) * 100 : 0;
  double get mobilesPercent => total > 0 ? (mobiles / total) * 100 : 0;
  double get tabletsPercent => total > 0 ? (tablets / total) * 100 : 0;
  double get othersPercent => total > 0 ? (others / total) * 100 : 0;

  factory AssetDistribution.fromJson(Map<String, dynamic> json) {
    final assetsByType = json['assets_by_type'] as List<dynamic>? ?? [];

    int laptops = 0, desktops = 0, mobiles = 0, tablets = 0, others = 0;

    for (final item in assetsByType) {
      if (item is! Map<String, dynamic>) continue;

      final type = item['asset_type']?.toString().toLowerCase() ?? '';
      final count = _parseIntSafely(item['count']);

      switch (type) {
        case 'laptop':
        case 'laptops':
          laptops = count;
          break;
        case 'desktop':
        case 'desktops':
          desktops = count;
          break;
        case 'mobile':
        case 'mobiles':
        case 'phone':
        case 'phones':
          mobiles = count;
          break;
        case 'tablet':
        case 'tablets':
          tablets = count;
          break;
        default:
          others += count;
          break;
      }
    }

    return AssetDistribution(
      laptops: laptops,
      desktops: desktops,
      mobiles: mobiles,
      tablets: tablets,
      others: others,
    );
  }

  // Helper method to safely parse integers
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? 0;
    }
    return 0;
  }
}

class RecentActivity {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String? employeeName;
  final String? assetName;

  RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.employeeName,
    this.assetName,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      timestamp: _parseDateTime(json['timestamp']),
      employeeName: json['employee_name']?.toString(),
      assetName: json['asset_name']?.toString(),
    );
  }

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();

    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      }
    } catch (e) {
      // If parsing fails, return current time
      return DateTime.now();
    }

    return DateTime.now();
  }
}