// lib/core/models/transaction_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Color এর জন্য

enum TransactionType {
  purchase,
  giftSent,
  giftReceived,
  game,
  pk,
  clan,
  reward,
  bonus,
  withdrawal,
  refund,
  commission,
  transfer,
  system,
}

enum TransactionStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
  refunded,
}

class TransactionModel {
  final String id;
  final String userId;
  final String? sellerId;
  final TransactionType type;         // purchase, gift_sent, gift_received, game
  final int amount;
  final int coinsBefore;
  final int coinsAfter;
  final String? description;
  final DateTime timestamp;
  final Map<String, dynamic> metadata; // giftId, gameId etc.

  // Additional fields
  final String? recipientId;
  final String? recipientName;
  final String? recipientAvatar;
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;
  final String? referenceId;
  final String? referenceType; // 'gift', 'game', 'pk', etc.
  final TransactionStatus status;
  final double? monetaryAmount;
  final String? currency;
  final String? paymentMethod;
  final String? paymentId;
  final DateTime? processedAt;
  final DateTime? completedAt;
  final DateTime? failedAt;
  final String? failureReason;
  final String? invoiceUrl;
  final String? receiptUrl;
  final Map<String, dynamic>? analytics;
  final Map<String, dynamic>? extraData;

  TransactionModel({
    required this.id,
    required this.userId,
    this.sellerId,
    required this.type,
    required this.amount,
    required this.coinsBefore,
    required this.coinsAfter,
    this.description,
    required this.timestamp,
    this.metadata = const {},
    this.recipientId,
    this.recipientName,
    this.recipientAvatar,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    this.referenceId,
    this.referenceType,
    this.status = TransactionStatus.completed,
    this.monetaryAmount,
    this.currency,
    this.paymentMethod,
    this.paymentId,
    this.processedAt,
    this.completedAt,
    this.failedAt,
    this.failureReason,
    this.invoiceUrl,
    this.receiptUrl,
    this.analytics,
    this.extraData,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      sellerId: json['sellerId'],
      type: _parseTransactionType(json['type']),
      amount: json['amount'] ?? 0,
      coinsBefore: json['coinsBefore'] ?? 0,
      coinsAfter: json['coinsAfter'] ?? 0,
      description: json['description'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      metadata: json['metadata'] ?? {},
      recipientId: json['recipientId'],
      recipientName: json['recipientName'],
      recipientAvatar: json['recipientAvatar'],
      senderId: json['senderId'],
      senderName: json['senderName'],
      senderAvatar: json['senderAvatar'],
      referenceId: json['referenceId'],
      referenceType: json['referenceType'],
      status: _parseTransactionStatus(json['status']),
      monetaryAmount: json['monetaryAmount']?.toDouble(),
      currency: json['currency'],
      paymentMethod: json['paymentMethod'],
      paymentId: json['paymentId'],
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      failedAt: json['failedAt'] != null
          ? DateTime.parse(json['failedAt'])
          : null,
      failureReason: json['failureReason'],
      invoiceUrl: json['invoiceUrl'],
      receiptUrl: json['receiptUrl'],
      analytics: json['analytics'],
      extraData: json['extraData'],
    );
  }

  static TransactionType _parseTransactionType(String? type) {
    if (type == null) return TransactionType.system;
    switch (type.toLowerCase()) {
      case 'purchase':
        return TransactionType.purchase;
      case 'giftsent':
      case 'gift_sent':
        return TransactionType.giftSent;
      case 'giftreceived':
      case 'gift_received':
        return TransactionType.giftReceived;
      case 'game':
        return TransactionType.game;
      case 'pk':
        return TransactionType.pk;
      case 'clan':
        return TransactionType.clan;
      case 'reward':
        return TransactionType.reward;
      case 'bonus':
        return TransactionType.bonus;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'refund':
        return TransactionType.refund;
      case 'commission':
        return TransactionType.commission;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.system;
    }
  }

  static TransactionStatus _parseTransactionStatus(String? status) {
    if (status == null) return TransactionStatus.completed;
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'processing':
        return TransactionStatus.processing;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'refunded':
        return TransactionStatus.refunded;
      default:
        return TransactionStatus.completed;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sellerId': sellerId,
      'type': type.toString().split('.').last,
      'amount': amount,
      'coinsBefore': coinsBefore,
      'coinsAfter': coinsAfter,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientAvatar': recipientAvatar,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'referenceId': referenceId,
      'referenceType': referenceType,
      'status': status.toString().split('.').last,
      'monetaryAmount': monetaryAmount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'processedAt': processedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'failedAt': failedAt?.toIso8601String(),
      'failureReason': failureReason,
      'invoiceUrl': invoiceUrl,
      'receiptUrl': receiptUrl,
      'analytics': analytics,
      'extraData': extraData,
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? sellerId,
    TransactionType? type,
    int? amount,
    int? coinsBefore,
    int? coinsAfter,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    String? recipientId,
    String? recipientName,
    String? recipientAvatar,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? referenceId,
    String? referenceType,
    TransactionStatus? status,
    double? monetaryAmount,
    String? currency,
    String? paymentMethod,
    String? paymentId,
    DateTime? processedAt,
    DateTime? completedAt,
    DateTime? failedAt,
    String? failureReason,
    String? invoiceUrl,
    String? receiptUrl,
    Map<String, dynamic>? analytics,
    Map<String, dynamic>? extraData,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sellerId: sellerId ?? this.sellerId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      coinsBefore: coinsBefore ?? this.coinsBefore,
      coinsAfter: coinsAfter ?? this.coinsAfter,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      recipientAvatar: recipientAvatar ?? this.recipientAvatar,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      status: status ?? this.status,
      monetaryAmount: monetaryAmount ?? this.monetaryAmount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      processedAt: processedAt ?? this.processedAt,
      completedAt: completedAt ?? this.completedAt,
      failedAt: failedAt ?? this.failedAt,
      failureReason: failureReason ?? this.failureReason,
      invoiceUrl: invoiceUrl ?? this.invoiceUrl,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      analytics: analytics ?? this.analytics,
      extraData: extraData ?? this.extraData,
    );
  }

