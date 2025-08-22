// lib/features/documents/providers/documents_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';
import '../../features/documents/models/asset_handover.dart';
import '../../features/documents/models/no_dues_certificate.dart';

final documentsProvider = StateNotifierProvider<DocumentsNotifier, DocumentsState>((ref) {
  return DocumentsNotifier();
});

class DocumentsNotifier extends StateNotifier<DocumentsState> {
  DocumentsNotifier() : super(DocumentsState.initial());

  // Asset Handover Methods
  Future<AssetHandover?> generateAssetHandover(String employeeId, Map<String, dynamic> handoverData) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await ApiService.generateAssetHandover(employeeId, handoverData);

    if (response.success && response.data != null) {
      final handover = AssetHandover.fromJson(response.data!);
      state = state.copyWith(
        isLoading: false,
        currentAssetHandover: handover,
      );
      return handover;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to generate asset handover',
      );
      return null;
    }
  }

  Future<void> loadAssetHandoverData(String employeeId) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await ApiService.getAssetHandoverData(employeeId);

    if (response.success && response.data != null) {
      final handover = AssetHandover.fromJson(response.data!);
      state = state.copyWith(
        isLoading: false,
        currentAssetHandover: handover,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load asset handover data',
      );
    }
  }

  Future<List<HandoverAsset>> loadEmployeeAssets(String employeeId) async {
    final response = await ApiService.getEmployeeAssets(employeeId);

    if (response.success && response.data != null) {
      return response.data!
          .map<HandoverAsset>((asset) => HandoverAsset(
        particulars: '${asset['asset_type']} - ${asset['brand']} ${asset['model']}',
        assetCode: asset['device_id'] ?? '',
        serialNo: asset['serial_no'] ?? '',
        condition: asset['working_status'] ?? 'Working',
      ))
          .toList();
    }
    return [];
  }

  // No Dues Certificate Methods
  Future<NoDuesCertificate?> generateNoDuesCertificate(String employeeId, Map<String, dynamic> noDuesData) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await ApiService.generateNoDuesCertificate(employeeId, noDuesData);

    if (response.success && response.data != null) {
      final certificate = NoDuesCertificate.fromJson(response.data!);
      state = state.copyWith(
        isLoading: false,
        currentNoDuesCertificate: certificate,
      );
      return certificate;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to generate no dues certificate',
      );
      return null;
    }
  }

  Future<void> loadNoDuesData(String employeeId) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await ApiService.getNoDuesData(employeeId);

    if (response.success && response.data != null) {
      final certificate = NoDuesCertificate.fromJson(response.data!);
      state = state.copyWith(
        isLoading: false,
        currentNoDuesCertificate: certificate,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load no dues data',
      );
    }
  }

  Future<bool> updateExitChecklist(String employeeId, List<ExitChecklistItem> checklist) async {
    final checklistData = checklist.map((item) => item.toJson()).toList();
    final response = await ApiService.updateExitChecklist(employeeId, checklistData);

    if (response.success) {
      // Update current certificate if it exists
      if (state.currentNoDuesCertificate != null) {
        final updatedCertificate = NoDuesCertificate(
          employeeName: state.currentNoDuesCertificate!.employeeName,
          employeeCode: state.currentNoDuesCertificate!.employeeCode,
          role: state.currentNoDuesCertificate!.role,
          resignationDate: state.currentNoDuesCertificate!.resignationDate,
          lastWorkingDay: state.currentNoDuesCertificate!.lastWorkingDay,
          certificateDate: state.currentNoDuesCertificate!.certificateDate,
          checklist: checklist,
        );
        state = state.copyWith(currentNoDuesCertificate: updatedCertificate);
      }
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to update exit checklist',
      );
      return false;
    }
  }

  // Employee Exit Process
  Future<bool> initiateEmployeeExit(String employeeId, Map<String, dynamic> exitData) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await ApiService.initiateEmployeeExit(employeeId, exitData);

    if (response.success) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to initiate employee exit',
      );
      return false;
    }
  }

  Future<bool> completeEmployeeExit(String employeeId) async {
    state = state.copyWith(isLoading: true, error: null);

    final response = await ApiService.completeEmployeeExit(employeeId);

    if (response.success) {
      state = state.copyWith(isLoading: false);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to complete employee exit',
      );
      return false;
    }
  }

  // Document History
  Future<void> loadEmployeeDocuments(String employeeId) async {
    final response = await ApiService.getEmployeeDocuments(employeeId);

    if (response.success && response.data != null) {
      state = state.copyWith(
        employeeDocuments: response.data!,
      );
    }
  }

  Future<bool> saveGeneratedDocument(Map<String, dynamic> documentData) async {
    final response = await ApiService.saveGeneratedDocument(documentData);
    return response.success;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void clearCurrentDocuments() {
    state = state.copyWith(
      currentAssetHandover: null,
      currentNoDuesCertificate: null,
    );
  }
}

class DocumentsState {
  final bool isLoading;
  final String? error;
  final AssetHandover? currentAssetHandover;
  final NoDuesCertificate? currentNoDuesCertificate;
  final List<dynamic> employeeDocuments;

  DocumentsState({
    required this.isLoading,
    this.error,
    this.currentAssetHandover,
    this.currentNoDuesCertificate,
    required this.employeeDocuments,
  });

  factory DocumentsState.initial() {
    return DocumentsState(
      isLoading: false,
      employeeDocuments: [],
    );
  }

  DocumentsState copyWith({
    bool? isLoading,
    String? error,
    AssetHandover? currentAssetHandover,
    NoDuesCertificate? currentNoDuesCertificate,
    List<dynamic>? employeeDocuments,
  }) {
    return DocumentsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentAssetHandover: currentAssetHandover ?? this.currentAssetHandover,
      currentNoDuesCertificate: currentNoDuesCertificate ?? this.currentNoDuesCertificate,
      employeeDocuments: employeeDocuments ?? this.employeeDocuments,
    );
  }
}