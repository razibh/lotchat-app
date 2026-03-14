class BadgeModel {
  String id;
  String name;
  BadgeType type;               // vip, svip, fan, event
  int tier;                     // 1-10 for VIP, 1-8 for SVIP
  String svgPath;               // assets/badges/vip1.svg
  String animationPath;         // assets/badges/vip1.json (optional)
  Map<String, dynamic> requirements; // coins spent, gifts sent etc.
  int expiryDays;               // 0 = permanent
}