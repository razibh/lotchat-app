import 'package:flutter/material.dart';

class ProfileTabBar extends StatelessWidget {

  const ProfileTabBar({
    required this.tabController, super.key,
  });
  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        tabs: const <>[
          Tab(
            icon: Icon(Icons.grid_on),
            text: 'Posts',
          ),
          Tab(
            icon: Icon(Icons.card_giftcard),
            text: 'Gifts',
          ),
          Tab(
            icon: Icon(Icons.info),
            text: 'About',
          ),
        ],
        indicatorColor: Colors.blue,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TabController>('tabController', tabController));
  }
}

// Custom Tab Bar with Indicators
class CustomProfileTabBar extends StatelessWidget {

  const CustomProfileTabBar({
    required this.currentIndex, required this.onTap, super.key,
  });
  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: <>[
          _buildTabItem(
            index: 0,
            icon: Icons.grid_on,
            label: 'Posts',
            isSelected: currentIndex == 0,
          ),
          _buildTabItem(
            index: 1,
            icon: Icons.card_giftcard,
            label: 'Gifts',
            isSelected: currentIndex == 1,
          ),
          _buildTabItem(
            index: 2,
            icon: Icons.info,
            label: 'About',
            isSelected: currentIndex == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <>[
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('currentIndex', currentIndex));
    properties.add(ObjectFlagProperty<Function(int)>.has('onTap', onTap));
  }
}

// Animated Tab Bar
class AnimatedProfileTabBar extends StatefulWidget {

  const AnimatedProfileTabBar({
    required this.currentIndex, required this.onTap, super.key,
  });
  final int currentIndex;
  final Function(int) onTap;

  @override
  State<AnimatedProfileTabBar> createState() => _AnimatedProfileTabBarState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('currentIndex', currentIndex));
    properties.add(ObjectFlagProperty<Function(int)>.has('onTap', onTap));
  }
}

class _AnimatedProfileTabBarState extends State<AnimatedProfileTabBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animations = List.generate(3, (int index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.1, 0.5 + index * 0.1),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: List.generate(3, (int index) {
          return Expanded(
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (BuildContext context, Widget? child) {
                return GestureDetector(
                  onTap: () {
                    if (widget.currentIndex != index) {
                      widget.onTap(index);
                      _controller.reset();
                      _controller.forward();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.currentIndex == index
                          ? Colors.blue.withValues(alpha: 0.1 + _animations[index].value * 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Transform.scale(
                      scale: widget.currentIndex == index
                          ? 1.0 + _animations[index].value * 0.05
                          : 1.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <>[
                          Icon(
                            _getIcon(index),
                            color: widget.currentIndex == index
                                ? Colors.blue
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getLabel(index),
                            style: TextStyle(
                              color: widget.currentIndex == index
                                  ? Colors.blue
                                  : Colors.grey,
                              fontWeight: widget.currentIndex == index
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  IconData _getIcon(int index) {
    switch (index) {
      case 0:
        return Icons.grid_on;
      case 1:
        return Icons.card_giftcard;
      case 2:
        return Icons.info;
      default:
        return Icons.error;
    }
  }

  String _getLabel(int index) {
    switch (index) {
      case 0:
        return 'Posts';
      case 1:
        return 'Gifts';
      case 2:
        return 'About';
      default:
        return '';
    }
  }
}