import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class DocumentTemplatesGrid extends StatelessWidget {
  const DocumentTemplatesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Document Templates',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3, end: 0),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildTemplateCard(
              title: 'Asset Handover Report',
              description: 'Generate asset handover documents for new employees',
              icon: Iconsax.document_text,
              color: const Color(0xFF6366F1),
              onTap: () => _showEmployeeSelector(context, 'asset_handover'),
            ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
            _buildTemplateCard(
              title: 'No Dues Certificate',
              description: 'Generate exit clearance documents for departing employees',
              icon: Iconsax.document_text_1,
              color: const Color(0xFFEF4444),
              onTap: () => _showEmployeeSelector(context, 'no_dues'),
            ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
            _buildTemplateCard(
              title: 'Asset Assignment Letter',
              description: 'Generate formal asset assignment letters',
              icon: Iconsax.document_download,
              color: Colors.green,
              onTap: () => _showComingSoon(context),
            ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.8, 0.8)),
            _buildTemplateCard(
              title: 'Employee Reports',
              description: 'Generate comprehensive employee reports',
              icon: Iconsax.chart,
              color: Colors.orange,
              onTap: () => _showComingSoon(context),
            ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
          ],
        ),
      ],
    );
  }

  Widget _buildTemplateCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmployeeSelector(BuildContext context, String documentType) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Employee',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Employee selector will be implemented with the employees list',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This feature is coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}