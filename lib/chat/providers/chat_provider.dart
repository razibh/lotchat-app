import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/di/service_locator.dart';

class ChatProvider extends ChangeNotifier {

  ChatProvider() {
    _initializeServices();
  }
  late final DatabaseService _databaseService;
  late final SocketService _socketService;

  List<ChatModel> _chats = <ChatModel>[];
  final List<ChatModel> _archivedChats = <ChatModel>[];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _chatSubscription;

  // Getters
  List<ChatModel> get chats => _chats;
  List<ChatModel> get archivedChats => _archivedChats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _initializeServices() {
    try {
      _databaseService = ServiceLocator.instance.get<DatabaseService>();
      _socketService = ServiceLocator.instance.get<SocketService>();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  // Initialize
  void init(String userId) {
    _loadChats(userId);
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    try {
      _socketService.on('chat-updated', _updateChat);

      _socketService.on('chat-deleted', (dynamic data) {
        if (data is Map<String, dynamic>) {
          final String? chatId = data['chatId'] as String?;
          if (chatId != null) {
            _removeChat(chatId);
          }
        }
      });

      _socketService.on('new-message', _updateLastMessage);
    } catch (e) {
      debugPrint('Socket setup error: $e');
    }
  }

  // Load chats
  Future<void> _loadChats(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In real app, fetch from database
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - using only fields that exist in ChatModel
      _chats = List.generate(5, (int index) {
        final bool isGroup = index % 3 == 0;
        return ChatModel(
          id: 'chat_$index',
          type: isGroup ? 'group' : 'private',
          participants: isGroup
              ? <String>['User 1', 'User 2', 'User 3']
              : <String>['User ${index + 1}'],
          groupName: isGroup ? 'Group ${index + 1}' : null,
          lastMessage: 'Last message ${index + 1}',
          lastMessageTime: DateTime.now().subtract(Duration(hours: index)),
        );
      });

      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get chat by id
  ChatModel? getChat(String chatId) {
    try {
      return _chats.firstWhere((ChatModel c) => c.id == chatId);
    } catch (e) {
      return null;
    }
  }

  // Create new chat
  Future<void> createChat({
    required String type,
    required List<String> participants,
    String? groupName,
    String? groupAvatar,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final ChatModel newChat = ChatModel(
        id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        participants: participants,
        groupName: groupName,
        groupAvatar: groupAvatar,
        lastMessageTime: DateTime.now(),
      );

      // Save to database
      try {
        await _databaseService.saveChat(newChat);
      } catch (e) {
        debugPrint('Error saving chat to database: $e');
      }

      _chats.insert(0, newChat);
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update chat
  void _updateChat(dynamic data) {
    if (data is Map<String, dynamic>) {
      final String? chatId = data['chatId'] as String?;
      if (chatId != null) {
        final int index = _chats.indexWhere((ChatModel c) => c.id == chatId);
        if (index != -1) {
          // Update chat logic here
          // You can update specific fields from data
          notifyListeners();
        }
      }
    }
  }

  void _updateLastMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final String? chatId = data['chatId'] as String?;
      final String? message = data['message'] as String?;
      final DateTime? time = data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'] as String)
          : DateTime.now();

      if (chatId != null) {
        final int index = _chats.indexWhere((ChatModel c) => c.id == chatId);
        if (index != -1) {
          // Update last message
          final ChatModel updatedChat = ChatModel(
            id: _chats[index].id,
            type: _chats[index].type,
            participants: _chats[index].participants,
            groupName: _chats[index].groupName,
            groupAvatar: _chats[index].groupAvatar,
            lastMessage: message ?? _chats[index].lastMessage,
            lastMessageTime: time,
          );

          // Move to top
          _chats.removeAt(index);
          _chats.insert(0, updatedChat);

          notifyListeners();
        }
      }
    }
  }

  void _removeChat(String chatId) {
    if (chatId.isNotEmpty) {
      _chats.removeWhere((ChatModel c) => c.id == chatId);
      _archivedChats.removeWhere((ChatModel c) => c.id == chatId);
      notifyListeners();
    }
  }

  // Toggle mute (stored separately since ChatModel doesn't have isMuted)
  final Map<String, bool> _mutedChats = <String, bool>{};

  bool isChatMuted(String chatId) {
    return _mutedChats[chatId] ?? false;
  }

  Future<void> toggleMute(String chatId) async {
    final bool currentValue = _mutedChats[chatId] ?? false;
    _mutedChats[chatId] = !currentValue;

    // Update in database if needed
    // await _databaseService.updateChat(chatId, {'isMuted': !currentValue});

    notifyListeners();
    debugPrint('Chat $chatId muted: ${!currentValue}');
  }

  // Toggle pin (stored separately since ChatModel doesn't have isPinned)
  final Map<String, bool> _pinnedChats = <String, bool>{};

  bool isChatPinned(String chatId) {
    return _pinnedChats[chatId] ?? false;
  }

  Future<void> togglePin(String chatId) async {
    final bool currentValue = _pinnedChats[chatId] ?? false;
    _pinnedChats[chatId] = !currentValue;

    if (!currentValue) {
      // Move pinned chat to top
      final int index = _chats.indexWhere((ChatModel c) => c.id == chatId);
      if (index != -1) {
        final ChatModel chat = _chats.removeAt(index);
        _chats.insert(0, chat);
      }
    }

    // Update in database if needed
    // await _databaseService.updateChat(chatId, {'isPinned': !currentValue});

    notifyListeners();
    debugPrint('Chat $chatId pinned: ${!currentValue}');
  }

  // Archive/Unarchive chat
  Future<void> toggleArchive(String chatId) async {
    final bool isArchived = _archivedChats.any((ChatModel c) => c.id == chatId);

    if (isArchived) {
      // Unarchive
      final int index = _archivedChats.indexWhere((ChatModel c) => c.id == chatId);
      if (index != -1) {
        final ChatModel chat = _archivedChats.removeAt(index);
        _chats.insert(0, chat);
      }
    } else {
      // Archive
      final int index = _chats.indexWhere((ChatModel c) => c.id == chatId);
      if (index != -1) {
        final ChatModel chat = _chats.removeAt(index);
        _archivedChats.insert(0, chat);
      }
    }

    // Update in database if needed
    // await _databaseService.updateChat(chatId, {'isArchived': !isArchived});

    notifyListeners();
    debugPrint('Chat $chatId archived: ${!isArchived}');
  }

  // Delete chat
  Future<void> deleteChat(String chatId) async {
    _chats.removeWhere((ChatModel c) => c.id == chatId);
    _archivedChats.removeWhere((ChatModel c) => c.id == chatId);
    _mutedChats.remove(chatId);
    _pinnedChats.remove(chatId);

    // Delete from database
    try {
      await _databaseService.deleteChat(chatId);
    } catch (e) {
      debugPrint('Error deleting chat from database: $e');
    }

    // Notify via socket
    try {
      _socketService.emit('chat-deleted', <String, dynamic>{'chatId': chatId});
    } catch (e) {
      debugPrint('Error emitting chat-deleted: $e');
    }

    notifyListeners();
  }

  // Mark as read
  Future<void> markAsRead(String chatId) async {
    // Implement mark as read logic
    debugPrint('Mark chat as read: $chatId');
  }

  // Search chats
  List<ChatModel> searchChats(String query) {
    if (query.isEmpty) return <ChatModel>[];

    final String lowerQuery = query.toLowerCase();
    return _chats.where((ChatModel chat) {
      if (chat.type == 'private') {
        return chat.participants.isNotEmpty &&
            chat.participants.first.toLowerCase().contains(lowerQuery);
      } else {
        return chat.groupName?.toLowerCase().contains(lowerQuery) ?? false;
      }
    }).toList();
  }

  // Get pinned chats
  List<ChatModel> getPinnedChats() {
    return _chats.where((ChatModel chat) => _pinnedChats[chat.id] ?? false).toList();
  }

  // Get regular chats (not pinned)
  List<ChatModel> getRegularChats() {
    return _chats.where((ChatModel chat) => _pinnedChats[chat.id] != true).toList();
  }

  // Unarchive chat
  void unarchiveChat(String chatId) {
    final int index = _archivedChats.indexWhere((ChatModel c) => c.id == chatId);
    if (index != -1) {
      final ChatModel chat = _archivedChats.removeAt(index);
      _chats.insert(0, chat);
      notifyListeners();
    }
  }

  // Clear all data
  void clear() {
    _chats.clear();
    _archivedChats.clear();
    _mutedChats.clear();
    _pinnedChats.clear();
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}