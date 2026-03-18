import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/gift_service.dart';

class RecentGifters extends StatefulWidget {
  final String receiverId;

  const RecentGifters({
    super.key,
    required this.receiverId,
  });

  @override
  State<RecentGifters> createState() => _RecentGiftersState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('receiverId', receiverId));
  }
}

class _RecentGiftersState extends State<RecentGifters> {
  final GiftService _giftService = ServiceLocator.instance.get<GiftService>();

  List<Map<String, dynamic>> _recentGifters = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRecentGifters();
  }

  Future<void> _loadRecentGifters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Map<String, dynamic>> gifters = await _giftService.getRecentGifters(widget.receiverId);
      setState(() {
        _recentGifters = gifters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Row(
          children: [
            Text(
              'Recent:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null || _recentGifters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
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
                final String name = gifter['name'] ?? 'Unknown';
                final String? avatar = gifter['avatar'];
                final int count = gifter['count'] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: avatar != null
                            ? NetworkImage(avatar)
                            : null,
                        child: avatar == null
                            ? Text(
                          _getInitials(name),
                          style: const TextStyle(fontSize: 12),
                        )
                            : null,
                      ),
                      const SizedBox(width: 4),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                size: 8,
                                color: Colors.purple,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$count',
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

// Recent gifters with avatars only (compact)
class RecentGiftersAvatars extends StatelessWidget {
  final List<Map<String, dynamic>> gifters;
  final int maxDisplay;

  const RecentGiftersAvatars({
    super.key,
    required this.gifters,
    this.maxDisplay = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (gifters.isEmpty) return const SizedBox.shrink();

    final displayGifters = gifters.take(maxDisplay).toList();
    final remaining = gifters.length - maxDisplay;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
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
              itemCount: displayGifters.length,
              itemBuilder: (context, index) {
                final gifter = displayGifters[index];
                final String name = gifter['name'] ?? 'Unknown';
                final String? avatar = gifter['avatar'];

                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Tooltip(
                    message: name,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: avatar != null
                          ? NetworkImage(avatar)
                          : null,
                      child: avatar == null
                          ? Text(name[0].toUpperCase())
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          if (remaining > 0)
            Container(
              margin: const EdgeInsets.only(left: 4),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Map<String, dynamic>>('gifters', gifters));
    properties.add(IntProperty('maxDisplay', maxDisplay));
  }
}

// Top gifters list
class TopGiftersList extends StatelessWidget {
  final List<Map<String, dynamic>> gifters;
  final Function(String)? onGifterTap;

  const TopGiftersList({
    super.key,
    required this.gifters,
    this.onGifterTap,
  });

  @override
  Widget build(BuildContext context) {
    if (gifters.isEmpty) {
      return const Center(
        child: Text(
          'No gifters yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gifters.length,
      itemBuilder: (context, index) {
        final gifter = gifters[index];
        final String name = gifter['name'] ?? 'Unknown';
        final String? avatar = gifter['avatar'];
        final int count = gifter['count'] ?? 0;
        final int total = gifter['total'] ?? 0;

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: avatar != null
                ? NetworkImage(avatar)
                : null,
            child: avatar == null
                ? Text(name[0].toUpperCase())
                : null,
          ),
          title: Text(name),
          subtitle: Text('$count gifts'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on,
                  size: 12,
                  color: Colors.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  '$total',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          onTap: onGifterTap != null
              ? () => onGifterTap!(gifter['userId'] ?? '')
              : null,
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<Map<String, dynamic>>('gifters', gifters));
  }
}