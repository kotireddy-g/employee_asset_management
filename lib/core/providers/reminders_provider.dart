// lib/core/providers/reminders_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../features/reminders/models/reminder.dart';

final remindersProvider = StateNotifierProvider<RemindersNotifier, RemindersState>((ref) {
  return RemindersNotifier();
});

class RemindersNotifier extends StateNotifier<RemindersState> {
  RemindersNotifier() : super(RemindersState.initial());

  Future<void> loadReminders({String search = '', int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final response = await ApiService.getReminders(
      page: page,
      limit: 20,
      search: search,
    );

    if (response.success && response.data != null) {
      final reminders = response.data!
          .map((json) => Reminder.fromJson(json))
          .toList();

      state = state.copyWith(
        isLoading: false,
        reminders: page == 1 ? reminders : [...state.reminders, ...reminders],
        hasMore: reminders.length == 20,
        currentPage: page,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load reminders',
      );
    }
  }

  Future<bool> createReminder(Map<String, dynamic> reminderData) async {
    final response = await ApiService.createReminder(reminderData);

    if (response.success) {
      // Reload reminders to get the updated list
      await loadReminders();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to create reminder',
      );
      return false;
    }
  }

  Future<bool> updateReminder(String id, Map<String, dynamic> reminderData) async {
    final response = await ApiService.updateReminder(id, reminderData);

    if (response.success) {
      await loadReminders();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to update reminder',
      );
      return false;
    }
  }

  Future<bool> deleteReminder(String id) async {
    final response = await ApiService.deleteReminder(id);

    if (response.success) {
      // Remove from local state immediately for better UX
      final updatedReminders = state.reminders.where((reminder) => reminder.id != id).toList();
      state = state.copyWith(reminders: updatedReminders);
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to delete reminder',
      );
      return false;
    }
  }

  Future<bool> dismissReminder(String id) async {
    final response = await ApiService.dismissReminder(id);

    if (response.success) {
      // Update local state immediately
      final updatedReminders = state.reminders.map((reminder) {
        if (reminder.id == id) {
          return reminder.copyWith(status: ReminderStatus.dismissed);
        }
        return reminder;
      }).toList();

      state = state.copyWith(reminders: updatedReminders);
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to dismiss reminder',
      );
      return false;
    }
  }

  Future<bool> markAsSent(String id) async {
    final response = await ApiService.markReminderAsSent(id);

    if (response.success) {
      // Update local state immediately
      final updatedReminders = state.reminders.map((reminder) {
        if (reminder.id == id) {
          return reminder.copyWith(status: ReminderStatus.sent);
        }
        return reminder;
      }).toList();

      state = state.copyWith(reminders: updatedReminders);
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to mark reminder as sent',
      );
      return false;
    }
  }

  Future<List<Reminder>> getPendingReminders() async {
    final response = await ApiService.getPendingReminders();

    if (response.success && response.data != null) {
      return response.data!
          .map((json) => Reminder.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<bool> generateReminders() async {
    final response = await ApiService.generateReminders();

    if (response.success) {
      // Reload reminders to show generated ones
      await loadReminders();
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to generate reminders',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setFilter(String search) {
    loadReminders(search: search);
  }

  // Load more reminders for pagination
  Future<void> loadMoreReminders() async {
    if (state.hasMore && !state.isLoading) {
      await loadReminders(page: state.currentPage + 1);
    }
  }

  // Refresh reminders
  Future<void> refreshReminders() async {
    await loadReminders(page: 1);
  }

  // Filter reminders by type locally
  List<Reminder> getRemindersByType(ReminderType type) {
    return state.reminders.where((reminder) => reminder.type == type).toList();
  }

  // Filter reminders by status locally
  List<Reminder> getRemindersByStatus(ReminderStatus status) {
    return state.reminders.where((reminder) => reminder.status == status).toList();
  }

  // Get overdue reminders
  List<Reminder> getOverdueReminders() {
    return state.reminders.where((reminder) => reminder.isOverdue).toList();
  }

  // Get today's reminders
  List<Reminder> getTodaysReminders() {
    return state.reminders.where((reminder) => reminder.isDueToday).toList();
  }

  // Get upcoming reminders (next 7 days)
  List<Reminder> getUpcomingReminders() {
    return state.reminders.where((reminder) => reminder.isDueSoon).toList();
  }

  // Get reminder statistics
  Map<String, int> getReminderStats() {
    final stats = <String, int>{};

    // Count by status
    for (final status in ReminderStatus.values) {
      stats[status.toString().split('.').last] =
          state.reminders.where((reminder) => reminder.status == status).length;
    }

    // Count by type
    for (final type in ReminderType.values) {
      stats['${type.toString().split('.').last}_count'] =
          state.reminders.where((reminder) => reminder.type == type).length;
    }

    // Special counts
    stats['total'] = state.reminders.length;
    stats['overdue'] = getOverdueReminders().length;
    stats['today'] = getTodaysReminders().length;
    stats['upcoming'] = getUpcomingReminders().length;

    return stats;
  }
}

class RemindersState {
  final bool isLoading;
  final List<Reminder> reminders;
  final String? error;
  final bool hasMore;
  final int currentPage;

  RemindersState({
    required this.isLoading,
    required this.reminders,
    this.error,
    required this.hasMore,
    required this.currentPage,
  });

  factory RemindersState.initial() {
    return RemindersState(
      isLoading: false,
      reminders: [],
      hasMore: true,
      currentPage: 1,
    );
  }

  RemindersState copyWith({
    bool? isLoading,
    List<Reminder>? reminders,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return RemindersState(
      isLoading: isLoading ?? this.isLoading,
      reminders: reminders ?? this.reminders,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}