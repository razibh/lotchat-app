import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {

  const AppSectionHeader({
    required this.title, super.key,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.padding = const EdgeInsets.all(16),
    this.titleStyle,
    this.subtitleStyle,
    this.leading,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final EdgeInsets padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: <>[
          if (leading != null) ...<>[
            leading,
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  title,
                  style: titleStyle ?? const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...<>[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: subtitleStyle ?? const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionText != null && onActionPressed != null)
            TextButton(
              onPressed: onActionPressed,
              child: Text(actionText!),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(StringProperty('subtitle', subtitle));
    properties.add(StringProperty('actionText', actionText));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onActionPressed', onActionPressed));
    properties.add(DiagnosticsProperty<EdgeInsets>('padding', padding));
    properties.add(DiagnosticsProperty<TextStyle?>('titleStyle', titleStyle));
    properties.add(DiagnosticsProperty<TextStyle?>('subtitleStyle', subtitleStyle));
  }
}

class SectionTitle extends StatelessWidget {

  const SectionTitle({
    required this.title, super.key,
    this.style,
  });
  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: style ?? const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<TextStyle?>('style', style));
  }
}

class SectionWithIcon extends StatelessWidget {

  const SectionWithIcon({
    required this.title, required this.icon, super.key,
    this.iconColor,
    this.onTap,
  });
  final String title;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <>[
            Icon(
              icon,
              color: iconColor ?? Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(DiagnosticsProperty<IconData>('icon', icon));
    properties.add(ColorProperty('iconColor', iconColor));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}

class SectionHeaderWithCount extends StatelessWidget {

  const SectionHeaderWithCount({
    required this.title, required this.count, super.key,
    this.onViewAll,
  });
  final String title;
  final int count;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text('View All'),
            ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('title', title));
    properties.add(IntProperty('count', count));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onViewAll', onViewAll));
  }
}