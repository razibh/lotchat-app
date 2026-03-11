class GiftModel {
  String id;
  String name;
  int price;
  String category;
  String animationPath;
  String soundPath;
  String previewImage;
  bool isVip;
  bool isSvip;
  int tier;
  Map<String, dynamic> effects;
  
  GiftModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.animationPath,
    required this.soundPath,
    required this.previewImage,
    this.isVip = false,
    this.isSvip = false,
    this.tier = 0,
    this.effects = const {},
  });
  
  static List<GiftModel> getGifts() {
    return [
      // Normal Gifts (100+)
      GiftModel(
        id: 'g1',
        name: 'Rose',
        price: 100,
        category: 'Cute',
        animationPath: 'assets/gifts/rose.json',
        soundPath: 'assets/sounds/gifts/rose.mp3',
        previewImage: 'assets/gifts/preview/rose.png',
      ),
      GiftModel(
        id: 'g2',
        name: 'Chocolate',
        price: 200,
        category: 'Cute',
        animationPath: 'assets/gifts/chocolate.json',
        soundPath: 'assets/sounds/gifts/chocolate.mp3',
        previewImage: 'assets/gifts/preview/chocolate.png',
      ),
      // ... more gifts up to 500+
      
      // VIP Gifts
      GiftModel(
        id: 'vip1',
        name: 'VIP Car',
        price: 5000,
        category: 'VIP',
        animationPath: 'assets/gifts/vip_car.json',
        soundPath: 'assets/sounds/gifts/vip_car.mp3',
        previewImage: 'assets/gifts/preview/vip_car.png',
        isVip: true,
        tier: 1,
        effects: {'fullscreen': true, 'duration': 5},
      ),
      
      // SVIP Gifts
      GiftModel(
        id: 'svip1',
        name: 'SVIP Yacht',
        price: 50000,
        category: 'SVIP',
        animationPath: 'assets/gifts/svip_yacht.json',
        soundPath: 'assets/sounds/gifts/svip_yacht.mp3',
        previewImage: 'assets/gifts/preview/svip_yacht.png',
        isSvip: true,
        tier: 1,
        effects: {'fullscreen': true, 'duration': 10, 'confetti': true},
      ),
    ];
  }
}