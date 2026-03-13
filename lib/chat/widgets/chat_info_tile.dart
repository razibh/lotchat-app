import 'package:flutter/material.dart';

class ChatInfoTile extends StatelessWidget {

  const ChatInfoTile({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
  }) : super(key: key);
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? Colors.grey).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.grey),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}