import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/di/service_locator.dart';
import '../../core/services/lucky_draw_service.dart';
import '../../core/services/payment_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';
import '../../widgets/animation/fade_animation.dart';
import '../../widgets/common/custom_button.dart';

class LuckyDrawScreen extends StatefulWidget {
  const LuckyDrawScreen({super.key});

  @override
  State<LuckyDrawScreen> createState() => _LuckyDrawScreenState();
}

class _LuckyDrawScreenState extends State<LuckyDrawScreen>
    with LoadingMixin, ToastMixin, DialogMixin, SingleTickerProviderStateMixin {

  final LuckyDrawService _luckyDrawService = ServiceLocator().get<LuckyDrawService>();
  final PaymentService _paymentService = ServiceLocator().get<PaymentService>();

  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  int _userCoins = 10000;
  bool _isSpinning = false;
  int? _selectedPrizeIndex;
  List<LuckyDrawPrize> _prizes = [];
  final List<LuckyDrawPrize> _history = [];
  int _spinCount = 0;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _spinAnimation = Tween<double>(begin: 0, end: 360 * 10).animate(
      CurvedAnimation(
        parent: _spinController,
        curve: Curves.easeOutCubic,
      ),
    );

    _spinController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
        });
        _showResult();
      }
    });

    _loadData();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));

      _prizes = [
        LuckyDrawPrize(
          id: '1',
          name: '100 Coins',
          value: 100,
          probability: 0.4,
          color: Colors.grey,
          icon: Icons.monetization_on,
          isRare: false,
        ),
        LuckyDrawPrize(
          id: '2',
          name: '500 Coins',
          value: 500,
          probability: 0.25,
          color: Colors.brown,
          icon: Icons.monetization_on,
          isRare: false,
        ),
        LuckyDrawPrize(
          id: '3',
          name: '1000 Coins',
          value: 1000,
          probability: 0.15,
          color: Colors.grey,
          icon: Icons.monetization_on,
          isRare: false,
        ),
        LuckyDrawPrize(
          id: '4',
          name: '5000 Coins',
          value: 5000,
          probability: 0.1,
          color: Colors.amber,
          icon: Icons.monetization_on,
          isRare: true,
        ),
        LuckyDrawPrize(
          id: '5',
          name: 'VIP Badge (7 Days)',
          value: 0,
          probability: 0.05,
          color: Colors.purple,
          icon: Icons.star,
          isRare: true,
        ),
        LuckyDrawPrize(
          id: '6',
          name: 'SVIP Frame (30 Days)',
          value: 0,
          probability: 0.03,
          color: Colors.red,
          icon: Icons.auto_awesome,
          isRare: true,
        ),
        LuckyDrawPrize(
          id: '7',
          name: 'Dragon Entry Effect',
          value: 0,
          probability: 0.015,
          color: Colors.orange,
          icon: Icons.whatshot,
          isRare: true,
        ),
        LuckyDrawPrize(
          id: '8',
          name: 'JACKPOT! 50,000 Coins',
          value: 50000,
          probability: 0.005,
          color: Colors.amber,
          icon: Icons.emoji_events,
          isRare: true,
        ),
      ];
    });
  }

  Future<void> _spinWheel(int cost, int draws) async {
    if (_userCoins < cost) {
      showError('Not enough coins');
      return;
    }

    setState(() {
      _userCoins -= cost;
      _isSpinning = true;
      _spinCount = draws;
    });

    _spinController.forward(from: 0);
  }

  Future<void> _showResult() async {
    final Random random = Random();
    final List<LuckyDrawPrize> results = [];

    for (var i = 0; i < _spinCount; i++) {
      final double rand = random.nextDouble();
      double cumulative = 0;

      for (LuckyDrawPrize prize in _prizes) {
        cumulative += prize.probability;
        if (rand < cumulative) {
          results.add(prize);
          if (prize.value > 0) {
            _userCoins += prize.value;
          }
          _history.insert(0, prize);
          break;
        }
      }
    }

    if (results.length == 1) {
      await showResultDialog(results.first);
    } else {
      await showMultiResultDialog(results);
    }
  }

  Future<void> showResultDialog(LuckyDrawPrize prize) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(prize.isRare ? '🎉 JACKPOT!' : 'Congratulations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: prize.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                prize.icon,
                color: prize.color,
                size: 50,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You won:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              prize.name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: prize.color,
              ),
            ),
            if (prize.value > 0) ...[
              const SizedBox(height: 8),
              Text(
                '+${prize.value} coins',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  Future<void> showMultiResultDialog(List<LuckyDrawPrize> results) async {
    final int totalCoins = results.fold(0, (int sum, LuckyDrawPrize prize) => sum + prize.value);
    final int rareCount = results.where((LuckyDrawPrize p) => p.isRare).length;

    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Draw Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Coins: +$totalCoins',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  if (rareCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Rare Items: $rareCount',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: results.length,
                itemBuilder: (BuildContext context, int index) {
                  final LuckyDrawPrize prize = results[index];
                  return Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: prize.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(prize.icon, color: prize.color, size: 24),
                        const SizedBox(height: 4),
                        Text(
                          prize.name.split(' ').first,
                          style: TextStyle(
                            fontSize: 10,
                            color: prize.color,
                            fontWeight: FontWeight.bold,
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucky Draw'),
        backgroundColor: Colors.amber,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_userCoins',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Wheel Preview
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Wheel
                  AnimatedBuilder(
                    animation: _spinAnimation,
                    builder: (BuildContext context, Widget? child) {
                      return Transform.rotate(
                        angle: _spinAnimation.value * pi / 180,
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ...List.generate(8, (int index) {
                                final double angle = (2 * pi / 8) * index;
                                return Positioned(
                                  left: 125 + 80 * cos(angle) - 20,
                                  top: 125 + 80 * sin(angle) - 20,
                                  child: Icon(
                                    _prizes[index].icon,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Center Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),

                  // Pointer
                  const Positioned(
                    top: 0,
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.red,
                      size: 50,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Draw Options
            Row(
              children: [
                Expanded(
                  child: _buildDrawCard(
                    cost: 1000,
                    draws: 1,
                    discount: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDrawCard(
                    cost: 5000,
                    draws: 6,
                    discount: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDrawCard(
                    cost: 9000,
                    draws: 12,
                    discount: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Prize List
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Available Prizes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._prizes.map((LuckyDrawPrize prize) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: prize.color.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              prize.icon,
                              color: prize.color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prize.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: prize.probability,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(prize.color),
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
                              color: prize.isRare
                                  ? Colors.purple.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${(prize.probability * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: prize.isRare ? Colors.purple : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Recent Wins
            if (_history.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Wins',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _history.length > 10 ? 10 : _history.length,
                          itemBuilder: (BuildContext context, int index) {
                            final LuckyDrawPrize prize = _history[index];
                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: prize.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(prize.icon, color: prize.color, size: 24),
                                  const SizedBox(height: 4),
                                  Text(
                                    prize.name.length > 10
                                        ? '${prize.name.substring(0, 8)}...'
                                        : prize.name,
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: prize.color,
                                    ),
                                    textAlign: TextAlign.center,
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
          ],
        ),
      ),
    );
  }

  Widget _buildDrawCard({
    required int cost,
    required int draws,
    required bool discount,
  }) {
    final int savings = discount ? ((cost / draws) * 0.2).round() : 0;

    return GestureDetector(
      onTap: _isSpinning ? null : () => _spinWheel(cost, draws),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.amber, Colors.orange],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$draws ${draws == 1 ? 'Draw' : 'Draws'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$cost',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (discount) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Save $savings coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LuckyDrawPrize {
  final String id;
  final String name;
  final int value;
  final double probability;
  final Color color;
  final IconData icon;
  final bool isRare;

  LuckyDrawPrize({
    required this.id,
    required this.name,
    required this.value,
    required this.probability,
    required this.color,
    required this.icon,
    required this.isRare,
  });
}