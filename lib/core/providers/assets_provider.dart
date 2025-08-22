// lib/core/providers/assets_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/assets/presentation/screens/assets_screen.dart';
import '../services/api_service.dart';
import '../../features/assets/models/asset.dart';

final assetsProvider = StateNotifierProvider<AssetsNotifier, AssetsState>((ref) {
  return AssetsNotifier();
});

class AssetsNotifier extends StateNotifier<AssetsState> {
  AssetsNotifier() : super(AssetsState.initial());

  Future<void> loadAssets({String search = '', int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final response = await ApiService.getAssets(
      page: page,
      limit: 20,
      search: search,
    );

    if (response.success && response.data != null) {
      final assets = response.data!
          .map((json) => Asset.fromJson(json))
          .toList();

      state = state.copyWith(
        isLoading: false,
        assets: page == 1 ? assets : [...state.assets, ...assets],
        hasMore: assets.length == 20,
        currentPage: page,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load assets',
      );
    }
  }

  Future<bool> createAsset(Map<String, dynamic> assetData) async {
    final response = await ApiService.createAsset(assetData);

    if (response.success) {
      // Reload assets to get the updated list
      await loadAssets();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to create asset',
      );
      return false;
    }
  }

  Future<bool> updateAsset(String id, Map<String, dynamic> assetData) async {
    final response = await ApiService.updateAsset(id, assetData);

    if (response.success) {
      await loadAssets();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to update asset',
      );
      return false;
    }
  }

  Future<bool> deleteAsset(String id) async {
    final response = await ApiService.deleteAsset(id);

    if (response.success) {
      // Remove from local state immediately for better UX
      final updatedAssets = state.assets.where((asset) => asset.id != id).toList();
      state = state.copyWith(assets: updatedAssets);
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to delete asset',
      );
      return false;
    }
  }

  Future<bool> assignAsset(String assetId, String employeeId, String? notes, String? asset_type, String? device_id) async {
    final response = await ApiService.assignAsset(assetId, employeeId, notes, asset_type, device_id);

    if (response.success) {
      // Update the asset status locally and reload to get fresh data
      final updatedAssets = state.assets.map((asset) {
        if (asset.id == assetId) {
          return asset.copyWith(
            status: AssetStatus.assigned,
            assignedDate: DateTime.now(),
          );
        }
        return asset;
      }).toList();

      state = state.copyWith(assets: updatedAssets);

      // Reload to get the complete updated data from server
      await loadAssets();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to assign asset',
      );
      return false;
    }
  }

  Future<bool> returnAsset(String assetId, String? condition, String? reason) async {
    final response = await ApiService.returnAsset(assetId, condition, reason);

    if (response.success) {
      // Update the asset status locally and reload to get fresh data
      final updatedAssets = state.assets.map((asset) {
        if (asset.id == assetId) {
          return asset.copyWith(
            status: AssetStatus.available,
            assignedTo: null,
            assignedDate: null,
          );
        }
        return asset;
      }).toList();

      state = state.copyWith(assets: updatedAssets);

      // Reload to get the complete updated data from server
      await loadAssets();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to return asset',
      );
      return false;
    }
  }

  Future<List<Asset>> getAvailableAssets() async {
    final response = await ApiService.getAvailableAssets();

    if (response.success && response.data != null) {
      return response.data!
          .map((json) => Asset.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<Asset>> getAssignedAssets(String? employeeId) async {
    final response = await ApiService.getAssignedAssets(employeeId);

    if (response.success && response.data != null) {
      return response.data!
          .map((json) => Asset.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<List<AssetHistory>> getAssetHistory(String assetId) async {
    final response = await ApiService.getAssetHistory(assetId);

    if (response.success && response.data != null) {
      return response.data!
          .map((json) => AssetHistory.fromJson(json))
          .toList();
    }
    return [];
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setFilter(String search) {
    loadAssets(search: search);
  }

  // Load more assets for pagination
  Future<void> loadMoreAssets() async {
    if (state.hasMore && !state.isLoading) {
      await loadAssets(page: state.currentPage + 1);
    }
  }

  // Refresh assets
  Future<void> refreshAssets() async {
    await loadAssets(page: 1);
  }

  // Filter assets by type locally
  List<Asset> getAssetsByType(AssetType type) {
    return state.assets.where((asset) => asset.type == type).toList();
  }

  // Filter assets by status locally
  List<Asset> getAssetsByStatus(AssetStatus status) {
    return state.assets.where((asset) => asset.status == status).toList();
  }

  // Get asset statistics
  Map<String, int> getAssetStats() {
    final stats = <String, int>{};

    // Count by status
    for (final status in AssetStatus.values) {
      stats[status.toString().split('.').last] =
          state.assets.where((asset) => asset.status == status).length;
    }

    // Count by type
    for (final type in AssetType.values) {
      stats['${type.toString().split('.').last}_count'] =
          state.assets.where((asset) => asset.type == type).length;
    }

    stats['total'] = state.assets.length;

    return stats;
  }
}

class AssetsState {
  final bool isLoading;
  final List<Asset> assets;
  final String? error;
  final bool hasMore;
  final int currentPage;

  AssetsState({
    required this.isLoading,
    required this.assets,
    this.error,
    required this.hasMore,
    required this.currentPage,
  });

  factory AssetsState.initial() {
    return AssetsState(
      isLoading: false,
      assets: [],
      hasMore: true,
      currentPage: 1,
    );
  }

  AssetsState copyWith({
    bool? isLoading,
    List<Asset>? assets,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return AssetsState(
      isLoading: isLoading ?? this.isLoading,
      assets: assets ?? this.assets,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Asset History model for tracking assignment history
class AssetHistory {
  final String id;
  final String assetId;
  final String employeeId;
  final String employeeName;
  final String employeeEmployeeId;
  final DateTime assignedDate;
  final DateTime? returnDate;
  final String? reasonForReturn;
  final String? conditionOnReturn;
  final DateTime createdAt;

  AssetHistory({
    required this.id,
    required this.assetId,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmployeeId,
    required this.assignedDate,
    this.returnDate,
    this.reasonForReturn,
    this.conditionOnReturn,
    required this.createdAt,
  });

  factory AssetHistory.fromJson(Map<String, dynamic> json) {
    return AssetHistory(
      id: json['id'].toString(),
      assetId: json['asset_id'].toString(),
      employeeId: json['employee_id'].toString(),
      employeeName: '${json['first_name']} ${json['last_name']}',
      employeeEmployeeId: json['employee_id'].toString(),
      assignedDate: DateTime.parse(json['assigned_date']),
      returnDate: json['return_date'] != null ? DateTime.parse(json['return_date']) : null,
      reasonForReturn: json['reason_for_return'],
      conditionOnReturn: json['condition_on_return'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}