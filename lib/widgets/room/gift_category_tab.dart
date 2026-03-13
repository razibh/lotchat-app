import 'package:flutter/material.dart';

class GiftCategoryTab extends StatelessWidget {

  const GiftCategoryTab({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final String category = categories[index];
          final bool isSelected = category == selectedCategory;
          
          final var categoryColor = _getCategoryColor(category);
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: <>[categoryColor, categoryColor.withOpacity(0.7)],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: <>[
                    Icon(
                      _getCategoryIcon(category),
                      size: 16,
                      color: isSelected ? Colors.white : categoryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cute':
        return Icons.favorite;
      case 'Luxury':
        return Icons.diamond;
      case 'VIP':
        return Icons.star;
      case 'SVIP':
        return Icons.auto_awesome;
      case 'Special':
        return Icons.card_giftcard;
      case 'Limited':
        return Icons.timer;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Cute':
        return Colors.pink;
      case 'Luxury':
        return Colors.amber;
      case 'VIP':
        return Colors.purple;
      case 'SVIP':
        return Colors.deepPurple;
      case 'Special':
        return Colors.red;
      case 'Limited':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}