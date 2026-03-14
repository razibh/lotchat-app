// lib/chat/models/room_model.dart

class RoomModel {

  RoomModel({
    required this.id,
    required this.name,
    required this.hostId,
    required this.seats,
    this.isPKActive,
    this.currentPK,
  });

  // fromJson factory constructor
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      hostId: json['hostId'] as String? ?? '',
      seats: (json['seats'] as List? ?? [])
          .map((seat) => Seat.fromJson(seat as Map<String, dynamic>))
          .toList(),
      isPKActive: json['isPKActive'] as bool? ?? false,
      currentPK: json['currentPK'] as String?,
    );
  }
  final String id;
  final String name;
  final String hostId;
  final List<Seat> seats;
  final bool? isPKActive;
  final String? currentPK;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'hostId': hostId,
      'seats': seats.map((Seat seat) => seat.toJson()).toList(),
      'isPKActive': isPKActive,
      'currentPK': currentPK,
    };
  }

  // copyWith method
  RoomModel copyWith({
    String? id,
    String? name,
    String? hostId,
    List<Seat>? seats,
    bool? isPKActive,
    String? currentPK,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      hostId: hostId ?? this.hostId,
      seats: seats ?? this.seats,
      isPKActive: isPKActive ?? this.isPKActive,
      currentPK: currentPK ?? this.currentPK,
    );
  }
}

class Seat {

  Seat({
    this.userId,
    this.userName,
    required this.position,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      position: json['position'] as int? ?? 0,
    );
  }
  final String? userId;
  final String? userName;
  final int position;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'userName': userName,
      'position': position,
    };
  }

  Seat copyWith({
    String? userId,
    String? userName,
    int? position,
  }) {
    return Seat(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      position: position ?? this.position,
    );
  }
}