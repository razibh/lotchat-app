import 'package:flutter/material.dart';
import '../core/models/room_model.dart';
import 'animation/pulse_animation.dart';
import 'badge_widget.dart';

class RoomCard extends StatelessWidget {

  const RoomCard({
    Key? key,
    required this.room,
    required this.onTap,
  }) : super(key: key);
  final RoomModel room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: room.coverImage != null
              ? DecorationImage(
                  image: NetworkImage(room.coverImage!),
                  fit: BoxFit.cover,
                )
              : null,
          gradient: room.coverImage == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <>[
                    Colors.primaries[room.name.hashCode % Colors.primaries.length],
                    Colors.primaries[(room.name.hashCode + 1) % Colors.primaries.length],
                  ],
                )
              : null,
        ),
        child: Stack(
          children: <>[
            // Dark Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <>[
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    // Room Name
                    Row(
                      children: <>[
                        Expanded(
                          child: Text(
                            room.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (room.isPKActive)
                          PulseAnimation(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: <>[Colors.red, Colors.orange],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: <>[
                                  Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'PK',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Host Info
                    Row(
                      children: <>[
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(room.hostAvatar!),
                          child: null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            room.hostName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Room Stats
                    Row(
                      children: <>[
                        const Icon(
                          Icons.people,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${room.viewerCount} watching',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.mic,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${room.activeSpeakers} speaking',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Category & Tags
                    Row(
                      children: <>[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            room.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (room.isPrivate)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: <>[
                                Icon(
                                  Icons.lock,
                                  color: Colors.white,
                                  size: 10,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  'Private',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Live Indicator
            Positioned(
              top: 12,
              right: 12,
              child: PulseAnimation(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: <>[
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.white,
                        size: 10,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomCardSkeleton extends StatelessWidget {
  const RoomCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: <>[
          // Shimmer Effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <>[
                    Colors.grey.shade300,
                    Colors.grey.shade100,
                    Colors.grey.shade300,
                  ],
                  stops: const <num>[0, 0.5, 1],
                  begin: Alignment(-1, -0.5),
                  end: Alignment(1, 0.5),
                ),
              ),
            ),
          ),

          // Content Placeholder
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Container(
                  width: 150,
                  height: 20,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}