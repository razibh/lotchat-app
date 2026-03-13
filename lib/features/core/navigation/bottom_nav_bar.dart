import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../../../core/constants/asset_constants.dart';
import '../../../core/services/notification_service.dart';

class BottomNavBar extends StatefulWidget {

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);
  final int currentIndex;
  final Function(int) onTap;

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _notificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotificationCount();
  }

  Future<void> _loadNotificationCount() async {
    final count = await NotificationService().getUnreadCount();
    setState(() {
      _notificationCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: <>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: <>[
                const Icon(Icons.chat_outlined),
                if (_notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _notificationCount > 9 ? '9+' : '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            activeIcon: Stack(
              children: <>[
                const Icon(Icons.chat),
                if (_notificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        _notificationCount > 9 ? '9+' : '$_notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Chat',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Animated Bottom Navigation Bar
class AnimatedBottomNavBar extends StatefulWidget {

  const AnimatedBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);
  final int currentIndex;
  final Function(int) onTap;

  @override
  State<AnimatedBottomNavBar> createState() => _AnimatedBottomNavBarState();
}

class _AnimatedBottomNavBarState extends State<AnimatedBottomNavBar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animations = List.generate(4, (int index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 0.5 + index * 0.1,
              curve: Curves.elasticOut),
        ),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        boxShadow: <>[
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (int index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Transform.scale(
                scale: 0.8 + _animations[index].value * 0.2,
                child: _buildNavItem(
                  index: index,
                  isSelected: widget.currentIndex == index,
                  onTap: () => widget.onTap(index),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData icon;
    String label;

    switch (index) {
      case 0:
        icon = isSelected ? Icons.home : Icons.home_outlined;
        label = 'Home';
      case 1:
        icon = isSelected ? Icons.explore : Icons.explore_outlined;
        label = 'Discover';
      case 2:
        icon = isSelected ? Icons.chat : Icons.chat_outlined;
        label = 'Chat';
      case 3:
        icon = isSelected ? Icons.person : Icons.person_outlined;
        label = 'Profile';
      default:
        icon = Icons.error;
        label = '';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Icon(
              icon,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected 
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}