import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../core/models/frame_model.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/widgets/profile_frame.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/payment_service.dart';
import '../../../widgets/common/empty_state_widget.dart';
import '../../../mixins/loading_mixin.dart';
import '../../../mixins/toast_mixin.dart';


class FramesScreen extends StatefulWidget {
  final String userId;

  const FramesScreen({
    super.key,
    required this.userId,
  });

  @override
  State<FramesScreen> createState() => _FramesScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('userId', userId));
  }
}

class _FramesScreenState extends State<FramesScreen> with LoadingMixin, ToastMixin {
  final NotificationService _notificationService = ServiceLocator.instance.get<NotificationService>();
  final PaymentService _paymentService = ServiceLocator.instance.get<PaymentService>();

  String _selectedType = 'All';
  int _userCoins = 0;

  final List<String> _types = ['All', 'Basic', 'VIP', 'SVIP', 'Event', 'Animated'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserCoins();
    });
  }

  Future<void> _loadUserCoins() async {
    try {
      final coins = await _paymentService.getUserBalance(widget.userId);
      if (mounted) {
        setState(() {
          _userCoins = coins;
        });
      }
    } catch (e) {
      if (mounted) {
        showError('Failed to load coins');
      }
    }
  }

  List<FrameModel> _filterFrames(List<FrameModel> frames) {
    if (_selectedType == 'All') return frames;

    final String type = _selectedType.toLowerCase();
    return frames.where((frame) {
      return frame.type.toString().split('.').last == type;
    }).toList();
  }

  void _showFrameDetails(FrameModel frame, bool isOwned) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Frame Preview
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  image: frame.imageUrl.isNotEmpty
                      ? DecorationImage(
                    image: NetworkImage(frame.imageUrl),
                    fit: BoxFit.contain,
                  )
                      : null,
                  color: Colors.grey.shade200,
                ),
                child: frame.imageUrl.isEmpty
                    ? Icon(
                  _getFrameIcon(frame.type),
                  size: 50,
                  color: Colors.grey.shade400,
                )
                    : null,
              ),
              const SizedBox(height: 16),

              // Frame Name
              Text(
                frame.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Frame Description
              Text(
                frame.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Frame Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Type', frame.type.toString().split('.').last),
                    _buildDetailRow('Rarity', frame.rarity.toString().split('.').last),
                    _buildDetailRow('Price', '${frame.price} coins'),
                    if (frame.isAnimated)
                      _buildDetailRow('Animated', 'Yes'),
                    if (!frame.isAvailable)
                      _buildDetailRow('Status', 'Limited Time'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              if (isOwned)
                frame.isEquipped
                    ? const Text(
                  'Currently Equipped',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                )
                    : ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _equipFrame(frame.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Equip Frame'),
                )
              else if (frame.isAvailable)
                Column(
                  children: [
                    if (_userCoins < frame.price)
                      const Text(
                        'Insufficient coins',
                        style: TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _userCoins >= frame.price
                          ? () {
                        Navigator.pop(context);
                        _purchaseFrame(frame);
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Purchase'),
                    ),
                  ],
                )
              else
                const Text(
                  'No longer available',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getFrameIcon(FrameType type) {
    switch (type) {
      case FrameType.basic:
        return Icons.photo;
      case FrameType.vip:
        return Icons.star;
      case FrameType.svip:
        return Icons.diamond;
      case FrameType.event:
        return Icons.event;
      case FrameType.animated:
        return Icons.animation;
    }
  }

  Future<void> _equipFrame(String frameId) async {
    try {
      await context.read<ProfileProvider>().equipFrame(frameId);
      if (mounted) {
        showSuccess('Frame equipped');
      }
    } catch (e) {
      if (mounted) {
        showError('Failed to equip frame');
      }
    }
  }

  Future<void> _purchaseFrame(FrameModel frame) async {
    try {
      showLoading('Processing payment...');

      final success = await _paymentService.deductCoins(widget.userId, frame.price);

      if (success) {
        await context.read<ProfileProvider>().purchaseFrame(frame.id);

        if (mounted) {
          setState(() {
            _userCoins -= frame.price;
          });
          hideLoading();
          showSuccess('Frame purchased successfully');
        }
      } else {
        if (mounted) {
          hideLoading();
          showError('Failed to purchase frame');
        }
      }
    } catch (e) {
      if (mounted) {
        hideLoading();
        showError('Failed to purchase frame');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (BuildContext context, ProfileProvider provider, Widget? child) {
        if (provider.isLoadingFrames) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final frames = _filterFrames(provider.frames);
        final ownedFrameIds = provider.ownedFrames.map((f) => f.frameId).toSet();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile Frames'),
            backgroundColor: Colors.purple,
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$_userCoins',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _types.map((String type) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(type),
                        selected: _selectedType == type,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                        backgroundColor: Colors.white.withOpacity(0.2),
                        selectedColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedType == type ? Colors.purple : Colors.white,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          body: frames.isEmpty
              ? const EmptyStateWidget(
            title: 'No Frames',
            message: 'No frames available',
            icon: Icons.photo,
          )
              : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: frames.length,
            itemBuilder: (BuildContext context, int index) {
              final frame = frames[index];
              final isOwned = ownedFrameIds.contains(frame.id);
              final isEquipped = frame.isEquipped;

              return ProfileFrame(
                frame: frame,
                isOwned: isOwned,
                isEquipped: isEquipped,
                canAfford: _userCoins >= frame.price,
                onTap: () => _showFrameDetails(frame, isOwned),
                onEquip: isOwned && !isEquipped
                    ? () => _equipFrame(frame.id)
                    : null,
                onPurchase: !isOwned && frame.isAvailable
                    ? () => _purchaseFrame(frame)
                    : null,
              );
            },
          ),
        );
      },
    );
  }
}