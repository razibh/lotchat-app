import 'package:flutter/material.dart';

class AppTabController extends ChangeNotifier {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  int get currentIndex => _currentIndex;
  PageController get pageController => _pageController;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      _pageController.jumpToPage(index);
      notifyListeners();
    }
  }

  void animateToIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// Custom Tab Bar with Indicator
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {

  const CustomTabBar({
    Key? key,
    required this.tabs,
    required this.controller,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.isScrollable = false,
  }) : super(key: key);
  final List<Tab> tabs;
  final TabController controller;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        boxShadow: <>[
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        tabs: tabs,
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? Theme.of(context).primaryColor,
        labelColor: labelColor ?? Theme.of(context).primaryColor,
        unselectedLabelColor: unselectedLabelColor ?? Colors.grey,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

// Animated Tab Bar
class AnimatedTabBar extends StatefulWidget {

  const AnimatedTabBar({
    Key? key,
    required this.tabs,
    this.initialIndex = 0,
    required this.onTabChanged,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);
  final List<Widget> tabs;
  final int initialIndex;
  final ValueChanged<int> onTabChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  State<AnimatedTabBar> createState() => _AnimatedTabBarState();
}

class _AnimatedTabBarState extends State<AnimatedTabBar> 
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animations = List.generate(widget.tabs.length, (int index) {
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.1, 0.5 + index * 0.1),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: List.generate(widget.tabs.length, (int index) {
          return Expanded(
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return GestureDetector(
                  onTap: () {
                    if (_currentIndex != index) {
                      setState(() {
                        _currentIndex = index;
                      });
                      widget.onTabChanged(index);
                      _animationController.reset();
                      _animationController.forward();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: _currentIndex == index
                          ? (widget.activeColor ?? Theme.of(context).primaryColor)
                              .withOpacity(0.1 + _animations[index].value * 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(21),
                    ),
                    child: Transform.scale(
                      scale: _currentIndex == index
                          ? 1.0 + _animations[index].value * 0.1
                          : 1.0,
                      child: widget.tabs[index],
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
}

// Custom Tab for Tab Bar
class CustomTab extends StatelessWidget {

  const CustomTab({
    Key? key,
    required this.icon,
    required this.label,
    this.isSelected = false,
  }) : super(key: key);
  final IconData icon;
  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          Icon(
            icon,
            color: isSelected 
                ? Theme.of(context).primaryColor
                : Colors.grey,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}