import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/gift_service.dart';

class RecentGifters extends StatefulWidget {

  const RecentGifters({required this.receiverId, super.key});
  final String receiverId;

  @override
  State<RecentGifters> createState() => _RecentGiftersState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('receiverId', receiverId));
  }
}

class _RecentGiftersState extends State<RecentGifters> {
  final GiftService _giftService = ServiceLocator().get<GiftService>();

  List<Map<String, dynamic>> _recentGifters = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadRecentGifters();
  }

  Future<void> _loadRecentGifters() async {
    final List<Map<String, dynamic>> gifters = await _giftService.getRecentGifters(widget.receiverId);
    setState(() {
      _recentGifters = gifters;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_recentGifters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <>[
          const Text(
            'Recent:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentGifters.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> gifter = _recentGifters[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
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
                      const SizedBox(width: 4),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <>[
                          Text(
                            gifter['name'],
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: <>[
                              const Icon(
                                Icons.card_giftcard,
                                size: 8,
                                color: Colors.purple,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${gifter['count']}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