  // Helper getters
  int get coinChange => coinsAfter - coinsBefore;
  bool get isCredit => coinChange > 0;
  bool get isDebit => coinChange < 0;
  bool get isZero => coinChange == 0;

  bool get isPending => status == TransactionStatus.pending;
  bool get isProcessing => status == TransactionStatus.processing;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isFailed => status == TransactionStatus.failed;
  bool get isCancelled => status == TransactionStatus.cancelled;
  bool get isRefunded => status == TransactionStatus.refunded;

  bool get hasSender => senderId != null && senderId!.isNotEmpty;
  bool get hasRecipient => recipientId != null && recipientId!.isNotEmpty;
  bool get hasReference => referenceId != null && referenceId!.isNotEmpty;
  bool get hasPayment => paymentId != null && paymentId!.isNotEmpty;
  bool get hasMonetaryValue => monetaryAmount != null && monetaryAmount! > 0;

  String get coinChangeDisplay {
    if (isCredit) return '+$coinChange';
    if (isDebit) return '$coinChange';
    return '0';
  }

  Color get coinChangeColor {
    if (isCredit) return Colors.green;
    if (isDebit) return Colors.red;
    return Colors.grey;
  }

  Color get statusColor {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.processing:
        return Colors.blue;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
      case TransactionStatus.refunded:
        return Colors.purple;
    }
  }

  String get typeDisplay {
    switch (type) {
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.giftSent:
        return 'Gift Sent';
      case TransactionType.giftReceived:
        return 'Gift Received';
      case TransactionType.game:
        return 'Game';
      case TransactionType.pk:
        return 'PK Battle';
      case TransactionType.clan:
        return 'Clan';
      case TransactionType.reward:
        return 'Reward';
      case TransactionType.bonus:
        return 'Bonus';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.refund:
        return 'Refund';
      case TransactionType.commission:
        return 'Commission';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.system:
        return 'System';
    }
  }

  // Get icon for transaction type
  IconData get icon {
    switch (type) {
      case TransactionType.purchase:
        return Icons.shopping_cart;
      case TransactionType.giftSent:
        return Icons.card_giftcard;
      case TransactionType.giftReceived:
        return Icons.card_giftcard;
      case TransactionType.game:
        return Icons.sports_esports;
      case TransactionType.pk:
        return Icons.emoji_events;
      case TransactionType.clan:
        return Icons.group;
      case TransactionType.reward:
        return Icons.star;
      case TransactionType.bonus:
        return Icons.card_giftcard;
      case TransactionType.withdrawal:
        return Icons.account_balance;
      case TransactionType.refund:
        return Icons.refresh;
      case TransactionType.commission:
        return Icons.trending_up;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.system:
        return Icons.info;
    }
  }

  // Format amount with currency
  String get formattedAmount {
    if (hasMonetaryValue) {
      return '${currency ?? '\$'}${monetaryAmount!.toStringAsFixed(2)}';
    }
    return '$amount coins';
  }

  // Time ago
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, user: $userId, type: $type, amount: $amount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel &&
        other.id == id &&
        other.userId == userId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(id, userId, timestamp);
}