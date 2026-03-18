import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class GiftComboSelector extends StatelessWidget {
  final int multiplier;
  final Function(int) onChanged;
  final List<int> options;
  final Color primaryColor;

  const GiftComboSelector({
    super.key,
    required this.multiplier,
    required this.onChanged,
    this.options = const [1, 5, 10, 99],
    this.primaryColor = Colors.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Send:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          ...options.map((value) => _buildMultiplierButton(value)).toList(),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${multiplier}x',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplierButton(int value) {
    final bool isSelected = multiplier == value;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: primaryColor, width: 2)
              : null,
        ),
        child: Text(
          '$value',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('multiplier', multiplier));
    properties.add(ObjectFlagProperty<Function(int)>.has('onChanged', onChanged));
    properties.add(IterableProperty<int>('options', options));
    properties.add(ColorProperty('primaryColor', primaryColor));
  }
}

// Custom combo selector with custom amount
class GiftComboSelectorWithCustom extends StatefulWidget {
  final int multiplier;
  final Function(int) onChanged;
  final List<int> options;
  final Color primaryColor;

  const GiftComboSelectorWithCustom({
    super.key,
    required this.multiplier,
    required this.onChanged,
    this.options = const [1, 5, 10, 50, 100],
    this.primaryColor = Colors.purple,
  });

  @override
  State<GiftComboSelectorWithCustom> createState() => _GiftComboSelectorWithCustomState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('multiplier', multiplier));
    properties.add(IterableProperty<int>('options', options));
    properties.add(ColorProperty('primaryColor', primaryColor));
  }
}

class _GiftComboSelectorWithCustomState extends State<GiftComboSelectorWithCustom> {
  final TextEditingController _customController = TextEditingController();
  bool _showCustomInput = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Quantity:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...widget.options.map((value) => _buildPresetButton(value)).toList(),
              _buildCustomButton(),
            ],
          ),
          if (_showCustomInput) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (value) {
                      final int? customValue = int.tryParse(value);
                      if (customValue != null && customValue > 0) {
                        widget.onChanged(customValue);
                        setState(() {
                          _showCustomInput = false;
                          _customController.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.check, color: widget.primaryColor),
                  onPressed: () {
                    final int? customValue = int.tryParse(_customController.text);
                    if (customValue != null && customValue > 0) {
                      widget.onChanged(customValue);
                      setState(() {
                        _showCustomInput = false;
                        _customController.clear();
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _showCustomInput = false;
                      _customController.clear();
                    });
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.card_giftcard, size: 16, color: Colors.purple),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.multiplier} ×',
                      style: TextStyle(
                        color: widget.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButton(int value) {
    final bool isSelected = widget.multiplier == value;

    return GestureDetector(
      onTap: () => widget.onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? widget.primaryColor : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: widget.primaryColor, width: 2)
              : null,
        ),
        child: Text(
          '$value',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showCustomInput = !_showCustomInput;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 14),
            SizedBox(width: 4),
            Text(
              'Custom',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }
}

// Gift combo with total price display
class GiftComboWithPrice extends StatelessWidget {
  final int multiplier;
  final int pricePerItem;
  final Function(int) onChanged;
  final List<int> options;
  final Color primaryColor;

  const GiftComboWithPrice({
    super.key,
    required this.multiplier,
    required this.pricePerItem,
    required this.onChanged,
    this.options = const [1, 5, 10, 99],
    this.primaryColor = Colors.purple,
  });

  @override
  Widget build(BuildContext context) {
    final totalPrice = multiplier * pricePerItem;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantity & Total:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ...options.map((value) => _buildOption(value)).toList(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$totalPrice',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${multiplier} × ${pricePerItem}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int value) {
    final bool isSelected = multiplier == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: primaryColor, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('multiplier', multiplier));
    properties.add(IntProperty('pricePerItem', pricePerItem));
    properties.add(IterableProperty<int>('options', options));
  }
}