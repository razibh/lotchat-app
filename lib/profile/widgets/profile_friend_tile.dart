import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import 'profile_avatar.dart';

class ProfileFriendTile extends StatelessWidget {

  const ProfileFriendTile({
    required this.user, super.key,
    this.onTap,
    this.onMessage,
    this.onFollow,
    this.showActions = true,
  });
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onMessage;
  final VoidCallback? onFollow;
  final bool showActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: ProfileAvatar(
          avatarUrl: user.photoURL,
          username: user.username,
          size: 40,
          isOnline: user.isOnline,
        ),
        title: Text(user.username),
        subtitle: Text(
          user.isOnline ? 'Online' : 'Last seen recently',
          style: TextStyle(
            color: user.isOnline ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: showActions
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: <>[
                  IconButton(
                    icon: const Icon(Icons.message, color: Colors.blue),
                    onPressed: onMessage,
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add, color: Colors.green),
                    onPressed: onFollow,
                  ),
                ],
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<UserModel>('user', user));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onMessage', onMessage));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onFollow', onFollow));
    properties.add(DiagnosticsProperty<bool>('showActions', showActions));
  }
}