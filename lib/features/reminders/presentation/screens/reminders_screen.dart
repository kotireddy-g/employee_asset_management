import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/providers/reminders_provider.dart';
import '../../models/reminder.dart';
import '../widgets/reminder_card.dart';
import '../widgets/add_reminder_dialog.dart';
import '../../../../shared/presentation/widgets/search_filter_bar.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  String _currentSearch = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Load reminders when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remindersProvider.notifier).loadReminders();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterReminders() {
    final search = _searchController.text.trim();
    if (search != _currentSearch) {
      _currentSearch = search;
      ref.read(remindersProvider.notifier).setFilter(search);
    }
  }

  void _showAddReminderDialog() {
    showDialog(
      context: context,
      builder: (context) =>
          AddReminderDialog(
            onReminderAdded: (reminderData) async {
              final success = await ref
                  .read(remindersProvider.notifier)
                  .createReminder(reminderData.toJson());

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Reminder "${reminderData
                            .title}" added successfully!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
    );
  }

  Future<void> _generateReminders() async {
    final success = await ref
        .read(remindersProvider.notifier)
        .generateReminders();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Automatic reminders generated successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final remindersState = ref.watch(remindersProvider);

    // Show error if any
    ref.listen(remindersProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ref.read(remindersProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _buildHeader(remindersState),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(remindersProvider.notifier).loadReminders(),
              child: remindersState.isLoading &&
                  remindersState.reminders.isEmpty
                  ? _buildLoadingState()
                  : _buildRemindersList(remindersState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading reminders...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  int _getFilteredRemindersCount(List<Reminder> reminders) {
    return _getFilteredReminders(reminders).length;
  }

  List<Reminder> _getFilteredReminders(List<Reminder> reminders) {
    return reminders.where((reminder) {
      // Apply status filter
      if (_selectedType != 'All') {
        switch (_selectedType) {
          case 'Pending':
            if (reminder.status != ReminderStatus.pending) return false;
            break;
          case 'Sent':
            if (reminder.status != ReminderStatus.sent) return false;
            break;
          case 'Dismissed':
            if (reminder.status != ReminderStatus.dismissed) return false;
            break;
        }
      }
      return true;
    }).toList();
  }

  void _showReminderDetails(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reminder.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reminder.description),
              const SizedBox(height: 16),
              _buildDetailRow('Type', reminder.typeDisplayName),
              _buildDetailRow('Status', reminder.statusDisplayName),
              _buildDetailRow('Reminder Date', reminder.formattedReminderDate),
              _buildDetailRow('Time Until Due', reminder.timeUntilDue),
              if (reminder.isRecurring)
                _buildDetailRow('Recurring', reminder.recurringInterval ?? 'Yes'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildHeader(RemindersState remindersState) {
    final pendingCount = _getFilteredReminders(remindersState.reminders)
        .where((r) => r.status == ReminderStatus.pending)
        .length;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Reminders',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),
                      if (remindersState.isLoading && remindersState.reminders.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                      if (pendingCount > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$pendingCount pending',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                            .animate(onPlay: (controller) => controller.repeat())
                            .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1))
                            .then()
                            .scale(begin: const Offset(1.1, 1.1), end: const Offset(1.0, 1.0)),
                      ],
                    ],
                  ),
                  Text(
                    '${_getFilteredRemindersCount(remindersState.reminders)} reminders found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.3, end: 0),
                ],
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _showAddReminderDialog,
                icon: const Icon(Iconsax.add),
                label: const Text('Add Reminder'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SearchFilterBar(
            searchController: _searchController,
            selectedFilter: _selectedType,
            filterOptions: const ['All', 'Pending', 'Sent', 'Dismissed'],
            onSearchChanged: (value) => _filterReminders(),
            onFilterChanged: (value) {
              setState(() {
                _selectedType = value;
                _filterReminders();
              });
            },
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 600.ms)
              .slideY(begin: 0.3, end: 0),
        ],
      ),
    );

}

  Widget _buildRemindersList(RemindersState remindersState) {
    if (remindersState.reminders.isEmpty && !remindersState.isLoading) {
      return _buildEmptyState();
    }

    final filteredReminders = _getFilteredReminders(remindersState.reminders);

    if (filteredReminders.isEmpty) {
      return _buildNoResultsState();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: filteredReminders.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ReminderCard(
                      reminder: filteredReminders[index],
                      onTap: () => _showReminderDetails(filteredReminders[index]),
                      onEdit: () => _editReminder(filteredReminders[index]),
                      onDelete: () => _deleteReminder(filteredReminders[index]),
                      onDismiss: () => _dismissReminder(filteredReminders[index]),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _deleteReminder(Reminder reminder) {
    // Implement delete reminder
  }

  void _editReminder(Reminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AddReminderDialog(
        reminder: reminder,
        onReminderAdded: (reminderData) async {
          final success = await ref.read(remindersProvider.notifier)
              .updateReminder(reminder.id, reminderData.toJson());

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Reminder "${reminder.title}" updated successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  void _dismissReminder(Reminder reminder) async {
    final success = await ref.read(remindersProvider.notifier).dismissReminder(reminder.id);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Reminder "${reminder.title}" dismissed successfully!'),
            ],
          ),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new reminder to get started',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddReminderDialog,
            icon: const Icon(Iconsax.add),
            label: const Text('Add First Reminder'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(begin: const Offset(0.8, 0.8));
  }


}