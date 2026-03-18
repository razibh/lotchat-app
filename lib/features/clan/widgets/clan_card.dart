import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/models/clan_model.dart';
import 'clan_badge.dart';
import 'clan_progress_bar.dart';

class ClanCard extends StatelessWidget {
  final ClanModel clan;
  final VoidCallback onTap;

  const ClanCard({
    required this.clan,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Clan Emblem
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  shape: BoxShape.circle,
                  image: clan.emblem != null
                      ? DecorationImage(
                    image: NetworkImage(clan.emblem!),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: clan.emblem == null
                    ? const Icon(
                  Icons.groups,
                  size: 30,
                  color: Colors.deepPurple,
                )
                    : null,
              ),
              const SizedBox(width: 12),

              // Clan Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            clan.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ClanBadge(level: clan.level),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${clan.memberCount}/${clan.maxMembers} members',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // XP Progress Bar
                    Column(
                      children: [
                        ClanProgressBar(
                          progress: clan.xp / clan.xpToNextLevel,
                          height: 4,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // War Wins
                            Row(
                              children: [
                                const Icon(
                                  Icons.military_tech,
                                  size: 12,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${clan.warWins} Wins',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // XP Text
                            Text(
                              '${clan.xp}/${clan.xpToNextLevel} XP',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ClanModel>('clan', clan));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}