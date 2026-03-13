// lib/core/models/gift_model.dart

class GiftModel {

  GiftModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.icon,
    required this.color,
    this.isVip = false,
    this.isSvip = false,
    this.isAnimated = false,
    this.animationPath,
    this.soundPath,
    this.effects = const {},
  });
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final IconData icon;
  final Color color;
  final bool isVip;
  final bool isSvip;
  final bool isAnimated;
  final String? animationPath;
  final String? soundPath;
  final Map<String, dynamic> effects;

  // Mock gifts data
  static List<GiftModel> getMockGifts() {
    return <GiftModel>[
      // Cute category
      GiftModel(
        id: 'g1',
        name: 'Rose',
        description: 'A beautiful red rose',
        price: 100,
        category: 'Cute',
        icon: Icons.local_florist,
        color: Colors.red,
      ),
      GiftModel(
        id: 'g2',
        name: 'Chocolate',
        description: 'Sweet chocolate box',
        price: 200,
        category: 'Cute',
        icon: Icons.cake,
        color: Colors.brown,
      ),
      GiftModel(
        id: 'g3',
        name: 'Teddy Bear',
        description: 'Cuddly teddy bear',
        price: 300,
        category: 'Cute',
        icon: Icons.toys,
        color: Colors.orange,
      ),
      
      // Luxury category
      GiftModel(
        id: 'g4',
        name: 'Diamond Ring',
        description: 'Sparkling diamond ring',
        price: 5000,
        category: 'Luxury',
        icon: Icons.diamond,
        color: Colors.cyan,
        isAnimated: true,
      ),
      GiftModel(
        id: 'g5',
        name: 'Luxury Car',
        description: 'Premium sports car',
        price: 10000,
        category: 'Luxury',
        icon: Icons.directions_car,
        color: Colors.red,
        isAnimated: true,
      ),
      
      // VIP category
      GiftModel(
        id: 'g6',
        name: 'VIP Crown',
        description: 'Royal VIP crown',
        price: 20000,
        category: 'VIP',
        icon: Icons.emoji_events,
        color: Colors.purple,
        isVip: true,
        isAnimated: true,
      ),
      GiftModel(
        id: 'g7',
        name: 'VIP Castle',
        description: 'Majestic castle',
        price: 50000,
        category: 'VIP',
        icon: Icons.account_balance,
        color: Colors.deepPurple,
        isVip: true,
        isAnimated: true,
      ),
      
      // SVIP category
      GiftModel(
        id: 'g8',
        name: 'SVIP Dragon',
        description: 'Legendary golden dragon',
        price: 100000,
        category: 'SVIP',
        icon: Icons.whatshot,
        color: Colors.amber,
        isSvip: true,
        isAnimated: true,
      ),
      GiftModel(
        id: 'g9',
        name: 'SVIP Galaxy',
        description: 'Magical galaxy effect',
        price: 200000,
        category: 'SVIP',
        icon: Icons.auto_awesome,
        color: const Color(0xFF8B5CF6),
        isSvip: true,
        isAnimated: true,
      ),
    ];
  }
}