import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/admin_service.dart';
import '../../core/models/gift_model.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class GiftManagement extends StatefulWidget {
  const GiftManagement({Key? key}) : super(key: key);

  @override
  State<GiftManagement> createState() => _GiftManagementState();
}

class _GiftManagementState extends State<GiftManagement> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final _adminService = ServiceLocator().get<AdminService>();
  
  List<GiftModel> _gifts = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  final List<String> _categories = ['All', 'Cute', 'Luxury', 'VIP', 'SVIP', 'Special'];

  @override
  void initState() {
    super.initState();
    _loadGifts();
  }

  Future<void> _loadGifts() async {
    await runWithLoading(() async {
      try {
        _gifts = GiftModel.getGifts();
      } catch (e) {
        showError('Failed to load gifts: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  List<GiftModel> get _filteredGifts {
    if (_selectedCategory == 'All') {
      return _gifts;
    }
    return _gifts.where((g) => g.category == _selectedCategory).toList();
  }

  Future<void> _addGift() async {
    // Show add gift form
    showDialog(
      context: context,
      builder: (context) => const AddGiftDialog(),
    ).then((value) {
      if (value == true) {
        _loadGifts();
      }
    });
  }

  Future<void> _editGift(GiftModel gift) async {
    // Show edit gift form
    showDialog(
      context: context,
      builder: (context) => EditGiftDialog(gift: gift),
    ).then((value) {
      if (value == true) {
        _loadGifts();
      }
    });
  }

  Future<void> _deleteGift(GiftModel gift) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Gift',
      message: 'Are you sure you want to delete ${gift.name}?',
    );

    if (confirmed == true) {
      await runWithLoading(() async {
        try {
          await _adminService.deleteGift(gift.id);
          showSuccess('Gift deleted successfully');
          _loadGifts();
        } catch (e) {
          showError('Failed to delete gift: $e');
        }
      });
    }
  }

  Future<void> _uploadSound(GiftModel gift) async {
    // Upload sound file
    showSuccess('Sound uploaded (demo)');
  }

  Future<void> _uploadAnimation(GiftModel gift) async {
    // Upload animation file
    showSuccess('Animation uploaded (demo)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Management'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addGift,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white.withOpacity(0.2),
                    selectedColor: Colors.white,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category ? Colors.purple : Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _filteredGifts.length,
              itemBuilder: (context, index) {
                final gift = _filteredGifts[index];
                return _buildGiftCard(gift);
              },
            ),
    );
  }

  Widget _buildGiftCard(GiftModel gift) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gift Preview
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: _getCategoryColor(gift.category).withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: Icon(
                  Icons.card_giftcard,
                  size: 50,
                  color: _getCategoryColor(gift.category),
                ),
              ),
            ),
          ),

          // Gift Info
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gift.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (gift.isVip)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        ),
                      if (gift.isSvip)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.purple, Colors.pink],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SVIP',
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gift.price} coins',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPriceColor(gift.price),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gift.category,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  const Spacer(),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16),
                        onPressed: () => _editGift(gift),
                      ),
                      IconButton(
                        icon: const Icon(Icons.music_note, size: 16),
                        onPressed: () => _uploadSound(gift),
                      ),
                      IconButton(
                        icon: const Icon(Icons.animation, size: 16),
                        onPressed: () => _uploadAnimation(gift),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                        onPressed: () => _deleteGift(gift),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
      default:
        return Colors.blue;
    }
  }

  Color _getPriceColor(int price) {
    if (price >= 50000) return Colors.purple;
    if (price >= 10000) return Colors.red;
    if (price >= 5000) return Colors.orange;
    return Colors.green;
  }
}

// Add Gift Dialog
class AddGiftDialog extends StatefulWidget {
  const AddGiftDialog({Key? key}) : super(key: key);

  @override
  State<AddGiftDialog> createState() => _AddGiftDialogState();
}

class _AddGiftDialogState extends State<AddGiftDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String _selectedCategory = 'Cute';
  bool _isVip = false;
  bool _isSvip = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Gift'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Gift Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter gift name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _priceController,
                label: 'Price (coins)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Cute', 'Luxury', 'VIP', 'SVIP', 'Special'].map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('VIP Gift'),
                value: _isVip,
                onChanged: (value) {
                  setState(() {
                    _isVip = value;
                    if (value) _isSvip = false;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('SVIP Gift'),
                value: _isSvip,
                onChanged: (value) {
                  setState(() {
                    _isSvip = value;
                    if (value) _isVip = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Add Gift'),
        ),
      ],
    );
  }
}

// Edit Gift Dialog
class EditGiftDialog extends StatefulWidget {
  final GiftModel gift;

  const EditGiftDialog({Key? key, required this.gift}) : super(key: key);

  @override
  State<EditGiftDialog> createState() => _EditGiftDialogState();
}

class _EditGiftDialogState extends State<EditGiftDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late String _selectedCategory;
  late bool _isVip;
  late bool _isSvip;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift.name);
    _priceController = TextEditingController(text: widget.gift.price.toString());
    _selectedCategory = widget.gift.category;
    _isVip = widget.gift.isVip;
    _isSvip = widget.gift.isSvip;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Gift'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'Gift Name',
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _priceController,
              label: 'Price (coins)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ['Cute', 'Luxury', 'VIP', 'SVIP', 'Special'].map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('VIP Gift'),
              value: _isVip,
              onChanged: (value) {
                setState(() {
                  _isVip = value;
                  if (value) _isSvip = false;
                });
              },
            ),
            SwitchListTile(
              title: const Text('SVIP Gift'),
              value: _isSvip,
              onChanged: (value) {
                setState(() {
                  _isSvip = value;
                  if (value) _isVip = false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}