import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/clan_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/animation/fade_animation.dart';
import 'widgets/clan_progress_bar.dart';

class ClanWarsScreen extends StatefulWidget {
  final String clanId;

  const ClanWarsScreen({Key? key, required this.clanId}) : super(key: key);

  @override
  State<ClanWarsScreen> createState() => _ClanWarsScreenState();
}

class _ClanWarsScreenState extends State<ClanWarsScreen> 
    with LoadingMixin, ToastMixin, DialogMixin {
  
  final _clanService = ServiceLocator().get<ClanService>();
  
  List<ClanWar> _activeWars = [];
  List<ClanWar> _upcomingWars = [];
  List<ClanWar> _pastWars = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWars();
  }

  Future<void> _loadWars() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _activeWars = [
        ClanWar(
          id: 'w1',
          opponentName: 'Dragon Clan',
          opponentEmblem: null,
          startTime: DateTime.now().subtract(const Duration(hours: 2)),
          endTime: DateTime.now().add(const Duration(hours: 22)),
          ourScore: 1250,
          opponentScore: 980,
          status: 'active',
          prize: '5000 clan coins',
        ),
      ];

      _upcomingWars = [
        ClanWar(
          id: 'w2',
          opponentName: 'Phoenix Clan',
          opponentEmblem: null,
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 2)),
          ourScore: 0,
          opponentScore: 0,
          status: 'upcoming',
          prize: '3000 clan coins',
        ),
        ClanWar(
          id: 'w3',
          opponentName: 'Wolf Clan',
          opponentEmblem: null,
          startTime: DateTime.now().add(const Duration(days: 3)),
          endTime: DateTime.now().add(const Duration(days: 4)),
          ourScore: 0,
          opponentScore: 0,
          status: 'upcoming',
          prize: '4000 clan coins',
        ),
      ];

      _pastWars = [
        ClanWar(
          id: 'w4',
          opponentName: 'Tiger Clan',
          opponentEmblem: null,
          startTime: DateTime.now().subtract(const Duration(days: 5)),
          endTime: DateTime.now().subtract(const Duration(days: 4)),
          ourScore: 2100,
          opponentScore: 1850,
          status: 'won',
          prize: '2000 clan coins',
        ),
        ClanWar(
          id: 'w5',
          opponentName: 'Lion Clan',
          opponentEmblem: null,
          startTime: DateTime.now().subtract(const Duration(days: 8)),
          endTime: DateTime.now().subtract(const Duration(days: 7)),
          ourScore: 1500,
          opponentScore: 2200,
          status: 'lost',
          prize: '0',
        ),
      ];

      _isLoading = false;
    });
  }

  Future<void> _startWarSearch() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 2));
      
      showInfo('Searching for opponent...');
      
      await Future.delayed(const Duration(seconds: 2));
      
      showSuccess('Opponent found! War starts in 1 hour');
      _loadWars();
    });
  }

  void _joinWar(ClanWar war) {
    showConfirmDialog(
      context,
      title: 'Join War',
      message: 'Join the war against ${war.opponentName}?',
    ).then((confirmed) {
      if (confirmed == true) {
        showSuccess('Joined the war!');
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clan Wars'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Start War Button
                  if (_activeWars.isEmpty && _upcomingWars.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 50),
                          const Icon(
                            Icons.sports_mma,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Active Wars',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start a war to compete with other clans',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            text: 'Find Opponent',
                            onPressed: _startWarSearch,
                            color: Colors.deepPurple,
                            width: 200,
                          ),
                        ],
                      ),
                    ),

                  // Active Wars
                  if (_activeWars.isNotEmpty) ...[
                    const Text(
                      'Active War',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._activeWars.map((war) => _buildActiveWarCard(war)),
                    const SizedBox(height: 24),
                  ],

                  // Upcoming Wars
                  if (_upcomingWars.isNotEmpty) ...[
                    const Text(
                      'Upcoming Wars',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._upcomingWars.map((war) => _buildUpcomingWarCard(war)),
                    const SizedBox(height: 24),
                  ],

                  // Past Wars
                  if (_pastWars.isNotEmpty) ...[
                    const Text(
                      'War History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._pastWars.map((war) => _buildPastWarCard(war)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildActiveWarCard(ClanWar war) {
    final totalScore = war.ourScore + war.opponentScore;
    final ourProgress = totalScore > 0 ? war.ourScore / totalScore : 0.5;
    final timeLeft = war.endTime.difference(DateTime.now());

    return Card(
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Our Clan
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Clan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${war.ourScore}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),

                // VS
                const Column(
                  children: [
                    Text(
                      'VS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Battle'),
                  ],
                ),

                // Opponent Clan
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: war.opponentEmblem != null
                            ? Image.network(war.opponentEmblem!)
                            : const Icon(
                                Icons.groups,
                                color: Colors.orange,
                                size: 30,
                              ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        war.opponentName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${war.opponentScore}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClanProgressBar(
              progress: ourProgress,
              color: Colors.deepPurple,
              height: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time left: ${_formatDuration(timeLeft)}'),
                Text('Prize: ${war.prize}'),
              ],
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Join Battle',
              onPressed: () => _joinWar(war),
              color: Colors.deepPurple,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingWarCard(ClanWar war) {
    final timeUntilStart = war.startTime.difference(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.groups, color: Colors.orange),
        ),
        title: Text(war.opponentName),
        subtitle: Text('Starts in ${_formatDuration(timeUntilStart)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              war.prize,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 4),
            ElevatedButton(
              onPressed: () => _joinWar(war),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(80, 30),
              ),
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastWarCard(ClanWar war) {
    final isWon = war.status == 'won';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isWon ? Colors.green.shade100 : Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isWon ? Icons.emoji_events : Icons.close,
            color: isWon ? Colors.green : Colors.red,
          ),
        ),
        title: Text(war.opponentName),
        subtitle: Text('${war.ourScore} - ${war.opponentScore}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isWon ? 'VICTORY' : 'DEFEAT',
              style: TextStyle(
                color: isWon ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (isWon) ...[
              const SizedBox(height: 4),
              Text(
                war.prize,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ClanWar {
  final String id;
  final String opponentName;
  final String? opponentEmblem;
  final DateTime startTime;
  final DateTime endTime;
  final int ourScore;
  final int opponentScore;
  final String status;
  final String prize;

  ClanWar({
    required this.id,
    required this.opponentName,
    this.opponentEmblem,
    required this.startTime,
    required this.endTime,
    required this.ourScore,
    required this.opponentScore,
    required this.status,
    required this.prize,
  });
}