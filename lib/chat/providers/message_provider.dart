import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../../../core/services/database_service.dart';
import '../../../core/services/socket_service.dart';
import '../../../core/di/service_locator.dart';

class MessageProvider extends ChangeNotifier {
  final DatabaseService _databaseService = ServiceLocator().get<DatabaseService>();
  final SocketService _socketService = ServiceLocator().get<SocketService>();
  
  List<MessageModel> _messages = <MessageModel>[];
  final Map<String, List<MessageModel>> _messagesByChat = <String, List<MessageModel>>{};
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;
  MessageModel? _replyingTo;

  // Getters
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;
  MessageModel? get replyingTo => _replyingTo;

  // Load messages for a chat
  Future<void> loadMessages(String chatId, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _messages = <MessageModel>[];
      _hasMore = true;
    }

    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // In real app, fetch from database with pagination
      await Future.delayed(const Duration(milliseconds: 500));
      
      final List<MessageModel> newMessages = List.generate(20, (int index) {
        final bool isMe = index % 3 == 0;
        return MessageModel(
          id: 'msg_${_currentPage}_$index',
          chatId: chatId,
          senderId: isMe ? 'current_user' : 'user_$index',
          senderName: isMe ? 'You' : 'User ${index + 1}',
          type: index % 5 == 0 ? MessageType.image : MessageType.text,
          status: MessageStatus.read,
          content: 'This is message ${_currentPage * 20 + index + 1}',
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
          readBy: isMe ? <String>[] : <String>['current_user'],
          reactions: index % 4 == 0 
              ? <MessageReaction>[MessageReaction(
                  userId: 'user_${index + 1}',
                  reaction: '👍',
                  timestamp: DateTime.now(),
                )]
              : <MessageReaction>[],
        );
      });

