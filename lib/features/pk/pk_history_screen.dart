import 'package:flutter/material.dart';

class PKHistoryScreen extends StatefulWidget {
  const PKHistoryScreen({super.key});

  @override
  State<PKHistoryScreen> createState() => _PKHistoryScreenState();
}

class _PKHistoryScreenState extends State<PKHistoryScreen> {
  final List<PKHistoryItem> _historyItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _historyItems.addAll(List.generate(20, (index) => PKHistoryItem(
        id: 'pk_$index',
        opponentName: 'User ${index + 1}',
        myScore: 50 + index,
        opponentScore: 30 + index,
        result: index % 3 == 0 ? 'win' : (index % 3 == 1 ? 'loss' : 'draw'),
        date: DateTime.now().subtract(Duration(days: index)),
      )));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PK History'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No PK battles yet',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historyItems.length,
        itemBuilder: (context, index) {
          final item = _historyItems[index];
          return _buildHistoryCard(item);
        },
      ),
    );
  }

  Widget _buildHistoryCard(PKHistoryItem item) {
    Color resultColor;
    IconData resultIcon;
    String resultText;

    switch (item.result) {
      case 'win':
        resultColor = Colors.green;
        resultIcon = Icons.emoji_events;
        resultText = 'WIN';
        break;
      case 'loss':
        resultColor = Colors.red;
        resultIcon = Icons.close;
        resultText = 'LOSS';
        break;
      default:
        resultColor = Colors.orange;
        resultIcon = Icons.remove;
        resultText = 'DRAW';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: resultColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: resultColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(resultIcon, size: 14, color: resultColor),
                      const SizedBox(width: 4),
                      Text(
                        resultText,
                        style: TextStyle(
                          color: resultColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(item.date),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('You', style: TextStyle(color: Colors.grey)),
                    Text(
                      '${item.myScore}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'VS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(item.opponentName, style: const TextStyle(color: Colors.grey)),
                    Text(
                      '${item.opponentScore}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}

class PKHistoryItem {
  final String id;
  final String opponentName;
  final int myScore;
  final int opponentScore;
  final String result; // 'win', 'loss', 'draw'
  final DateTime date;

  PKHistoryItem({
    required this.id,
    required this.opponentName,
    required this.myScore,
    required this.opponentScore,
    required this.result,
    required this.date,
  });
}