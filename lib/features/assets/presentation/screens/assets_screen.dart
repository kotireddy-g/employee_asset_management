import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/providers/assets_provider.dart';
import '../../models/asset.dart';
import '../widgets/asset_card.dart';
import '../widgets/add_asset_dialog.dart';
import '../../../../shared/presentation/widgets/search_filter_bar.dart';

class AssetsScreen extends ConsumerStatefulWidget {
  const AssetsScreen({super.key});

  @override
  ConsumerState<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends ConsumerState<AssetsScreen>
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

    // Load assets when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assetsProvider.notifier).loadAssets();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterAssets() {
    final search = _searchController.text.trim();
    if (search != _currentSearch) {
      _currentSearch = search;
      ref.read(assetsProvider.notifier).setFilter(search);
    }
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAssetDialog(
        onAssetAdded: (assetData) async {
          final success = await ref.read(assetsProvider.notifier).createAsset(assetData.toJson());

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Asset "${assetData.deviceId}" added successfully!'),
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
    final assetsState = ref.watch(assetsProvider);

    // Show error if any
    ref.listen(assetsProvider, (previous, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Colors.white,
              onPressed: () {
                ref.read(assetsProvider.notifier).clearError();
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
          _buildHeader(assetsState),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(assetsProvider.notifier).loadAssets(),
              child: assetsState.isLoading && assetsState.assets.isEmpty
                  ? _buildLoadingState()
                  : _buildAssetsList(assetsState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AssetsState assetsState) {
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
                        'Asset Management',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideX(begin: -0.3, end: 0),
                      if (assetsState.isLoading && assetsState.assets.isNotEmpty) ...[
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
                    '${_getFilteredAssetsCount(assetsState.assets)} assets found',
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
                onPressed: _showAddAssetDialog,
                icon: const Icon(Iconsax.add),
                label: const Text('Add Asset'),
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
            filterOptions: const ['All', 'Laptop', 'Desktop', 'Mobile', 'Tablet'],
            onSearchChanged: (value) => _filterAssets(),
            onFilterChanged: (value) {
              setState(() {
                _selectedType = value;
                _filterAssets();
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
            'Loading assets...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList(AssetsState assetsState) {
    if (assetsState.assets.isEmpty && !assetsState.isLoading) {
      return _buildEmptyState();
    }

    final filteredAssets = _applyLocalFilters(assetsState.assets);

    if (filteredAssets.isEmpty) {
      return _buildNoResultsState();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: AnimationLimiter(
        child: GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.92,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: filteredAssets.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 600),
              columnCount: 3,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: AssetCard(
                    asset: filteredAssets[index],
                    onTap: () => _showAssetDetails(filteredAssets[index]),
                    onEdit: () => _editAsset(filteredAssets[index]),
                    onDelete: () => _deleteAsset(filteredAssets[index]),
                    onAssign: () => _assignAsset(filteredAssets[index]),
                    onReturn: () => _returnAsset(filteredAssets[index]),
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
            Iconsax.monitor,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No assets found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first asset to get started',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddAssetDialog,
            icon: const Icon(Iconsax.add),
            label: const Text('Add First Asset'),
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
            'No assets found',
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

  int _getFilteredAssetsCount(List<Asset> assets) {
    return _applyLocalFilters(assets).length;
  }

  List<Asset> _applyLocalFilters(List<Asset> assets) {
    return assets.where((asset) {
      // Apply type filter
      if (_selectedType != 'All' &&
          asset.type.toString().split('.').last.toLowerCase() != _selectedType.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showAssetDetails(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asset.deviceId),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Type', asset.type.toString().split('.').last.toUpperCase()),
              _buildDetailRow('Brand', asset.brand),
              _buildDetailRow('Model', asset.model),
              _buildDetailRow('Serial No', asset.serialNo),
              _buildDetailRow('Status', asset.status.toString().split('.').last.toUpperCase()),
              if (asset.assignedTo != null) ...[
                _buildDetailRow('Assigned To', asset.assignedTo!),
                if (asset.assignedDate != null)
                  _buildDetailRow('Assigned Date',
                      '${asset.assignedDate!.day}/${asset.assignedDate!.month}/${asset.assignedDate!.year}'),
              ],
              if (asset.ram != null) _buildDetailRow('RAM', asset.ram!),
              if (asset.storage != null) _buildDetailRow('Storage', asset.storage!),
              if (asset.processor != null) _buildDetailRow('Processor', asset.processor!),
              if (asset.operatingSystem != null) _buildDetailRow('OS', asset.operatingSystem!),
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
            width: 100,
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

  void _editAsset(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AddAssetDialog(
        asset: asset,
        onAssetAdded: (assetData) async {
          final success = await ref.read(assetsProvider.notifier)
              .updateAsset(asset.id, assetData.toJson());

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    Text('Asset "${asset.deviceId}" updated successfully!'),
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

  void _deleteAsset(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Are you sure you want to delete ${asset.deviceId}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await ref.read(assetsProvider.notifier)
                  .deleteAsset(asset.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Asset "${asset.deviceId}" deleted successfully!'),
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

  void _assignAsset(Asset asset) {
    if (asset.status != AssetStatus.available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asset is not available for assignment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show employee selection dialog
    _showAssignAssetDialog(asset);
  }

  void _showAssignAssetDialog(Asset asset) {
    final TextEditingController employeeIdController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assign ${asset.deviceId}'),
        content: Column(
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
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Assignment notes',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (employeeIdController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Employee ID is required'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.of(context).pop();

              final success = await ref.read(assetsProvider.notifier).assignAsset(
                asset.id,
                employeeIdController.text.trim(),
                notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                asset.type.name,
                asset.deviceId
              );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Asset "${asset.deviceId}" assigned successfully!'),
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

  void _returnAsset(Asset asset) {
    if (asset.status != AssetStatus.assigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Asset is not currently assigned'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showReturnAssetDialog(asset);
  }

  void _showReturnAssetDialog(Asset asset) {
    final TextEditingController conditionController = TextEditingController();
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Return ${asset.deviceId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: conditionController,
              decoration: const InputDecoration(
                labelText: 'Condition',
                hintText: 'Asset condition on return',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Return',
                hintText: 'Why is this asset being returned?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              final success = await ref.read(assetsProvider.notifier).returnAsset(
                asset.id,
                conditionController.text.trim().isEmpty ? null : conditionController.text.trim(),
                reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
              );

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('Asset "${asset.deviceId}" returned successfully!'),
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
            child: const Text('Return'),
          ),
        ],
      ),
    );
  }
}