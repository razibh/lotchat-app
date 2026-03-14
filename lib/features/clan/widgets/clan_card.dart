import 'package:flutter/material.dart';
import '../../models/clan_model.dart';
import 'clan_badge.dart';
import 'clan_progress_bar.dart';

class ClanCard extends StatelessWidget {

  const ClanCard({
    required this.clan, required this.onTap, super.key,
  });
  final ClanModel clan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <>[
              // Clan Emblem
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
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
                  children: <>[
                    Row(
                      children: <>[
                        Expanded(
                          child: Text(
                            clan.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ClanBadge(level: clan.level),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${clan.memberCount}/${clan.maxMembers} members • ${clan.totalActivity} activity',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClanProgressBar(
                      progress: clan.xpProgress,
                      height: 4,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <>[
                        const Icon(
                          Icons.military_tech,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${clan.warWins} Wins',
                          style: const TextStyle(fontSize: 10),
                        ),
                        const Spacer(),
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