import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/avatar_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/custom_button.dart';

class AvatarBuilderScreen extends StatefulWidget {
  const AvatarBuilderScreen({Key? key}) : super(key: key);

  @override
  State<AvatarBuilderScreen> createState() => _AvatarBuilderScreenState();
}

class _AvatarBuilderScreenState extends State<AvatarBuilderScreen> 
    with LoadingMixin, ToastMixin {
  
  final _avatarService = ServiceLocator().get<AvatarService>();
  
  String _selectedCategory = 'Face';
  Map<String, dynamic> _currentAvatar = <String, dynamic>{
    'face': 'face1',
    'eyes': 'eyes1',
    'nose': 'nose1',
    'mouth': 'mouth1',
    'hair': 'hair1',
    'outfit': 'outfit1',
    'accessory': 'none',
    'background': 'bg1',
  };
  
  List<AvatarItem> _faceItems = <AvatarItem>[];
  List<AvatarItem> _eyesItems = <AvatarItem>[];
  final List<AvatarItem> _noseItems = <AvatarItem>[];
  final List<AvatarItem> _mouthItems = <AvatarItem>[];
  List<AvatarItem> _hairItems = <AvatarItem>[];
  List<AvatarItem> _outfitItems = <AvatarItem>[];
  final List<AvatarItem> _accessoryItems = <AvatarItem>[];
  final List<AvatarItem> _backgroundItems = <AvatarItem>[];

  final List<String> _categories = <String>[
    'Face', 'Eyes', 'Nose', 'Mouth', 'Hair', 'Outfit', 'Accessory', 'Background'
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _faceItems = List.generate(10, (int index) => AvatarItem(
        id: 'face${index + 1}',
        name: 'Face ${index + 1}',
        category: 'Face',
        price: index < 3 ? 0 : 500 * index,
        image: 'face_$index',
        isLocked: index > 5,
      ));

      _eyesItems = List.generate(10, (int index) => AvatarItem(
        id: 'eyes${index + 1}',
        name: 'Eyes ${index + 1}',
        category: 'Eyes',
        price: index < 3 ? 0 : 300 * index,
        image: 'eyes_$index',
        isLocked: index > 5,
      ));

      _hairItems = List.generate(15, (int index) => AvatarItem(
        id: 'hair${index + 1}',
        name: 'Hairstyle ${index + 1}',
        category: 'Hair',
        price: index < 5 ? 0 : 800 * index,
        image: 'hair_$index',
        isLocked: index > 8,
      ));

      _outfitItems = List.generate(20, (int index) => AvatarItem(
        id: 'outfit${index + 1}',
        name: 'Outfit ${index + 1}',
        category: 'Outfit',
        price: index < 5 ? 0 : 1000 * index,
        image: 'outfit_$index',
        isLocked: index > 10,
      ));
    });
  }

  List<AvatarItem> get _currentItems {
    switch (_selectedCategory) {
      case 'Face':
        return _faceItems;
      case 'Eyes':
        return _eyesItems;
      case 'Nose':
        return _noseItems;
      case 'Mouth':
        return _mouthItems;
      case 'Hair':
        return _hairItems;
      case 'Outfit':
        return _outfitItems;
      case 'Accessory':
        return _accessoryItems;
      case 'Background':
        return _backgroundItems;
      default:
        return <AvatarItem>[];
    }
  }

  void _selectItem(AvatarItem item) {
    if (item.isLocked) {
      _showPurchaseDialog(item);
      return;
    }

    setState(() {
      _currentAvatar[_selectedCategory.toLowerCase()] = item.id;
    });
  }

  void _showPurchaseDialog(AvatarItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlock Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock, size: 50, color: Colors.purple),
            ),
            const SizedBox(height: 16),
            Text(
              'Unlock ${item.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ${item.price} coins',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showSuccess('Item unlocked!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
            ),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }

  void _saveAvatar() {
    showSuccess('Avatar saved!');
    Navigator.pop(context, _currentAvatar);
  }

  void _randomizeAvatar() {
    setState(() {
      _currentAvatar = <String, dynamic>{
        'face': 'face${Random().nextInt(10) + 1}',
        'eyes': 'eyes${Random().nextInt(10) + 1}',
        'nose': 'nose${Random().nextInt(5) + 1}',
        'mouth': 'mouth${Random().nextInt(8) + 1}',
        'hair': 'hair${Random().nextInt(15) + 1}',
        'outfit': 'outfit${Random().nextInt(20) + 1}',
        'accessory': Random().nextBool() ? 'accessory${Random().nextInt(5) + 1}' : 'none',
        'background': 'bg${Random().nextInt(6) + 1}',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Builder'),
        backgroundColor: Colors.purple,
        actions: <>[
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: _randomizeAvatar,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAvatar,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: <>[
                // Sidebar Categories
                Container(
                  width: 100,
                  color: Colors.grey.shade100,
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final String category = _categories[index];
                      final bool isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.purple.withOpacity(0.1) : null,
                            border: Border(
                              left: isSelected
                                  ? const BorderSide(color: Colors.purple, width: 4)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Column(
                            children: <>[
                              Icon(
                                _getCategoryIcon(category),
                                color: isSelected ? Colors.purple : Colors.grey,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? Colors.purple : Colors.grey,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Avatar Preview
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: <>[
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://api.dicebear.com/7.x/avataaars/png?seed=${_currentAvatar.values.join()}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Preview',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._currentAvatar.entries.map((MapEntry<String, dynamic> entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <>[
                              Text(
                                '${entry.key}:',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                              Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Items Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _currentItems.length,
                    itemBuilder: (context, index) {
                      final AvatarItem item = _currentItems[index];
                      final bool isSelected = _currentAvatar[_selectedCategory.toLowerCase()] == item.id;
                      
                      return GestureDetector(
                        onTap: () => _selectItem(item),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.purple.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.purple : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: <>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <>[
                                  Icon(
                                    Icons.face,
                                    size: 40,
                                    color: item.isLocked ? Colors.grey : Colors.purple,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: item.isLocked ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                  if (item.price > 0) ...<>[
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <>[
                                        const Icon(
                                          Icons.monetization_on,
                                          size: 10,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${item.price}',
                                          style: const TextStyle(
                                            fontSize: 8,
                                            color: Colors.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              if (item.isLocked)
                                const Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Icon(
                                    Icons.lock,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Face':
        return Icons.face;
      case 'Eyes':
        return Icons.visibility;
      case 'Nose':
        return Icons.height;
      case 'Mouth':
        return Icons.insert_emoticon;
      case 'Hair':
        return Icons.brush;
      case 'Outfit':
        return Icons.checkroom;
      case 'Accessory':
        return Icons.watch;
      case 'Background':
        return Icons.wallpaper;
      default:
        return Icons.circle;
    }
  }
}

class AvatarItem {

  AvatarItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.isLocked,
  });
  final String id;
  final String name;
  final String category;
  final int price;
  final String image;
  final bool isLocked;
}