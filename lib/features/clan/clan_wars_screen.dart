import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // DiagnosticPropertiesBuilder এর জন্য
import '../../core/di/service_locator.dart';
import '../clan/services/clan_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/animation/fade_animation.dart';

class ClanWarsScreen extends StatefulWidget {
  final String clanId;

  const ClanWarsScreen({required this.clanId, super.key});

  @override
  State<ClanWarsScreen> createState() => _ClanWarsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('clanId', clanId));
  }
}

class _ClanWarsScreenState extends State<ClanWarsScreen>
    with LoadingMixin, ToastMixin, DialogMixin {

  final ClanService _clanService = ServiceLocator().get<ClanService>();

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

      _activeWars = [
        ClanWar(
          id: 'w1',
          opponentName: 'Dragon Clan',
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
          startTime: DateTime.now().subtract(const Duration(days: 8)),
          endTime: DateTime.now().subtract(const Duration(days: 7)),
          ourScore: 1500,
          opponentScore: 2200,
          status: 'lost',
          prize: '0',
        ),
      ];

      setState(() {
        _isLoading = false;
      });
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
    ).then((bool? confirmed) {
      if (confirmed ?? false) {
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

  Widget _buildProgressBar(double progress, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 8,
        color: Colors.grey.shade200,
        child: FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveWarCard(ClanWar war) {
    final int totalScore = war.ourScore + war.opponentScore;
    final double ourProgress = totalScore > 0 ? war.ourScore / totalScore : 0.5;
    final Duration timeLeft = war.endTime.difference(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          color: Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.groups,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your Clan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${war.ourScore}',
                        style: const TextStyle(
                          fontSize: 28,
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'BATTLE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Opponent Clan
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: war.opponentEmblem != null
                            ? ClipOval(
                          child: Image.network(
                            war.opponentEmblem!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Icon(
                          Icons.groups,
                          color: Colors.orange,
                          size: 35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        war.opponentName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${war.opponentScore}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildProgressBar(ourProgress, Colors.deepPurple),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Time left: ${_formatDuration(timeLeft)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.card_giftcard, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        war.prize,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: () => _joinWar(war),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Join Battle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingWarCard(ClanWar war) {
    final Duration timeUntilStart = war.startTime.difference(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
        title: Text(
          war.opponentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.timer, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text('Starts in ${_formatDuration(timeUntilStart)}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                war.prize,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 80,
              height: 30,
              child: ElevatedButton(
                onPressed: () => _joinWar(war),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Join', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastWarCard(ClanWar war) {
    final bool isWon = war.status == 'won';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
            size: 30,
          ),
        ),
        title: Text(
          war.opponentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${war.ourScore} - ${war.opponentScore}',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isWon ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isWon ? 'VICTORY' : 'DEFEAT',
                style: TextStyle(
                  color: isWon ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            if (isWon && war.prize != '0') ...[
              const SizedBox(height: 4),
              Text(
                war.prize,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clan Wars'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
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
                    SizedBox(
                      width: 200,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _startWarSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Find Opponent'),
                      ),
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
              ..._activeWars.map(_buildActiveWarCard),
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
              ..._upcomingWars.map(_buildUpcomingWarCard),
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
              ..._pastWars.map(_buildPastWarCard),
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