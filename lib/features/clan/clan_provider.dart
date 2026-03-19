import 'package:flutter/material.dart';
import '../../../core/models/clan_model.dart';
import '../../features/clan/models/clan_member_model.dart';
import '../../features/clan/services/clan_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/logger_service.dart';

class ClanProvider extends ChangeNotifier {
  final ClanService _clanService = ServiceLocator.instance.get<ClanService>();
  final LoggerService _logger = ServiceLocator.instance.get<LoggerService>();

  List<ClanModel> _clans = [];
  ClanModel? _currentClan;
  List<ClanMember> _members = [];
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ClanModel> get clans => _clans;
  ClanModel? get currentClan => _currentClan;
  List<ClanMember> get members => _members;
  List<Map<String, dynamic>> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load clan by ID
  Future<void> loadClan(String clanId) async {
    _setLoading(true);
    try {
      _currentClan = await _clanService.getClan(clanId);
      _error = null;
    } catch (e, stackTrace) {
      _logger.error('Failed to load clan', error: e, stackTrace: stackTrace);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Stream clan
  Stream<ClanModel?> streamClan(String clanId) {
    return _clanService.streamClan(clanId);
  }

  // Search clans
  Future<void> searchClans(String query) async {
    _setLoading(true);
    try {
      _clans = await _clanService.searchClans(query);
      _error = null;
    } catch (e, stackTrace) {
      _logger.error('Failed to search clans', error: e, stackTrace: stackTrace);
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Load join requests
  void loadRequests(String clanId) {
    _clanService.getJoinRequests(clanId).listen((requests) {
      _requests = requests;
      notifyListeners();
    });
  }

  // Create clan
  Future<ClanModel?> createClan({
    required String name,
    String? description,
    String? rules,
    String? emblem,
    ClanJoinType joinType = ClanJoinType.open,
    List<String> tags = const [],
  }) async {
    _setLoading(true);
    try {
      final clan = await _clanService.createClan(
        name: name,
        description: description,
        rules: rules,
        emblem: emblem,
        joinType: joinType,
        tags: tags,
      );
      _error = null;
      return clan;
    } catch (e, stackTrace) {
      _logger.error('Failed to create clan', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Join clan
  Future<bool> joinClan(String clanId) async {
    _setLoading(true);
    try {
      final success = await _clanService.joinClan(clanId);
      if (success) {
        await loadClan(clanId);
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to join clan', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Leave clan
  Future<bool> leaveClan(String clanId) async {
    _setLoading(true);
    try {
      final success = await _clanService.leaveClan(clanId);
      if (success) {
        _currentClan = null;
        _members = [];
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to leave clan', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Kick member
  Future<bool> kickMember(String clanId, String memberId) async {
    _setLoading(true);
    try {
      final success = await _clanService.kickMember(clanId, memberId);
      if (success) {
        _members.removeWhere((m) => m.userId == memberId);
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to kick member', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Change member role
  Future<bool> changeMemberRole(String clanId, String memberId, ClanRole newRole) async {
    _setLoading(true);
    try {
      final success = await _clanService.changeMemberRole(clanId, memberId, newRole);
      if (success) {
        final index = _members.indexWhere((m) => m.userId == memberId);
        if (index != -1) {
          _members[index] = _members[index].copyWith(role: newRole);
        }
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to change member role', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Approve join request
  Future<bool> approveRequest(String requestId, String clanId) async {
    _setLoading(true);
    try {
      final success = await _clanService.approveRequest(requestId, clanId);
      if (success) {
        _requests.removeWhere((r) => r['id'] == requestId);
        await loadClan(clanId); // Refresh clan data
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to approve request', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reject join request
  Future<bool> rejectRequest(String requestId) async {
    _setLoading(true);
    try {
      final success = await _clanService.rejectRequest(requestId);
      if (success) {
        _requests.removeWhere((r) => r['id'] == requestId);
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to reject request', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Add activity points
  Future<void> addActivityPoints(String clanId, String userId, int points) async {
    try {
      await _clanService.addActivityPoints(clanId, userId, points);
    } catch (e, stackTrace) {
      _logger.error('Failed to add activity points', error: e, stackTrace: stackTrace);
    }
  }

  // Add donation
  Future<void> addDonation(String clanId, String userId, int amount) async {
    try {
      await _clanService.addDonation(clanId, userId, amount);
    } catch (e, stackTrace) {
      _logger.error('Failed to add donation', error: e, stackTrace: stackTrace);
    }
  }

  // Get top clans stream
  Stream<List<ClanModel>> getTopClans() {
    return _clanService.getTopClans();
  }

  // Get top members stream
  Stream<List<ClanMember>> getTopMembers(String clanId) {
    return _clanService.getTopMembers(clanId);
  }

  // Update clan settings
  Future<bool> updateClanSettings(String clanId, Map<String, dynamic> settings) async {
    _setLoading(true);
    try {
      final success = await _clanService.updateClanSettings(clanId, settings);
      if (success) {
        await loadClan(clanId); // Refresh clan data
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to update clan settings', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Transfer leadership
  Future<bool> transferLeadership(String clanId, String newLeaderId) async {
    _setLoading(true);
    try {
      final success = await _clanService.transferLeadership(clanId, newLeaderId);
      if (success) {
        await loadClan(clanId); // Refresh clan data
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to transfer leadership', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Disband clan
  Future<bool> disbandClan(String clanId) async {
    _setLoading(true);
    try {
      final success = await _clanService.disbandClan(clanId);
      if (success) {
        _currentClan = null;
        _members = [];
        _requests = [];
      }
      return success;
    } catch (e, stackTrace) {
      _logger.error('Failed to disband clan', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _clans = [];
    _currentClan = null;
    _members = [];
    _requests = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Helper method
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}