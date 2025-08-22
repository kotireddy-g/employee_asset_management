import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final List<String> filterOptions;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  const SearchFilterBar({
    super.key,
    required this.searchController,
    required this.selectedFilter,
    required this.filterOptions,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButton<String>(
            value: selectedFilter,
            onChanged: (value) => onFilterChanged(value!),
            underline: const SizedBox(),
            icon: Icon(Iconsax.arrow_down_1, color: Colors.grey.shade600),
            items: filterOptions.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}