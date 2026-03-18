import 'package:flutter/material.dart';

// Participant class (final নেই)
class Participant {
  String userId;
  String name;
  String? avatar;
  bool hasVideo;
  bool isMuted;
  bool isSpeaking;
  bool isPinned;
  double audioLevel;

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

class ParticipantGrid extends StatelessWidget {
  final List<Participant> participants;
  final String localUserId;
  final Function(String) onParticipantTap;
  final Function(String) onMuteParticipant;
  final Function(String) onPinParticipant;

  const ParticipantGrid({
    Key? key,
    required this.participants,
    required this.localUserId,
    required this.onParticipantTap,
    required this.onMuteParticipant,
    required this.onPinParticipant,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return GestureDetector(
          onTap: () => onParticipantTap(participant.userId),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: participant.isPinned
                  ? Border.all(color: Colors.green, width: 2)
                  : null,
            ),
            child: Stack(
              children: [
                // Video or Avatar
                Center(
                  child: participant.hasVideo
                      ? Container(
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        'Video Stream',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 40,
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
                        participant.userId == localUserId
                            ? 'You'
                            : participant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Mute indicator
                if (participant.isMuted)
                  const Positioned(
                    top: 8,
                    left: 8,
                    child: Icon(
                      Icons.mic_off,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),

                // Speaking indicator
                if (participant.isSpeaking)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Pin indicator
                if (participant.isPinned)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.push_pin,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),

                // Audio level indicator
                if (participant.audioLevel > 0)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: participant.audioLevel,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}