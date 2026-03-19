import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User hide

import '../../core/di/service_locator.dart';
import '../clan/services/clan_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/animation/fade_animation.dart';

class ClanTasksScreen extends StatefulWidget {
  final String clanId;

  const ClanTasksScreen({required this.clanId, super.key});

  @override
  State<ClanTasksScreen> createState() => _ClanTasksScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('clanId', clanId));
  }
}

class _ClanTasksScreenState extends State<ClanTasksScreen>
    with LoadingMixin, ToastMixin {

  final ClanService _clanService = ServiceLocator().get<ClanService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

  List<ClanTask> _dailyTasks = [];
  List<ClanTask> _weeklyTasks = [];
  String? _currentUserId;
  int _clanCoins = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    // ✅ Firebase Auth → Supabase Auth
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _currentUserId = session?.user.id;
    });
  }

  Future<void> _loadTasks() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      _dailyTasks = [
        ClanTask(
          id: 'dt1',
          title: 'Send 5 Gifts',
          description: 'Send gifts to clan members',
          type: 'daily',
          xpReward: 100,
          coinReward: 50,
          progress: 3,
          target: 5,
          icon: Icons.card_giftcard,
          color: Colors.pink,
        ),
        ClanTask(
          id: 'dt2',
          title: 'Chat Activity',
          description: 'Send 20 messages in clan chat',
          type: 'daily',
          xpReward: 80,
          coinReward: 40,
          progress: 12,
          target: 20,
          icon: Icons.chat,
          color: Colors.blue,
        ),
        ClanTask(
          id: 'dt3',
          title: 'Play Games',
          description: 'Play 3 games in clan',
          type: 'daily',
          xpReward: 120,
          coinReward: 60,
          progress: 1,
          target: 3,
          icon: Icons.sports_esports,
          color: Colors.green,
        ),
        ClanTask(
          id: 'dt4',
          title: 'Donate Coins',
          description: 'Donate 500 coins to clan',
          type: 'daily',
          xpReward: 150,
          coinReward: 75,
          progress: 200,
          target: 500,
          icon: Icons.monetization_on,
          color: Colors.amber,
        ),
        ClanTask(
          id: 'dt5',
          title: 'Voice Chat',
          description: 'Spend 30 minutes in voice chat',
          type: 'daily',
          xpReward: 200,
          coinReward: 100,
          progress: 15,
          target: 30,
          icon: Icons.mic,
          color: Colors.purple,
        ),
      ];

      _weeklyTasks = [
        ClanTask(
          id: 'wt1',
          title: 'Win Clan Wars',
          description: 'Win 5 clan war battles',
          type: 'weekly',
          xpReward: 500,
          coinReward: 250,
          progress: 2,
          target: 5,
          icon: Icons.emoji_events,
          color: Colors.red,
        ),
        ClanTask(
          id: 'wt2',
          title: 'Top Donator',
          description: 'Donate 5000 coins to clan',
          type: 'weekly',
          xpReward: 1000,
          coinReward: 500,
          progress: 3200,
          target: 5000,
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
        ClanTask(
          id: 'wt3',
          title: 'Invite Friends',
          description: 'Invite 10 friends to clan',
          type: 'weekly',
          xpReward: 800,
          coinReward: 400,
          progress: 4,
          target: 10,
          icon: Icons.person_add,
          color: Colors.green,
        ),
      ];

      _clanCoins = 1250;
    });
  }

  Future<void> _claimTask(ClanTask task) async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        if (task.type == 'daily') {
          final int index = _dailyTasks.indexWhere((ClanTask t) => t.id == task.id);
          if (index != -1) {
            _dailyTasks[index] = task.copyWith(progress: task.target);
          }
        } else {
          final int index = _weeklyTasks.indexWhere((ClanTask t) => t.id == task.id);
          if (index != -1) {
            _weeklyTasks[index] = task.copyWith(progress: task.target);
          }
        }
        _clanCoins += task.coinReward;
      });

      showSuccess('Task completed! +${task.xpReward} XP, +${task.coinReward} coins');

      if (_currentUserId != null) {
        await _clanService.addActivityPoints(
          widget.clanId,
          _currentUserId!,
          task.xpReward,
        );
      }
    });
  }

  Widget _buildTaskCard(ClanTask task) {
    final bool isCompleted = task.progress >= task.target;
    final double progress = task.progress / task.target;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: task.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(task.icon, color: task.color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        task.description,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.flash_on, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('+${task.xpReward}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildProgressBar(progress, task.color),
                ),
                const SizedBox(width: 12),
                Text(
                  '${task.progress}/${task.target}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monetization_on, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text('+${task.coinReward} coins'),
                  ],
                ),
                if (!isCompleted)
                  SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _claimTask(task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: task.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Claim'),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text('Completed'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 6,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clan Tasks'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_clanCoins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Tasks
            const Text(
              'Daily Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Reset in 12 hours',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...List.generate(_dailyTasks.length, (int index) {
              final task = _dailyTasks[index];
              return FadeAnimation(
                delay: Duration(milliseconds: index * 100),
                child: _buildTaskCard(task),
              );
            }),

            const SizedBox(height: 24),

            // Weekly Tasks
            const Text(
              'Weekly Tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Reset in 5 days',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...List.generate(_weeklyTasks.length, (int index) {
              final task = _weeklyTasks[index];
              return FadeAnimation(
                delay: Duration(milliseconds: (index + _dailyTasks.length) * 100),
                child: _buildTaskCard(task),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ClanTask {
  final String id;
  final String title;
  final String description;
  final String type;
  final int xpReward;
  final int coinReward;
  final int progress;
  final int target;
  final IconData icon;
  final Color color;

  ClanTask({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
    required this.coinReward,
    required this.progress,
    required this.target,
    required this.icon,
    required this.color,
  });

  ClanTask copyWith({int? progress}) {
    return ClanTask(
      id: id,
      title: title,
      description: description,
      type: type,
      xpReward: xpReward,
      coinReward: coinReward,
      progress: progress ?? this.progress,
      target: target,
      icon: icon,
      color: color,
    );
  }
}