      if (newMessages.isEmpty) {
        _hasMore = false;
      } else {
        _messages.insertAll(0, newMessages);
        _currentPage++;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send message
  Future<void> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    double? duration,
    double? latitude,
    double? longitude,
    String? placeName,
    String? contactName,
    String? contactPhone,
    String? giftId,
    String? giftName,
    int? giftPrice,
  }) async {
    final MessageModel newMessage = MessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      chatId: chatId,
      senderId: 'current_user',
      senderName: 'You',
      type: type,
      status: MessageStatus.sending,
      content: content,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      fileSize: fileSize,
      duration: duration,
      latitude: latitude,
      longitude: longitude,
      placeName: placeName,
      contactName: contactName,
      contactPhone: contactPhone,
      giftId: giftId,
      giftName: giftName,
      giftPrice: giftPrice,
      timestamp: DateTime.now(),
      readBy: <String>[],
      reactions: <MessageReaction>[],
      replyTo: _replyingTo,
    );

    // Add to UI immediately
    _messages.add(newMessage);
    notifyListeners();

    try {
      // Send to server
      _socketService.emit('send-message', newMessage.toJson());

      // Update status to sent after a delay (mock)
      await Future.delayed(const Duration(seconds: 1));
      
      final int index = _messages.indexWhere((MessageModel m) => m.id == newMessage.id);
      if (index != -1) {
        _messages[index].status = MessageStatus.sent;
        notifyListeners();
      }

      // Clear reply
      _replyingTo = null;
    } catch (e) {
      final int index = _messages.indexWhere((MessageModel m) => m.id == newMessage.id);
      if (index != -1) {
        _messages[index].status = MessageStatus.failed;
        notifyListeners();
      }
    }
  }

  // Add message from socket
  void addMessage(Map<String, dynamic> data) {
    final MessageModel message = MessageModel.fromJson(data);
    
    // Check if already exists
    final bool exists = _messages.any((MessageModel m) => m.id == message.id);
    if (!exists) {
      _messages.add(message);
      notifyListeners();
    }
  }

  // Delete message
  Future<void> deleteMessage(String messageId, {bool forEveryone = false}) async {
    final int index = _messages.indexWhere((MessageModel m) => m.id == messageId);
    if (index != -1) {
      if (forEveryone) {
        _messages.removeAt(index);
        _socketService.emit('delete-message', <String, String>{'messageId': messageId});
      } else {
        _messages[index].content = 'This message was deleted';
        _messages[index].type = MessageType.system;
        _messages[index].deletedAt = DateTime.now();
      }
      notifyListeners();
    }
  }

  // Edit message
  Future<void> editMessage(String messageId, String newContent) async {
    final int index = _messages.indexWhere((MessageModel m) => m.id == messageId);
    if (index != -1) {
      _messages[index].content = newContent;
      _messages[index].editedAt = DateTime.now();
      
      _socketService.emit('edit-message', <String, String>{
        'messageId': messageId,
        'content': newContent,
      });
      
      notifyListeners();
    }
  }

  // Add reaction
  Future<void> addReaction(String messageId, String reaction) async {
    final int index = _messages.indexWhere((MessageModel m) => m.id == messageId);
    if (index != -1) {
      // Check if user already reacted
      final int existingIndex = _messages[index].reactions
          .indexWhere((MessageReaction r) => r.userId == 'current_user');
      
      if (existingIndex != -1) {
        // Update existing reaction
        _messages[index].reactions[existingIndex] = MessageReaction(
          userId: 'current_user',
          reaction: reaction,
          timestamp: DateTime.now(),
        );
      } else {
        // Add new reaction
        _messages[index].reactions.add(MessageReaction(
          userId: 'current_user',
          reaction: reaction,
          timestamp: DateTime.now(),
        ));
      }
      
      _socketService.emit('add-reaction', <String, String>{
        'messageId': messageId,
        'reaction': reaction,
      });
      
      notifyListeners();
    }
  }

  // Remove reaction
  Future<void> removeReaction(String messageId, String reaction) async {
    final int index = _messages.indexWhere((MessageModel m) => m.id == messageId);
    if (index != -1) {
      _messages[index].reactions
          .removeWhere((MessageReaction r) => r.userId == 'current_user' && r.reaction == reaction);
      
      _socketService.emit('remove-reaction', <String, String>{
        'messageId': messageId,
        'reaction': reaction,
      });
      
      notifyListeners();
    }
  }

  // Set reply
  void setReplyTo(MessageModel? message) {
    _replyingTo = message;
    notifyListeners();
  }

  // Clear reply
  void clearReply() {
    _replyingTo = null;
    notifyListeners();
  }

  // Mark messages as read
  Future<void> markAsRead(List<String> messageIds) async {
    for (String id in messageIds) {
      final int index = _messages.indexWhere((MessageModel m) => m.id == id);
      if (index != -1 && !_messages[index].readBy.contains('current_user')) {
        _messages[index].readBy.add('current_user');
      }
    }
    
    _socketService.emit('mark-read', <String, List<String>>{'messageIds': messageIds});
    notifyListeners();
  }

  // Forward message
  Future<void> forwardMessage(MessageModel message, String targetChatId) async {
    await sendMessage(
      chatId: targetChatId,
      content: message.content,
      type: message.type,
      mediaUrl: message.mediaUrl,
      thumbnailUrl: message.thumbnailUrl,
      fileName: message.fileName,
      fileSize: message.fileSize,
      duration: message.duration,
      latitude: message.latitude,
      longitude: message.longitude,
      placeName: message.placeName,
      contactName: message.contactName,
      contactPhone: message.contactPhone,
      giftId: message.giftId,
      giftName: message.giftName,
      giftPrice: message.giftPrice,
    );
  }

  // Search messages
  List<MessageModel> searchMessages(String chatId, String query) {
    if (query.isEmpty) return <MessageModel>[];
    
    final String lowerQuery = query.toLowerCase();
    return _messages.where((MessageModel msg) {
      return msg.chatId == chatId && 
             msg.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Clear messages
  void clearMessages() {
    _messages.clear();
    _currentPage = 0;
    _hasMore = true;
    notifyListeners();
  }

  // Retry failed messages
  Future<void> retryMessage(String messageId) async {
    final int index = _messages.indexWhere((MessageModel m) => m.id == messageId);
    if (index != -1 && _messages[index].status == MessageStatus.failed) {
      _messages[index].status = MessageStatus.sending;
      notifyListeners();

      try {
        _socketService.emit('send-message', _messages[index].toJson());
        await Future.delayed(const Duration(seconds: 1));
        _messages[index].status = MessageStatus.sent;
        notifyListeners();
      } catch (e) {
        _messages[index].status = MessageStatus.failed;
        notifyListeners();
      }
    }
  }
}