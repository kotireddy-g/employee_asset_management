// lib/features/assets/presentation/widgets/add_asset_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/asset.dart';

class AddAssetDialog extends StatefulWidget {
  final Function(Asset) onAssetAdded;
  final Asset? asset; // For editing existing assets

  const AddAssetDialog({
    super.key,
    required this.onAssetAdded,
    this.asset,
  });

  @override
  State<AddAssetDialog> createState() => _AddAssetDialogState();
}

class _AddAssetDialogState extends State<AddAssetDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _serialNoController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _processorController = TextEditingController();
  final _osController = TextEditingController();
  final _macAddressController = TextEditingController();
  final _purchaseCostController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otherDetailsController = TextEditingController();

  AssetType _selectedType = AssetType.laptop;
  AssetStatus _selectedStatus = AssetStatus.available;
  String _selectedWorkingStatus = 'Working';
  bool _crowdstrikeInstalled = false;
  bool _vpnConfigured = false;
  DateTime? _billDate;

  late AnimationController _animationController;

  final List<String> _workingStatuses = [
    'Working',
    'Not Working',
    'Partially Working',
    'Needs Repair'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Pre-fill form if editing existing asset
    if (widget.asset != null) {
      _populateFormFromAsset(widget.asset!);
    }

    _animationController.forward();
  }

  void _populateFormFromAsset(Asset asset) {
    _deviceIdController.text = asset.deviceId;
    _brandController.text = asset.brand;
    _modelController.text = asset.model;
    _serialNoController.text = asset.serialNo;
    _ramController.text = asset.ram ?? '';
    _storageController.text = asset.storage ?? '';
    _processorController.text = asset.processor ?? '';
    _osController.text = asset.operatingSystem ?? '';
    _macAddressController.text = asset.macAddress ?? '';
    _purchaseCostController.text = asset.purchaseCost?.toString() ?? '';
    _passwordController.text = asset.password ?? '';
    _otherDetailsController.text = asset.otherDetails ?? '';

    _selectedType = asset.type;
    _selectedStatus = asset.status;
    _selectedWorkingStatus = asset.workingStatus ?? 'Working';
    _crowdstrikeInstalled = asset.crowdstrikeInstalled;
    _vpnConfigured = asset.vpnConfigured;
    _billDate = asset.billDate;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _deviceIdController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _serialNoController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _processorController.dispose();
    _osController.dispose();
    _macAddressController.dispose();
    _purchaseCostController.dispose();
    _passwordController.dispose();
    _otherDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.asset != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 700,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isEditing),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildFormFields(),
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButtons(isEditing),
            ],
          ),
        ),
      )
          .animate(controller: _animationController)
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0))
          .slideY(begin: 0.2, end: 0),
    );
  }

  Widget _buildHeader(bool isEditing) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isEditing ? Iconsax.edit : Iconsax.add,
            color: const Color(0xFF6366F1),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Asset' : 'Add New Asset',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                isEditing ? 'Update asset details' : 'Fill in the asset details below',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideX(begin: -0.3, end: 0);
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        // Basic Information Section
        _buildSectionHeader('Basic Information'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID *',
                  prefixIcon: Icon(Iconsax.code),
                  hintText: 'e.g., LTP-001',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device ID';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<AssetType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Asset Type *',
                  prefixIcon: Icon(Iconsax.category),
                ),
                items: AssetType.values.map((AssetType type) {
                  return DropdownMenuItem<AssetType>(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (AssetType? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideX(begin: 0.3, end: 0),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Brand *',
                  prefixIcon: Icon(Iconsax.tag),
                  hintText: 'e.g., Apple, Dell, HP',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter brand';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms)
                  .slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Model *',
                  prefixIcon: Icon(Iconsax.cpu),
                  hintText: 'e.g., MacBook Pro M2',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter model';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideX(begin: 0.3, end: 0),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _serialNoController,
                decoration: const InputDecoration(
                  labelText: 'Serial Number *',
                  prefixIcon: Icon(Iconsax.scan_barcode),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter serial number';
                  }
                  return null;
                },
              )
                  .animate()
                  .fadeIn(delay: 600.ms, duration: 400.ms)
                  .slideX(begin: -0.3, end: 0),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<AssetStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Iconsax.flag),
                ),
                items: AssetStatus.values.map((AssetStatus status) {
                  return DropdownMenuItem<AssetStatus>(
                    value: status,
                    child: Text(status.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (AssetStatus? newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 400.ms)
                  .slideX(begin: 0.3, end: 0),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Technical Specifications Section
        _buildSectionHeader('Technical Specifications'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ramController,
                decoration: const InputDecoration(
                  labelText: 'RAM',
                  prefixIcon: Icon(Iconsax.cpu_charge),
                  hintText: 'e.g., 16GB',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _storageController,
                decoration: const InputDecoration(
                  labelText: 'Storage',
                  prefixIcon: Icon(Icons.storage),
                  hintText: 'e.g., 512GB SSD',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _processorController,
                decoration: const InputDecoration(
                  labelText: 'Processor',
                  prefixIcon: Icon(Iconsax.cpu),
                  hintText: 'e.g., Intel i7, Apple M2',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _osController,
                decoration: const InputDecoration(
                  labelText: 'Operating System',
                  prefixIcon: Icon(Iconsax.monitor),
                  hintText: 'e.g., Windows 11, macOS',
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _macAddressController,
                decoration: const InputDecoration(
                  labelText: 'MAC Address',
                  prefixIcon: Icon(Iconsax.wifi),
                  hintText: 'e.g., 00:1B:44:11:3A:B7',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedWorkingStatus,
                decoration: const InputDecoration(
                  labelText: 'Working Status',
                  prefixIcon: Icon(Iconsax.status),
                ),
                items: _workingStatuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedWorkingStatus = newValue!;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Security & Configuration Section
        _buildSectionHeader('Security & Configuration'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('CrowdStrike Installed'),
                value: _crowdstrikeInstalled,
                onChanged: (bool? value) {
                  setState(() {
                    _crowdstrikeInstalled = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('VPN Configured'),
                value: _vpnConfigured,
                onChanged: (bool? value) {
                  setState(() {
                    _vpnConfigured = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextFormField(
          controller: _passwordController,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Iconsax.lock),
            hintText: 'Device password (if applicable)',
          ),
          obscureText: true,
        ),

        const SizedBox(height: 32),

        // Financial Information Section
        _buildSectionHeader('Financial Information'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _purchaseCostController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Cost',
                  prefixIcon: Icon(Iconsax.dollar_circle),
                  hintText: 'e.g., 1500.00',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Bill Date',
                    prefixIcon: Icon(Iconsax.calendar),
                  ),
                  child: Text(
                    _billDate != null
                        ? '${_billDate!.day}/${_billDate!.month}/${_billDate!.year}'
                        : 'Select date',
                    style: TextStyle(
                      color: _billDate != null ? Colors.black87 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Additional Information Section
        _buildSectionHeader('Additional Information'),
        const SizedBox(height: 16),

        TextFormField(
          controller: _otherDetailsController,
          decoration: const InputDecoration(
            labelText: 'Other Details',
            prefixIcon: Icon(Iconsax.note),
            hintText: 'Any additional notes or specifications',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _saveAsset,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(isEditing ? 'Update Asset' : 'Add Asset'),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 400.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _billDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _billDate) {
      setState(() {
        _billDate = picked;
      });
    }
  }

  void _saveAsset() {
    if (_formKey.currentState!.validate()) {
      final asset = Asset(
        id: widget.asset?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        deviceId: _deviceIdController.text.trim(),
        type: _selectedType,
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        serialNo: _serialNoController.text.trim(),
        status: _selectedStatus,
        ram: _ramController.text.trim().isEmpty ? null : _ramController.text.trim(),
        storage: _storageController.text.trim().isEmpty ? null : _storageController.text.trim(),
        processor: _processorController.text.trim().isEmpty ? null : _processorController.text.trim(),
        operatingSystem: _osController.text.trim().isEmpty ? null : _osController.text.trim(),
        macAddress: _macAddressController.text.trim().isEmpty ? null : _macAddressController.text.trim(),
        crowdstrikeInstalled: _crowdstrikeInstalled,
        vpnConfigured: _vpnConfigured,
        workingStatus: _selectedWorkingStatus,
        billDate: _billDate,
        purchaseCost: _purchaseCostController.text.trim().isEmpty
            ? null
            : double.tryParse(_purchaseCostController.text.trim()),
        password: _passwordController.text.trim().isEmpty ? null : _passwordController.text.trim(),
        otherDetails: _otherDetailsController.text.trim().isEmpty ? null : _otherDetailsController.text.trim(),
        createdAt: widget.asset?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onAssetAdded(asset);
      Navigator.of(context).pop();
    }
  }
}