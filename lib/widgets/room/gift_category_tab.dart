import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GiftCategoryTab extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const GiftCategoryTab({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) {
          final String category = categories[index];
          final bool isSelected = category == selectedCategory;

          final Color categoryColor = _getCategoryColor(category);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onCategorySelected(category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                    colors: [categoryColor, categoryColor.withOpacity(0.7)],
                  )
                      : null,
                  color: isSelected ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
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
      case 'Flowers':
        return Icons.local_florist;
      case 'Jewelry':
        return Icons.ring_volume;
      case 'Cars':
        return Icons.directions_car;
      case 'Pets':
        return Icons.pets;
      case 'Food':
        return Icons.fastfood;
      case 'Drinks':
        return Icons.local_drink;
      case 'Travel':
        return Icons.flight;
      case 'Fashion':
        return Icons.checkroom;
      case 'Tech':
        return Icons.computer;
      case 'Sports':
        return Icons.sports_esports;
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
      case 'Flowers':
        return Colors.pink.shade300;
      case 'Jewelry':
        return Colors.amber.shade700;
      case 'Cars':
        return Colors.blue;
      case 'Pets':
        return Colors.brown;
      case 'Food':
        return Colors.green;
      case 'Drinks':
        return Colors.teal;
      case 'Travel':
        return Colors.indigo;
      case 'Fashion':
        return Colors.purple.shade400;
      case 'Tech':
        return Colors.cyan;
      case 'Sports':
        return Colors.lime;
      default:
        return Colors.blue;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('categories', categories));
    properties.add(StringProperty('selectedCategory', selectedCategory));
    properties.add(ObjectFlagProperty<Function(String)>.has('onCategorySelected', onCategorySelected));
  }
}

// Gift Category Grid
class GiftCategoryGrid extends StatelessWidget {
  final List<GiftCategoryItem> categories;
  final String? selectedCategoryId;
  final Function(GiftCategoryItem) onCategorySelected;

  const GiftCategoryGrid({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = category.id == selectedCategoryId;

        return GestureDetector(
          onTap: () => onCategorySelected(category),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? category.color.withOpacity(0.2) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? category.color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category.icon,
                  color: isSelected ? category.color : Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? category.color : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<GiftCategoryItem>('categories', categories));
    properties.add(StringProperty('selectedCategoryId', selectedCategoryId));
  }
}

class GiftCategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  GiftCategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

// Gift Category Chip
class GiftCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const GiftCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('label', label));
    properties.add(DiagnosticsProperty<bool>('isSelected', isSelected));
    properties.add(DiagnosticsProperty<IconData?>('icon', icon));
  }
}