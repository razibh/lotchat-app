import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../profile/profile_screen.dart';

class SuggestionTile extends StatelessWidget {

  const SuggestionTile({
    Key? key,
    required this.suggestion,
    this.onAdd,
    this.onDismiss,
  }) : super(key: key);
  final Map<String, dynamic> suggestion;
  final VoidCallback? onAdd;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: <>[
            // Avatar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: suggestion['userId']),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: suggestion['avatar'] != null
                    ? NetworkImage(suggestion['avatar'])
                    : null,
                child: suggestion['avatar'] == null
                    ? Text(suggestion['name'][0].toUpperCase())
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <>[
                  Text(
                    suggestion['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${suggestion['username']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: <>[
                      Icon(
                        Icons.people,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${suggestion['mutualFriends']} mutual friends',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (suggestion['commonInterests'] != null &&
                      suggestion['commonInterests'].isNotEmpty) ...<>[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: suggestion['commonInterests'].take(2).map<Widget>((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (suggestion['reason'] != null) ...<>[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        suggestion['reason'],
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <>[
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.green),
                  onPressed: onAdd,
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onDismiss,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CompactSuggestionTile extends StatelessWidget {

  const CompactSuggestionTile({
    Key? key,
    required this.suggestion,
    required this.onAdd,
  }) : super(key: key);
  final Map<String, dynamic> suggestion;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: suggestion['avatar'] != null
              ? NetworkImage(suggestion['avatar'])
              : null,
          child: suggestion['avatar'] == null
              ? Text(suggestion['name'][0].toUpperCase())
              : null,
        ),
        title: Text(suggestion['name']),
        subtitle: Text('${suggestion['mutualFriends']} mutual friends'),
        trailing: ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            minimumSize: const Size(80, 36),
          ),
          child: const Text('Add'),
        ),
      ),
    );
  }
}