import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;  // ✅ Supabase User hide

import '../../core/di/service_locator.dart';
import '../clan/services/clan_service.dart';
import '../../core/services/socket_service.dart';
import '../../core/services/auth_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../mixins/dialog_mixin.dart';

// ইম্পোর্ট
import '../../core/models/clan_model.dart';
import '../../core/models/gift_model.dart';
import '../clan/models/clan_member_model.dart';

import 'widgets/clan_chat_bubble.dart' as bubble;
import '../../widgets/gift_panel.dart';

class ClanChatScreen extends StatefulWidget {
  final String clanId;
  final String clanName;

  const ClanChatScreen({
    super.key,
    required this.clanId,
    required this.clanName,
  });

  @override
  State<ClanChatScreen> createState() => _ClanChatScreenState();
}

class _ClanChatScreenState extends State<ClanChatScreen>
    with LoadingMixin, ToastMixin, DialogMixin {
  final ClanService _clanService = ServiceLocator().get<ClanService>();
  final SocketService _socketService = ServiceLocator().get<SocketService>();
  final AuthService _authService = ServiceLocator().get<AuthService>();

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _showGiftPanel = false;

  String? _currentUserId;
  ClanModel? _clan;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadClan();
    _loadMessages();
    _setupSocket();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _socketService.emit('leave-clan-chat', {'clanId': widget.clanId});
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    // ✅ Firebase Auth → Supabase Auth
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _currentUserId = session?.user.id;
    });
  }

  Future<void> _loadClan() async {
    try {
      final clan = await _clanService.getClan(widget.clanId);
      setState(() {
        _clan = clan;
      });
    } catch (e) {
      debugPrint("Clan load error $e");
    }
  }

  Future<void> _loadMessages() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final data = List.generate(10, (index) {
      bool isMe = index % 2 == 0;
      return {
        "id": "msg_$index",
        "userId": isMe ? _currentUserId : "user_$index",
        "username": isMe ? "You" : "User $index",
        "avatar": null,
        "message": "Message number ${index + 1}",
        "timestamp": DateTime.now().toIso8601String(),
        "type": "text",
        "reactions": {},
        "isPinned": index == 0
      };
    });

    setState(() {
      _messages = data.reversed.toList();
      _isLoading = false;
    });
  }

  void _setupSocket() {
    _socketService.emit('join-clan-chat', {"clanId": widget.clanId});

    _socketService.on('clan-message', (data) {
      if (!mounted) return;
      if (data is Map<String, dynamic>) {
        setState(() {
          _messages.insert(0, data);
        });
      }
    });

    _socketService.on('clan-typing', (data) {
      if (data['userId'] != _currentUserId) {
        setState(() => _isTyping = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isTyping = false);
        });
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final msg = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "userId": _currentUserId,
      "username": "You",
      "message": _messageController.text,
      "timestamp": DateTime.now().toIso8601String(),
      "type": "text",
      "reactions": {}
    };

    _socketService.emit("clan-message", {
      "clanId": widget.clanId,
      "message": _messageController.text
    });

    setState(() {
      _messages.insert(0, msg);
      _messageController.clear();
    });
  }

  void _sendGift(GiftModel gift) {
    final msg = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "userId": _currentUserId,
      "username": "You",
      "gift": {
        'id': gift.id,
        'name': gift.name,
        'price': gift.price,
      },
      "timestamp": DateTime.now().toIso8601String(),
      "type": "gift",
      "reactions": {}
    };

    setState(() {
      _messages.insert(0, msg);
      _showGiftPanel = false;
    });

    showSuccess("Gift Sent 🎁");
  }

  void _addReaction(String messageId) {
    final index = _messages.indexWhere((m) => m['id'] == messageId);
    if (index == -1) return;

    final reactions = Map<String, int>.from(_messages[index]['reactions'] ?? {});
    reactions['👍'] = (reactions['👍'] ?? 0) + 1;

    setState(() {
      _messages[index]['reactions'] = reactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              backgroundImage:
              _clan?.emblem != null ? NetworkImage(_clan!.emblem!) : null,
              child: _clan?.emblem == null ? const Icon(Icons.groups) : null,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_clan?.name ?? widget.clanName),
                Text(
                  "${_clan?.memberCount ?? 0} members",
                  style: const TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
      ),
      body: Column(
        children: [
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(6),
              child: Text("Someone is typing..."),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMe = message['userId'] == _currentUserId;

                final sender = ClanMemberModel(
                  userId: message['userId'] ?? "",
                  username: message['username'] ?? "",
                  role: MemberClanRole.member,
                  status: MemberOnlineStatus.online,
                  joinedAt: DateTime.now(),
                  avatar: message['avatar'],
                );

                final timestamp = DateTime.parse(message['timestamp']);

                bubble.MessageType type = message['type'] == "gift"
                    ? bubble.MessageType.gift
                    : bubble.MessageType.text;

                return bubble.ClanChatBubble(
                  sender: sender,
                  message: message['message'] ?? "",
                  type: type,
                  timestamp: timestamp,
                  isMe: isMe,
                  showAvatar: true,
                  showName: true,
                  giftName: message['gift']?['name'],
                  giftPrice: message['gift']?['price'],
                  reactions: message['reactions'],
                  onReact: () => _addReaction(message['id']),
                  onReply: () {},
                  onPin: () {},
                  onReport: () {},
                );
              },
            ),
          ),
          if (_showGiftPanel)
            GiftPanel(
              onSendGift: _sendGift,
              onClose: () => setState(() => _showGiftPanel = false),
              receiverId: _currentUserId ?? "",
            ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type message...",
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.card_giftcard),
                  onPressed: () =>
                      setState(() => _showGiftPanel = !_showGiftPanel),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}