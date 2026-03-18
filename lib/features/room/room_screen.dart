import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
// Widgets
import '../../widgets/gift_panel.dart';
import '../../widgets/seat_widget.dart';
import '../../widgets/chat_widget.dart';

// Models
import '../../core/models/room_model.dart';
import '../../core/models/gift_model.dart';
import '../../core/models/seat_model.dart';
import '../../core/models/user_models.dart'; // UserTier এর জন্য

class RoomScreen extends StatefulWidget {
  const RoomScreen({
    super.key,
    required this.room,
  });

  final RoomModel room;

  @override
  State<RoomScreen> createState() => _RoomScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<RoomModel>('room', room));
  }
}

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool showGiftPanel = false;
  bool isMicOn = true;
  List<GiftAnimation> activeGifts = [];

  // Mock seats data (you'll replace with actual data)
  late List<SeatModel> _seats;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Initialize mock seats
    _initSeats();
  }

  void _initSeats() {
    _seats = List.generate(9, (index) {
      if (index == 0) {
        // Host seat
        return SeatModel(
          seatNumber: index + 1,
          userId: widget.room.hostId,
          userName: 'Host',
          userAvatar: widget.room.hostAvatar,
          isSpeaking: true,
          userTier: UserTier.vip,
        );
      } else if (index == 1) {
        // Occupied seat
        return SeatModel(
          seatNumber: index + 1,
          userId: 'user2',
          userName: 'Alice',
          userAvatar: null,
          isMuted: true,
          userTier: UserTier.normal,
        );
      } else {
        // Empty seat
        return SeatModel.empty(index + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildRoomHeader(),
                Expanded(
                  child: Row(
                    children: [
                      // Left side - Seats
                      Expanded(
                        flex: 3,
                        child: _buildSeatsGrid(),
                      ),
                      // Right side - Chat
                      Expanded(
                        flex: 2,
                        child: _buildChatPanel(),
                      ),
                    ],
                  ),
                ),
                _buildRoomControls(),
              ],
            ),
          ),

          // Gift Animations Overlay
          ...activeGifts.map(_buildGiftAnimation),

          // Gift Panel
          if (showGiftPanel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GiftPanel(
                onSendGift: _sendGift,
                onClose: () {
                  setState(() {
                    showGiftPanel = false;
                  });
                },
              ),
            ),

          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.purple, Colors.pink, Colors.amber, Colors.green],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: widget.room.hostAvatar != null
                ? NetworkImage(widget.room.hostAvatar!)
                : null,
            radius: 20,
            child: widget.room.hostAvatar == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.room.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.people, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.room.viewerCount ?? 0} watching',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Text(' LIVE', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          _buildPKButton(),
        ],
      ),
    );
  }

  Widget _buildPKButton() {
    if (widget.room.isPKActive == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.pink],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ScaleTransition(
              scale: _pulseController,
              child: const Icon(Icons.games, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 4),
            const Text('PK BATTLE', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSeatsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _seats.length,
      itemBuilder: (BuildContext context, int index) {
        final seat = _seats[index];
        final isCurrentUser = seat.userId == 'current_user_id'; // Replace with actual user ID

        return SeatWidget(
          seat: seat,
          isCurrentUser: isCurrentUser,
          onTap: () => _handleSeatTap(seat.seatNumber),
          onLongPress: () => _handleSeatLongPress(seat.seatNumber),
        );
      },
    );
  }

  void _handleSeatTap(int seatNumber) {
    final seat = _seats.firstWhere((s) => s.seatNumber == seatNumber);

    if (seat.isEmpty) {
      _showTakeSeatDialog(context, seatNumber);
    } else {
      _showUserProfile(seat);
    }
  }

  void _handleSeatLongPress(int seatNumber) {
    final seat = _seats.firstWhere((s) => s.seatNumber == seatNumber);

    if (!seat.isEmpty) {
      _showUserOptions(seat);
    }
  }

  void _showTakeSeatDialog(BuildContext context, int seatNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Take Seat $seatNumber'),
        content: const Text('Do you want to take this seat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('You took seat $seatNumber')),
              );
            },
            child: const Text('Take Seat'),
          ),
        ],
      ),
    );
  }

  void _showUserProfile(SeatModel seat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(seat.userName ?? 'User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: seat.userAvatar != null
                  ? NetworkImage(seat.userAvatar!)
                  : null,
              child: seat.userAvatar == null
                  ? Text(seat.userName?[0].toUpperCase() ?? 'U')
                  : null,
            ),
            const SizedBox(height: 16),
            Text('Seat: ${seat.seatNumber}'),
            if (seat.userTier != null)
              Text('Tier: ${seat.userTier!.toString().split('.').last}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserOptions(SeatModel seat) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View Profile'),
            onTap: () {
              Navigator.pop(context);
              _showUserProfile(seat);
            },
          ),
          ListTile(
            leading: const Icon(Icons.volume_off),
            title: Text(seat.isMuted ? 'Unmute' : 'Mute'),
            onTap: () {
              Navigator.pop(context);
              // Toggle mute
            },
          ),
          if (seat.userId != widget.room.hostId)
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orange),
              title: const Text('Kick from seat'),
              onTap: () {
                Navigator.pop(context);
                // Kick user
              },
            ),
        ],
      ),
    );
  }

  Widget _buildChatPanel() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Chat messages
          Expanded(
            child: ChatWidget(roomId: widget.room.id),
          ),

          // Input area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.card_giftcard, color: Colors.purple),
                  onPressed: () {
                    setState(() {
                      showGiftPanel = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: isMicOn ? Icons.mic : Icons.mic_off,
            onTap: () {
              setState(() {
                isMicOn = !isMicOn;
              });
            },
          ),
          _buildControlButton(
            icon: Icons.card_giftcard,
            onTap: () {
              setState(() {
                showGiftPanel = true;
              });
            },
          ),
          _buildControlButton(
            icon: Icons.emoji_events,
            onTap: _showGamesMenu,
          ),
          _buildControlButton(
            icon: Icons.group_add,
            onTap: () {
              // Show invite
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Future<void> _sendGift(GiftModel gift) async {
    // Play sound
    if (gift.soundPath != null) {
      try {
        await _audioPlayer.play(AssetSource(gift.soundPath!));
      } catch (e) {
        debugPrint('Error playing sound: $e');
      }
    }

    // Add animation
    setState(() {
      activeGifts.add(GiftAnimation(
        gift: gift,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      ));
    });

    // Show confetti for big gifts
    if (gift.price >= 10000) {
      _confettiController.play();
    }

    // Remove animation after duration
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        activeGifts.removeWhere((GiftAnimation g) => g.id == gift.id);
      });
    });
  }

  Widget _buildGiftAnimation(GiftAnimation gift) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Lottie.asset(
          gift.gift.animationPath ?? 'assets/animations/default.json',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _showGamesMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Color(0xFF16213e),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Games',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildGameItem('Roulette', Icons.casino),
                    _buildGameItem('3 Patti', Icons.style),
                    _buildGameItem('Ludo', Icons.grid_3x3),
                    _buildGameItem('Carrom', Icons.sports_esports),
                    _buildGameItem('Greedy Cat', Icons.pets),
                    _buildGameItem('Werewolf', Icons.whatshot),
                    _buildGameItem('Trivia', Icons.quiz),
                    _buildGameItem('Pictionary', Icons.brush),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGameItem(String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, '/game', arguments: name);
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.pink],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('showGiftPanel', showGiftPanel));
    properties.add(DiagnosticsProperty<bool>('isMicOn', isMicOn));
    properties.add(IterableProperty<GiftAnimation>('activeGifts', activeGifts));
  }
}

class GiftAnimation {
  final GiftModel gift;
  final String id;

  GiftAnimation({
    required this.gift,
    required this.id,
  });
}