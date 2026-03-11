import 'package:flutter/material.dart';
import '../../core/models/user_model.dart';

class ParticipantGrid extends StatelessWidget {
  final List<Participant> participants;
  final String? localUserId;
  final Function(String userId)? onParticipantTap;
  final Function(String userId)? onMuteParticipant;
  final Function(String userId)? onPinParticipant;

  const ParticipantGrid({
    Key? key,
    required this.participants,
    this.localUserId,
    this.onParticipantTap,
    this.onMuteParticipant,
    this.onPinParticipant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const Center(
        child: Text('No participants'),
      );
    }

    // Determine grid layout based on participant count
    int crossAxisCount = _getCrossAxisCount(participants.length);
    double childAspectRatio = _getAspectRatio(participants.length);

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        final isLocal = participant.userId == localUserId;
        
        return ParticipantTile(
          participant: participant,
          isLocal: isLocal,
          onTap: () => onParticipantTap?.call(participant.userId),
          onMute: () => onMuteParticipant?.call(participant.userId),
          onPin: () => onPinParticipant?.call(participant.userId),
        );
      },
    );
  }

  int _getCrossAxisCount(int count) {
    if (count <= 2) return 1;
    if (count <= 4) return 2;
    if (count <= 9) return 3;
    return 4;
  }

  double _getAspectRatio(int count) {
    if (count <= 2) return 16 / 9;
    if (count <= 4) return 1;
    return 0.8;
  }
}

class ParticipantTile extends StatelessWidget {
  final Participant participant;
  final bool isLocal;
  final VoidCallback? onTap;
  final VoidCallback? onMute;
  final VoidCallback? onPin;

  const ParticipantTile({
    Key? key,
    required this.participant,
    required this.isLocal,
    this.onTap,
    this.onMute,
    this.onPin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video or Avatar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: participant.isSpeaking
                  ? Border.all(color: Colors.green, width: 3)
                  : null,
            ),
            child: participant.hasVideo
                ? Container() // Video view would go here
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: participant.avatar != null
                              ? NetworkImage(participant.avatar!)
                              : null,
                          child: participant.avatar == null
                              ? Text(
                                  participant.name[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 30),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          participant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        if (isLocal)
                          const Text(
                            '(You)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
          ),

          // Status overlays
          Positioned(
            top: 8,
            left: 8,
            child: Row(
              children: [
                // Mute indicator
                if (participant.isMuted)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_off,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                
                // Pin indicator
                if (participant.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.push_pin,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Name label
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      participant.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (participant.audioLevel > 0)
                    Container(
                      width: 20,
                      height: 20,
                      child: CustomPaint(
                        painter: AudioLevelPainter(
                          level: participant.audioLevel,
                          color: Colors.green,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Local user indicator
          if (isLocal)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ),

          // Action buttons (on long press)
          if (onMute != null || onPin != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onLongPress: () {
                    _showActions(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                participant.isMuted ? Icons.mic : Icons.mic_off,
                color: participant.isMuted ? Colors.green : Colors.red,
              ),
              title: Text(participant.isMuted ? 'Unmute' : 'Mute'),
              onTap: () {
                Navigator.pop(context);
                onMute?.call();
              },
            ),
            ListTile(
              leading: Icon(
                participant.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: participant.isPinned ? Colors.blue : null,
              ),
              title: Text(participant.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(context);
                onPin?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class Participant {
  final String userId;
  final String name;
  final String? avatar;
  final bool hasVideo;
  final bool isMuted;
  final bool isSpeaking;
  final bool isPinned;
  final double audioLevel;

  Participant({
    required this.userId,
    required this.name,
    this.avatar,
    this.hasVideo = false,
    this.isMuted = false,
    this.isSpeaking = false,
    this.isPinned = false,
    this.audioLevel = 0.0,
  });
}

class AudioLevelPainter extends CustomPainter {
  final double level;
  final Color color;

  AudioLevelPainter({required this.level, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final barWidth = size.width / 3;
    final barSpacing = 2;

    for (int i = 0; i < 3; i++) {
      final barHeight = size.height * (0.3 + (level * 0.7) * (i + 1) / 3);
      final left = i * (barWidth + barSpacing);
      final top = size.height - barHeight;
      
      canvas.drawRect(
        Rect.fromLTWH(left, top, barWidth - barSpacing, barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioLevelPainter oldDelegate) {
    return oldDelegate.level != level;
  }
}