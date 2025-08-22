import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const ChartCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms)
                  .slideX(begin: -0.2, end: 0),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}