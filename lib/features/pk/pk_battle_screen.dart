import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/pk_service.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/custom_button.dart';
import '../room/room_screen.dart';

class PKBattleScreen extends StatefulWidget {

  const PKBattleScreen({
    Key? key,
    required this.roomId,
    required this.opponentRoomId,
  }) : super(key: key);
  final String roomId;
  final String opponentRoomId;

  @override
  State<PKBattleScreen> createState() => _PKBattleScreenState();
}

class _PKBattleScreenState extends State<PKBattleScreen> 
    with LoadingMixin, ToastMixin {
  
  final _pkService = ServiceLocator().get<PkService>();
  final SocketService _socketService = ServiceLocator().get<SocketService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();
  
  PKBattle? _battle;
  int _ourScore = 0;
  int _opponentScore = 0;
  int _timeLeft = 300; // 5 minutes in seconds
  List<Map<String, dynamic>> _topGifters = <Map<String, dynamic>>[];
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _setupBattle();
    _startTimer();
    _setupSocketListeners();
  }

  Future<void> _getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUserId = user?.uid;
    });
  }

  Future<void> _setupBattle() async {
    await runWithLoading(() async {
      _battle = await _pkService.startBattle(
        roomId: widget.roomId,
        opponentRoomId: widget.opponentRoomId,
      );
      
      if (_battle != null) {
        _socketService.emit('join-pk', <String, String>{'battleId': _battle!.id});
      }
    });
  }

  void _setupSocketListeners() {
    _socketService.on('pk-score-update', (data) {
      setState(() {
        if (data['roomId'] == widget.roomId) {
          _ourScore = data['score'];
        } else {
          _opponentScore = data['score'];
        }
      });
    });

    _socketService.on('pk-top-gifters', (data) {
      setState(() {
        _topGifters = List<Map<String, dynamic>>.from(data['gifters']);
      });
    });

    _socketService.on('pk-battle-end', _showBattleEndDialog);
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        _startTimer();
      } else if (_timeLeft == 0) {
        _endBattle();
      }
    });
  }

  Future<void> _endBattle() async {
    await _pkService.endBattle(_battle!.id);
    _showBattleEndDialog(<String, dynamic>{
      'winner': _ourScore > _opponentScore ? 'our' : 'opponent',
      'ourScore': _ourScore,
      'opponentScore': _opponentScore,
    });
  }

  void _showBattleEndDialog(Map<String, dynamic> data) {
    final won = data['winner'] == 'our';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(won ? '🎉 Victory!' : '😢 Defeat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Text(
              won
                  ? 'Your team won the PK battle!'
                  : 'Better luck next time!',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <>[
                Column(
                  children: <>[
                    const Text('Your Team'),
                    const SizedBox(height: 4),
                    Text(
                      '${data['ourScore']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const Text('VS', style: TextStyle(fontWeight: FontWeight.bold)),
                Column(
                  children: <>[
                    const Text('Opponent'),
                    const SizedBox(height: 4),
                    Text(
                      '${data['opponentScore']}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: <>[
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PK Battle'),
        backgroundColor: Colors.red,
        actions: <>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatTime(_timeLeft),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <>[Colors.red.shade900, Colors.red.shade700],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <>[
              // Score Board
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: <>[
                    // Our Room
                    Expanded(
                      child: Column(
                        children: <>[
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.meeting_room, color: Colors.red, size: 30),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Your Room',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_ourScore',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // VS
                    const Column(
                      children: <>[
                        Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'BATTLE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    
                    // Opponent Room
                    Expanded(
                      child: Column(
                        children: <>[
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.meeting_room, color: Colors.blue, size: 30),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Opponent',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_opponentScore',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Stack(
                  children: <>[
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Row(
                      children: <>[
                        Expanded(
                          flex: _ourScore,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <>[Colors.green, Colors.lightGreen],
                              ),
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: _opponentScore,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: <>[Colors.red, Colors.orange],
                              ),
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Top Gifters
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      const Text(
                        'Top Supporters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _topGifters.length,
                          itemBuilder: (context, index) {
                            final Map<String, dynamic> gifter = _topGifters[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: <>[
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundImage: gifter['avatar'] != null
                                        ? NetworkImage(gifter['avatar'])
                                        : null,
                                    child: gifter['avatar'] == null
                                        ? Text(gifter['name'][0].toUpperCase())
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <>[
                                        Text(
                                          gifter['name'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${gifter['gifts']} gifts',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      children: <>[
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          '#${index + 1}',
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Join Battle Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: CustomButton(
                  text: 'Join Battle',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomScreen(
                          room: RoomModel(id: widget.roomId, name: 'Battle Room'),
                        ),
                      ),
                    );
                  },
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PKBattle {

  PKBattle({
    required this.id,
    required this.room1Id,
    required this.room2Id,
    required this.room1Score,
    required this.room2Score,
    required this.startTime,
    required this.endTime,
  });
  final String id;
  final String room1Id;
  final String room2Id;
  final int room1Score;
  final int room2Score;
  final DateTime startTime;
  final DateTime endTime;
}