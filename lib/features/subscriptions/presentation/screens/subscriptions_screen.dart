import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/providers/subscriptions_provider.dart';
import '../../models/subscription.dart';
import '../widgets/subscription_card.dart';
import '../widgets/add_subscription_dialog.dart';
import '../../../../shared/presentation/widgets/search_filter_bar.dart';

class SubscriptionsScreen extends ConsumerStatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  ConsumerState<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends ConsumerState<SubscriptionsScreen>
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

    // Load subscriptions when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscriptionsProvider.notifier).loadSubscriptions();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubscriptions() {
    final search = _searchController.text.trim();
    if (search != _currentSearch) {
      _currentSearch = search;
      ref.read(subscriptionsProvider.notifier).setFilter(search);
    }
  }

  void _showAddSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AddSubscriptionDialog(
        onSubscriptionAdded: (subscriptionData) async {
          final success = await ref.read(subscriptionsProvider.notifier).createSubscription(subscriptionData.toJson());

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Subscription "${subscriptionData.name}" added successfully!'),
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

  @override
  Widget build(BuildContext context) {
    final subscriptionsState = ref.watch(subscriptionsProvider);

    // Show error if any
    ref.listen(subscriptionsProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ref.read(subscriptionsProvider.notifier).clearError();
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
          _buildHeader(subscriptionsState),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(subscriptionsProvider.notifier).loadSubscriptions(),
              child: subscriptionsState.isLoading && subscriptionsState.subscriptions.isEmpty
                  ? _buildLoadingState()
                  : _buildSubscriptionsList(subscriptionsState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(SubscriptionsState subscriptionsState) {
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
                        'Subscriptions',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),
                      if (subscriptionsState.isLoading && subscriptionsState.subscriptions.isNotEmpty) ...[
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
                    ],
                  ),
                  Text(
                    '${_getFilteredSubscriptionsCount(subscriptionsState.subscriptions)} subscriptions found',
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
              ElevatedButton.icon(
                onPressed: _showAddSubscriptionDialog,
                icon: const Icon(Iconsax.add),
                label: const Text('Add Subscription'),
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
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
          const SizedBox(height: 20),
          SearchFilterBar(
            searchController: _searchController,
            selectedFilter: _selectedType,
            filterOptions: const ['All', 'Software', 'Service', 'License', 'Other'],
            onSearchChanged: (value) => _filterSubscriptions(),
            onFilterChanged: (value) {
              setState(() {
                _selectedType = value;
                _filterSubscriptions();
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
            'Loading subscriptions...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList(SubscriptionsState subscriptionsState) {
    if (subscriptionsState.subscriptions.isEmpty && !subscriptionsState.isLoading) {
      return _buildEmptyState();
    }

    final filteredSubscriptions = _applyLocalFilters(subscriptionsState.subscriptions);

    if (filteredSubscriptions.isEmpty) {
      return _buildNoResultsState();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.95,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: filteredSubscriptions.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: 3,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: SubscriptionCard(
                    subscription: filteredSubscriptions[index],
                    onTap: () => _showSubscriptionDetails(filteredSubscriptions[index]),
                    onEdit: () => _editSubscription(filteredSubscriptions[index]),
                    onDelete: () => _deleteSubscription(filteredSubscriptions[index]),
                    onAssign: () => _assignSubscription(filteredSubscriptions[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subscriptions,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No subscriptions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first subscription to get started',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddSubscriptionDialog,
            icon: const Icon(Iconsax.add),
            label: const Text('Add First Subscription'),
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
            'No subscriptions found',
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

  int _getFilteredSubscriptionsCount(List<Subscription> subscriptions) {
    return _applyLocalFilters(subscriptions).length;
  }

  List<Subscription> _applyLocalFilters(List<Subscription> subscriptions) {
    return subscriptions.where((subscription) {
      // Apply type filter
      if (_selectedType != 'All' &&
          subscription.type.toString().split('.').last.toLowerCase() != _selectedType.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showSubscriptionDetails(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subscription.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Provider', subscription.provider),
              _buildDetailRow('Type', subscription.typeDisplayName),
              _buildDetailRow('Cost', subscription.formattedCost),
              _buildDetailRow('Billing Cycle', subscription.billingDisplayName),
              _buildDetailRow('Status', subscription.statusDisplayName),
              _buildDetailRow('Start Date', '${subscription.startDate.day}/${subscription.startDate.month}/${subscription.startDate.year}'),
              _buildDetailRow('End Date', '${subscription.endDate.day}/${subscription.endDate.month}/${subscription.endDate.year}'),
              _buildDetailRow('Users', '${subscription.currentUsers}/${subscription.maxUsers}'),
              _buildDetailRow('Available Slots', '${subscription.availableSlots}'),
              if (subscription.description != null)
                _buildDetailRow('Description', subscription.description!),
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

  void _editSubscription(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AddSubscriptionDialog(
        subscription: subscription,
        onSubscriptionAdded: (subscriptionData) async {
          final success = await ref.read(subscriptionsProvider.notifier)
              .updateSubscription(subscription.id, subscriptionData.toJson());

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Subscription "${subscription.name}" updated successfully!'),
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

  void _deleteSubscription(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subscription'),
        content: Text('Are you sure you want to delete ${subscription.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await ref.read(subscriptionsProvider.notifier)
                  .deleteSubscription(subscription.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Subscription "${subscription.name}" deleted successfully!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _assignSubscription(Subscription subscription) {
    if (subscription.availableSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available slots for this subscription'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showAssignSubscriptionDialog(subscription);
  }

  void _showAssignSubscriptionDialog(Subscription subscription) {
    final TextEditingController employeeIdController = TextEditingController();
    final TextEditingController loginIdController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign ${subscription.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: employeeIdController,
                decoration: const InputDecoration(
                  labelText: 'Employee ID',
                  hintText: 'Enter employee ID',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: loginIdController,
                decoration: const InputDecoration(
                  labelText: 'Login ID',
                  hintText: 'Enter login ID for the subscription',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password for the subscription',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Assignment notes',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Available slots: ${subscription.availableSlots}/${subscription.maxUsers}',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (employeeIdController.text.trim().isEmpty ||
                  loginIdController.text.trim().isEmpty ||
                  passwordController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employee ID, Login ID, and Password are required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              final success = await ref.read(subscriptionsProvider.notifier).assignSubscription(
                subscription.id,
                employeeIdController.text.trim(),
                loginIdController.text.trim(),
                passwordController.text.trim(),
                notesController.text.trim().isEmpty ? null : notesController.text.trim(),
              );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Subscription "${subscription.name}" assigned successfully!'),
                      ],
                    ),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}