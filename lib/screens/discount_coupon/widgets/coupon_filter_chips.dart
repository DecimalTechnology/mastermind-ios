import 'package:flutter/material.dart';
import 'package:master_mind/utils/const.dart';

class CouponFilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function(int) onDiscountChanged;

  const CouponFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onDiscountChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Restaurant Filter Chips
        Text(
          'Restaurants',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All', selectedFilter == 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('KFC', selectedFilter == 'KFC'),
              const SizedBox(width: 8),
              _buildFilterChip('McDonald\'s', selectedFilter == 'McDonald\'s'),
              const SizedBox(width: 8),
              _buildFilterChip('Pizza Hut', selectedFilter == 'Pizza Hut'),
              const SizedBox(width: 8),
              _buildFilterChip('Subway', selectedFilter == 'Subway'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Discount Filter Chips
        Text(
          'Discount Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildDiscountChip('All', 0),
              const SizedBox(width: 8),
              _buildDiscountChip('10%+', 10),
              const SizedBox(width: 8),
              _buildDiscountChip('20%+', 20),
              const SizedBox(width: 8),
              _buildDiscountChip('30%+', 30),
              const SizedBox(width: 8),
              _buildDiscountChip('50%+', 50),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => onFilterChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kOxygenMMPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kOxygenMMPurple : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountChip(String label, int minDiscount) {
    final isSelected =
        minDiscount == 0; // You can implement proper selection logic here

    return GestureDetector(
      onTap: () => onDiscountChanged(minDiscount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kOxygenMMPurple : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kOxygenMMPurple : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
