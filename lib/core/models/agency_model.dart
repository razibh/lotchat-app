class AgencyModel {
  String id;
  String name;
  String ownerId;
  String ownerName;
  List<String> memberIds;
  Map<String, int> memberEarnings;
  int totalEarnings;
  double commissionRate;
  DateTime createdAt;
  AgencyStatus status;          // active, suspended
}