import 'package:flutter/material.dart';
import '../models/gift_model.dart';
import '../services/gift_service.dart';
import '../services/payment_service.dart';

class GiftProvider extends ChangeNotifier {
  final GiftService _giftService = GiftService();
  final PaymentService _paymentService = PaymentService();
  
  List<GiftModel> _gifts = [];
  List<GiftModel> _recentGifts = [];
  bool _isLoading = false;
  String? _error;

  List<GiftModel> get gifts => _gifts;
  List<GiftModel> get recentGifts => _recentGifts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadGifts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _gifts = await _giftService.getAvailableGifts();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentGifts(String userId) async {
    try {
      _recentGifts = await _giftService.getRecentGifts(userId);
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  List<GiftModel> getGiftsByCategory(String category) {
    return _gifts.where((g) => g.category == category).toList();
  }

  List<GiftModel> getVipGifts() {
    return _gifts.where((g) => g.isVip).toList();
  }

  List<GiftModel> getSvipGifts() {
    return _gifts.where((g) => g.isSvip).toList();
  }

  Future<bool> sendGift({
    required String senderId,
    required String receiverId,
    required String giftId,
    required int amount,
    String? roomId,
  }) async {
    try {
      await _paymentService.deductCoins(senderId, amount);
      await _giftService.sendGift(
        senderId: senderId,
        receiverId: receiverId,
        giftId: giftId,
        amount: amount,
        roomId: roomId,
      );
      await loadRecentGifts(senderId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }
}