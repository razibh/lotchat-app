import 'package:flutter/material.dart';

class AppSectionHeader extends StatelessWidget {

  const AppSectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.padding = const EdgeInsets.all(16),
    this.titleStyle,
    this.subtitleStyle,
    this.leading,
    this.trailing,
  }) : super(key: key);
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
}

class SectionTitle extends StatelessWidget {

  const SectionTitle({
    Key? key,
    required this.title,
    this.style,
  }) : super(key: key);
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
}

class SectionWithIcon extends StatelessWidget {

  const SectionWithIcon({
    Key? key,
    required this.title,
    required this.icon,
    this.iconColor,
    this.onTap,
  }) : super(key: key);
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
}

class SectionHeaderWithCount extends StatelessWidget {

  const SectionHeaderWithCount({
    Key? key,
    required this.title,
    required this.count,
    this.onViewAll,
  }) : super(key: key);
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
}