import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/di/service_locator.dart';

class ChatProvider extends ChangeNotifier {
  final DatabaseService _databaseService = ServiceLocator().get<DatabaseService>();
  final SocketService _socketService = ServiceLocator().get<SocketService>();
  
  List<ChatModel> _chats = <>[];
  final List<ChatModel> _archivedChats = <>[];
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _chatSubscription;

  // Getters
  List<ChatModel> get chats => _chats;
  List<ChatModel> get archivedChats => _archivedChats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize
  void init(String userId) {
    _loadChats(userId);
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socketService.on('chat-updated', _updateChat);

    _socketService.on('chat-deleted', (data) {
      _removeChat(data['chatId']);
    });

    _socketService.on('new-message', _updateLastMessage);
  }

  // Load chats
  Future<void> _loadChats(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In real app, fetch from database
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _chats = List.generate(20, (int index) {
        final bool isGroup = index % 3 == 0;
        return ChatModel(
          id: 'chat_$index',
          type: isGroup ? 'group' : 'private',
          participants: isGroup 
              ? <String>['User 1', 'User 2', 'User 3']
              : <String>['User ${index + 1}'],
          groupName: isGroup ? 'Group ${index + 1}' : null,
          lastMessage: null,
          unreadCount: index % 5,
          createdAt: DateTime.now().subtract(Duration(days: index)),
          updatedAt: DateTime.now().subtract(Duration(hours: index)),
        );
      });

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get chat by id
  ChatModel? getChat(String chatId) {
    try {
      return _chats.firstWhere((Object? c) => c.id == chatId);
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
      final newChat = ChatModel(
        id: 'chat_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        participants: participants,
        groupName: groupName,
        groupAvatar: groupAvatar,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to database
      // await _databaseService.saveChat(newChat);

      _chats.insert(0, newChat);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update chat
  void _updateChat(Map<String, dynamic> data) {
    final int index = _chats.indexWhere((Object? c) => c.id == data['chatId']);
    if (index != -1) {
      // Update chat
      notifyListeners();
    }
  }

  void _updateLastMessage(Map<String, dynamic> data) {
    final int index = _chats.indexWhere((Object? c) => c.id == data['chatId']);
    if (index != -1) {
      // Update last message
      _chats[index].lastMessage = null; // Set actual message
      _chats[index].updatedAt = DateTime.now();
      
      // Move to top
      final chat = _chats.removeAt(index);
      _chats.insert(0, chat);
      
      notifyListeners();
    }
  }

  void _removeChat(String chatId) {
    _chats.removeWhere((Object? c) => c.id == chatId);
    notifyListeners();
  }

  // Chat actions
  Future<void> toggleMute(String chatId) async {
    final int index = _chats.indexWhere((Object? c) => c.id == chatId);
    if (index != -1) {
      _chats[index].isMuted = !_chats[index].isMuted;
      // Update in database
      // await _databaseService.updateChat(chatId, {'isMuted': _chats[index].isMuted});
      notifyListeners();
    }
  }

  Future<void> togglePin(String chatId) async {
    final int index = _chats.indexWhere((Object? c) => c.id == chatId);
    if (index != -1) {
      _chats[index].isPinned = !_chats[index].isPinned;
      
      if (_chats[index].isPinned) {
        // Move pinned chat to top
        final chat = _chats.removeAt(index);
        _chats.insert(0, chat);
      }
      
      // Update in database
      // await _databaseService.updateChat(chatId, {'isPinned': _chats[index].isPinned});
      notifyListeners();
    }
  }

  Future<void> toggleArchive(String chatId) async {
    final int index = _chats.indexWhere((Object? c) => c.id == chatId);
    if (index != -1) {
      final chat = _chats[index];
      chat.isArchived = !chat.isArchived;
      
      if (chat.isArchived) {
        _chats.removeAt(index);
        _archivedChats.insert(0, chat);
      } else {
        _archivedChats.removeWhere((Object? c) => c.id == chatId);
        _chats.insert(0, chat);
      }
      
      // Update in database
      // await _databaseService.updateChat(chatId, {'isArchived': chat.isArchived});
      notifyListeners();
    }
  }

  Future<void> deleteChat(String chatId) async {
    final confirm = await showDialog<bool>(
      context: _getContext(),
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat?'),
        actions: <>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _chats.removeWhere((Object? c) => c.id == chatId);
      _archivedChats.removeWhere((Object? c) => c.id == chatId);
      
      // Delete from database
      // await _databaseService.deleteChat(chatId);
      
      // Notify via socket
      _socketService.emit('chat-deleted', <String, String>{'chatId': chatId});
      
      notifyListeners();
    }
  }

  Future<void> markAsRead(String chatId) async {
    final int index = _chats.indexWhere((Object? c) => c.id == chatId);
    if (index != -1) {
      _chats[index].unreadCount = 0;
      // Update in database
      // await _databaseService.updateChat(chatId, {'unreadCount': 0});
      notifyListeners();
    }
  }

  // Search chats
  List<ChatModel> searchChats(String query) {
    if (query.isEmpty) return <>[];
    
    final String lowerQuery = query.toLowerCase();
    return _chats.where((Object? chat) {
      if (chat.type == 'private') {
        return chat.participants.first.toLowerCase().contains(lowerQuery);
      } else {
        return chat.groupName?.toLowerCase().contains(lowerQuery) ?? false;
      }
    }).toList();
  }

  // Helper to get context
  BuildContext? _getContext() {
    // This should be implemented with a navigator key
    return null;
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    super.dispose();
  }
}