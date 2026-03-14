import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppSvgIcon extends StatelessWidget {

  const AppSvgIcon({
    required this.assetName, super.key,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.onTap,
  });
  final String assetName;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        assetName,
        width: width,
        height: height,
        color: color,
        fit: fit,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('assetName', assetName));
    properties.add(DoubleProperty('width', width));
    properties.add(DoubleProperty('height', height));
    properties.add(ColorProperty('color', color));
    properties.add(EnumProperty<BoxFit>('fit', fit));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}

class AppSvgIconButton extends StatelessWidget {

  const AppSvgIconButton({
    required this.assetName, required this.size, required this.onPressed, super.key,
    this.color,
    this.tooltip,
  });
  final String assetName;
  final double size;
  final Color? color;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SvgPicture.asset(
        assetName,
        width: size,
        height: size,
        color: color,
      ),
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('assetName', assetName));
    properties.add(DoubleProperty('size', size));
    properties.add(ColorProperty('color', color));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onPressed', onPressed));
    properties.add(StringProperty('tooltip', tooltip));
  }
}

class AnimatedSvgIcon extends StatefulWidget {

  const AnimatedSvgIcon({
    required this.assetName, required this.size, super.key,
    this.color,
    this.duration = const Duration(milliseconds: 200),
    this.onTap,
  });
  final String assetName;
  final double size;
  final Color? color;
  final Duration duration;
  final VoidCallback? onTap;

  @override
  State<AnimatedSvgIcon> createState() => _AnimatedSvgIconState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('assetName', assetName));
    properties.add(DoubleProperty('size', size));
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<Duration>('duration', duration));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}

class _AnimatedSvgIconState extends State<AnimatedSvgIcon> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _animation = Tween<double>(begin: 1, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget? child) {
          return Transform.scale(
            scale: _animation.value,
            child: SvgPicture.asset(
              widget.assetName,
              width: widget.size,
              height: widget.size,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class SvgIconWithLabel extends StatelessWidget {

  const SvgIconWithLabel({
    required this.assetName, required this.label, super.key,
    this.iconSize = 24,
    this.fontSize = 12,
    this.color,
    this.onTap,
  });
  final String assetName;
  final String label;
  final double iconSize;
  final double fontSize;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <>[
          SvgPicture.asset(
            assetName,
            width: iconSize,
            height: iconSize,
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: color ?? Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('assetName', assetName));
    properties.add(StringProperty('label', label));
    properties.add(DoubleProperty('iconSize', iconSize));
    properties.add(DoubleProperty('fontSize', fontSize));
    properties.add(ColorProperty('color', color));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}

// Helper class for SVG assets
class SvgAssets {
  static const String home = 'assets/svgs/home.svg';
  static const String explore = 'assets/svgs/explore.svg';
  static const String chat = 'assets/svgs/chat.svg';
  static const String profile = 'assets/svgs/profile.svg';
  static const String settings = 'assets/svgs/settings.svg';
  static const String notification = 'assets/svgs/notification.svg';
  static const String search = 'assets/svgs/search.svg';
  static const String filter = 'assets/svgs/filter.svg';
  static const String add = 'assets/svgs/add.svg';
  static const String edit = 'assets/svgs/edit.svg';
  static const String delete = 'assets/svgs/delete.svg';
  static const String share = 'assets/svgs/share.svg';
  static const String like = 'assets/svgs/like.svg';
  static const String comment = 'assets/svgs/comment.svg';
  static const String bookmark = 'assets/svgs/bookmark.svg';
  static const String more = 'assets/svgs/more.svg';
  static const String back = 'assets/svgs/back.svg';
  static const String close = 'assets/svgs/close.svg';
  static const String menu = 'assets/svgs/menu.svg';
  static const String refresh = 'assets/svgs/refresh.svg';

  // Social
  static const String google = 'assets/svgs/social/google.svg';
  static const String facebook = 'assets/svgs/social/facebook.svg';
  static const String apple = 'assets/svgs/social/apple.svg';
  static const String twitter = 'assets/svgs/social/twitter.svg';
  static const String instagram = 'assets/svgs/social/instagram.svg';

  // Wallet
  static const String coin = 'assets/svgs/wallet/coin.svg';
  static const String diamond = 'assets/svgs/wallet/diamond.svg';
  static const String wallet = 'assets/svgs/wallet/wallet.svg';
  static const String card = 'assets/svgs/wallet/card.svg';

  // Games
  static const String roulette = 'assets/svgs/games/roulette.svg';
  static const String cards = 'assets/svgs/games/cards.svg';
  static const String dice = 'assets/svgs/games/dice.svg';
  static const String trophy = 'assets/svgs/games/trophy.svg';
}