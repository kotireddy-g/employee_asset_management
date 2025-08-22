import 'dart:convert';
import 'package:dio/dio.dart';

import 'local_storage_service.dart';

class ApiService {
  static final Dio _dio = Dio();
  static const String baseUrl = 'https://exflow.gkr.digital/api';

  static void init() {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          final token = LocalStorageService.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Token expired, redirect to login
            LocalStorageService.remove('auth_token');
          }
          handler.next(error);
        },
      ),
    );
  }

  // Auth endpoints
  static Future<ApiResponse<Map<String, dynamic>>> login(
      String username, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    try {
      final response = await _dio.get('/dashboard/stats');

      // Handle different response structures
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>? ?? data);
      } else {
        return ApiResponse.error('Invalid response format');
      }
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Fixed asset distribution method
  static Future<ApiResponse<Map<String, dynamic>>> getAssetDistribution() async {
    try {
      final response = await _dio.get('/dashboard/assets-chart');

      // Handle different response structures
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return ApiResponse.success(data['data'] as Map<String, dynamic>? ?? data);
      } else {
        return ApiResponse.error('Invalid response format');
      }
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Fixed recent activities method
  static Future<ApiResponse<List<dynamic>>> getRecentActivities({int limit = 10}) async {
    try {
      final response = await _dio.get('/dashboard/activities', queryParameters: {
        'limit': limit,
      });

      // Handle different response structures
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final activities = data['data'];
        if (activities is List) {
          return ApiResponse.success(activities);
        } else {
          return ApiResponse.success([]);
        }
      } else if (data is List) {
        return ApiResponse.success(data);
      } else {
        return ApiResponse.success([]);
      }
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Enhanced error handling
  static String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final responseData = error.response!.data;
        if (responseData is Map<String, dynamic>) {
          return responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              'An error occurred';
        } else if (responseData is String) {
          return responseData;
        } else {
          return 'Server error: ${error.response!.statusCode}';
        }
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout. Please check your internet connection.';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return 'Request timeout. Please try again.';
      } else {
        return 'Network error. Please check your connection.';
      }
    }
    return 'An unexpected error occurred: ${error.toString()}';
  }

  // Employee endpoints
  static Future<ApiResponse<List<dynamic>>> getEmployees({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    try {
      final response = await _dio.get('/employees', queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
      });
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> createEmployee(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/employees', data: data);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateEmployee(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/employees/$id', data: data);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<void>> deleteEmployee(String id) async {
    try {
      await _dio.delete('/employees/$id');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Asset endpoints
  static Future<ApiResponse<List<dynamic>>> getAssets({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    try {
      final response = await _dio.get('/assets', queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
      });
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> createAsset(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/assets', data: data);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> assignAsset(
      String assetId, String employeeId, String? notes,String? asset_type, String? device_id) async {
    try {
      final response = await _dio.post('/assets/assign', data: {
        'asset_id': assetId,
        'employee_id': employeeId,
        'notes': notes,
        'asset_type': asset_type,
        'device_id': device_id
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Subscription endpoints
  static Future<ApiResponse<List<dynamic>>> getSubscriptions({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    try {
      final response = await _dio.get('/subscriptions', queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
      });
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<dynamic>>> getExpiringSubscriptions(
      int days) async {
    try {
      final response = await _dio.get('/subscriptions/expiring',
          queryParameters: {'days': days});
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateAsset(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/assets/$id', data: data);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<void>> deleteAsset(String id) async {
    try {
      await _dio.delete('/assets/$id');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> returnAsset(
      String assetId, String? condition, String? reason) async {
    try {
      final response = await _dio.post('/assets/return', data: {
        'asset_id': assetId,
        'condition': condition,
        'reason': reason,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<dynamic>>> getAvailableAssets() async {
    try {
      final response = await _dio.get('/assets/available');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<dynamic>>> getAssignedAssets(String? employeeId) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (employeeId != null && employeeId.isNotEmpty) {
        queryParams['employee_id'] = employeeId;
      }

      final response = await _dio.get('/assets/assigned', queryParameters: queryParams);
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<dynamic>>> getAssetHistory(String assetId) async {
    try {
      final response = await _dio.get('/assets/$assetId/history');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getAssetDetails(String assetId) async {
    try {
      final response = await _dio.get('/assets/$assetId');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Asset Statistics
  static Future<ApiResponse<Map<String, dynamic>>> getAssetStats() async {
    try {
      final response = await _dio.get('/dashboard/asset-stats');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Search assets with advanced filters
  static Future<ApiResponse<List<dynamic>>> searchAssets({
    String? search,
    String? assetType,
    String? status,
    String? assignedTo,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (assetType != null && assetType.isNotEmpty) {
        queryParams['asset_type'] = assetType;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (assignedTo != null && assignedTo.isNotEmpty) {
        queryParams['assigned_to'] = assignedTo;
      }

      final response = await _dio.get('/assets/search', queryParameters: queryParams);
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Bulk operations
  static Future<ApiResponse<Map<String, dynamic>>> bulkUpdateAssetStatus(
      List<String> assetIds, String newStatus) async {
    try {
      final response = await _dio.post('/assets/bulk-update-status', data: {
        'asset_ids': assetIds,
        'status': newStatus,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> bulkAssignAssets(
      List<String> assetIds, String employeeId, String? notes) async {
    try {
      final response = await _dio.post('/assets/bulk-assign', data: {
        'asset_ids': assetIds,
        'employee_id': employeeId,
        'notes': notes,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Export assets
  static Future<ApiResponse<String>> exportAssets({
    String format = 'csv',
    String? assetType,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'format': format,
      };

      if (assetType != null && assetType.isNotEmpty) {
        queryParams['asset_type'] = assetType;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get('/assets/export', queryParameters: queryParams);
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Asset maintenance
  static Future<ApiResponse<Map<String, dynamic>>> markAssetForMaintenance(
      String assetId, String reason, String? notes) async {
    try {
      final response = await _dio.post('/assets/$assetId/maintenance', data: {
        'reason': reason,
        'notes': notes,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> markAssetMaintenanceComplete(
      String assetId, String? notes) async {
    try {
      final response = await _dio.post('/assets/$assetId/maintenance-complete', data: {
        'notes': notes,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Asset disposal
  static Future<ApiResponse<Map<String, dynamic>>> disposeAsset(
      String assetId, String reason, String? notes) async {
    try {
      final response = await _dio.post('/assets/$assetId/dispose', data: {
        'reason': reason,
        'notes': notes,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> createSubscription(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/subscriptions', data: data);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateSubscription(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/subscriptions/$id', data: data);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<void>> deleteSubscription(String id) async {
    try {
      await _dio.delete('/subscriptions/$id');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> assignSubscription(
      String subscriptionId,
      String employeeId,
      String loginId,
      String password,
      String? notes) async {
    try {
      final response = await _dio.post('/subscriptions/assign', data: {
        'subscription_id': subscriptionId,
        'employee_id': employeeId,
        'login_id': loginId,
        'password': password,
        'notes': notes,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getSubscriptionDetails(String subscriptionId) async {
    try {
      final response = await _dio.get('/subscriptions/$subscriptionId');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getSubscriptionUsage(String subscriptionId) async {
    try {
      final response = await _dio.get('/subscriptions/$subscriptionId/usage');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<dynamic>>> getSubscriptionAssignments(String subscriptionId) async {
    try {
      final response = await _dio.get('/subscriptions/$subscriptionId/assignments');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Search subscriptions with advanced filters
  static Future<ApiResponse<List<dynamic>>> searchSubscriptions({
    String? search,
    String? subscriptionType,
    String? status,
    String? provider,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (subscriptionType != null && subscriptionType.isNotEmpty) {
        queryParams['subscription_type'] = subscriptionType;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (provider != null && provider.isNotEmpty) {
        queryParams['provider'] = provider;
      }

      final response = await _dio.get('/subscriptions/search', queryParameters: queryParams);
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Subscription statistics
  static Future<ApiResponse<Map<String, dynamic>>> getSubscriptionStats() async {
    try {
      final response = await _dio.get('/dashboard/subscription-stats');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Renew subscription
  static Future<ApiResponse<Map<String, dynamic>>> renewSubscription(
      String subscriptionId, DateTime newEndDate, double? newCost) async {
    try {
      final response = await _dio.post('/subscriptions/$subscriptionId/renew', data: {
        'new_end_date': newEndDate.toIso8601String().split('T')[0],
        'new_cost': newCost,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Cancel subscription
  static Future<ApiResponse<Map<String, dynamic>>> cancelSubscription(
      String subscriptionId, String reason) async {
    try {
      final response = await _dio.post('/subscriptions/$subscriptionId/cancel', data: {
        'reason': reason,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Export subscriptions
  static Future<ApiResponse<String>> exportSubscriptions({
    String format = 'csv',
    String? subscriptionType,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'format': format,
      };

      if (subscriptionType != null && subscriptionType.isNotEmpty) {
        queryParams['subscription_type'] = subscriptionType;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get('/subscriptions/export', queryParameters: queryParams);
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<dynamic>>> getReminders({
    int page = 1,
    int limit = 20,
    String search = '',
  }) async {
    try {
      final response = await _dio.get('/reminders', queryParameters: {
        'page': page,
        'limit': limit,
        'search': search,
      });
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> createReminder(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/reminders', data: data);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateReminder(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/reminders/$id', data: data);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<void>> deleteReminder(String id) async {
    try {
      await _dio.delete('/reminders/$id');
      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> dismissReminder(String id) async {
    try {
      final response = await _dio.put('/reminders/$id/dismiss');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> markReminderAsSent(String id) async {
    try {
      final response = await _dio.put('/reminders/$id/mark-sent');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<dynamic>>> getPendingReminders() async {
    try {
      final response = await _dio.get('/reminders/pending');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> generateReminders() async {
    try {
      final response = await _dio.get('/reminders/generate');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getReminderDetails(String reminderId) async {
    try {
      final response = await _dio.get('/reminders/$reminderId');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Search reminders with advanced filters
  static Future<ApiResponse<List<dynamic>>> searchReminders({
    String? search,
    String? reminderType,
    String? status,
    String? relatedTable,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (reminderType != null && reminderType.isNotEmpty) {
        queryParams['reminder_type'] = reminderType;
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }
      if (relatedTable != null && relatedTable.isNotEmpty) {
        queryParams['related_table'] = relatedTable;
      }

      final response = await _dio.get('/reminders/search', queryParameters: queryParams);
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

// Reminder statistics
  static Future<ApiResponse<Map<String, dynamic>>> getReminderStats() async {
    try {
      final response = await _dio.get('/dashboard/reminder-stats');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Asset Handover Document APIs
  static Future<ApiResponse<Map<String, dynamic>>> generateAssetHandover(
      String employeeId, Map<String, dynamic> handoverData) async {
    try {
      final response = await _dio.post('/documents/asset-handover', data: {
        'employee_id': employeeId,
        ...handoverData,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getAssetHandoverData(
      String employeeId) async {
    try {
      final response = await _dio.get('/documents/asset-handover/$employeeId');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<List<dynamic>>> getEmployeeAssets(
      String employeeId) async {
    try {
      final response = await _dio.get('/employees/$employeeId/assets');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // No Dues Certificate APIs
  static Future<ApiResponse<Map<String, dynamic>>> generateNoDuesCertificate(
      String employeeId, Map<String, dynamic> noDuesData) async {
    try {
      final response = await _dio.post('/documents/no-dues-certificate', data: {
        'employee_id': employeeId,
        ...noDuesData,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> getNoDuesData(
      String employeeId) async {
    try {
      final response = await _dio.get('/documents/no-dues-certificate/$employeeId');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> updateExitChecklist(
      String employeeId, List<Map<String, dynamic>> checklistData) async {
    try {
      final response = await _dio.put('/employees/$employeeId/exit-checklist', data: {
        'checklist': checklistData,
      });
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Employee resignation/exit APIs
  static Future<ApiResponse<Map<String, dynamic>>> initiateEmployeeExit(
      String employeeId, Map<String, dynamic> exitData) async {
    try {
      final response = await _dio.post('/employees/$employeeId/initiate-exit', data: exitData);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> completeEmployeeExit(
      String employeeId) async {
    try {
      final response = await _dio.post('/employees/$employeeId/complete-exit');
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  // Document history and tracking
  static Future<ApiResponse<List<dynamic>>> getEmployeeDocuments(
      String employeeId) async {
    try {
      final response = await _dio.get('/employees/$employeeId/documents');
      return ApiResponse.success(response.data['data']);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> saveGeneratedDocument(
      Map<String, dynamic> documentData) async {
    try {
      final response = await _dio.post('/documents/save', data: documentData);
      return ApiResponse.success(response.data);
    } catch (e) {
      return ApiResponse.error(_handleError(e));
    }
  }
}

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse.success(this.data)
      : success = true,
        error = null;

  ApiResponse.error(this.error)
      : success = false,
        data = null;
}