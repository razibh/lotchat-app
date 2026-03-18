import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/date_utils.dart';
import '../../profile/profile_screen.dart';

class SuggestionTile extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final VoidCallback? onAdd;
  final VoidCallback? onDismiss;

  const SuggestionTile({
    required this.suggestion,
    this.onAdd,
    this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: suggestion['userId'] ?? ''),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: suggestion['avatar'] != null
                    ? NetworkImage(suggestion['avatar'])
                    : null,
                backgroundColor: Colors.grey.shade200,
                child: suggestion['avatar'] == null
                    ? Text(
                  suggestion['name'] != null && suggestion['name'].toString().isNotEmpty
                      ? suggestion['name'][0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : null,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${suggestion['username'] ?? 'unknown'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${suggestion['mutualFriends'] ?? 0} mutual friends',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (suggestion['commonInterests'] != null &&
                      (suggestion['commonInterests'] as List).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: (suggestion['commonInterests'] as List)
                          .take(2)
                          .map<Widget>((interest) {
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
                            interest.toString(),
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.blue,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (suggestion['reason'] != null) ...[
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
                        suggestion['reason'].toString(),
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
              children: [
                IconButton(
                  icon: const Icon(Icons.person_add, color: Colors.green),
                  onPressed: onAdd,
                  tooltip: 'Add Friend',
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onDismiss,
                    tooltip: 'Dismiss',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, dynamic>>('suggestion', suggestion));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onAdd', onAdd));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDismiss', onDismiss));
  }
}

class CompactSuggestionTile extends StatelessWidget {
  final Map<String, dynamic> suggestion;
  final VoidCallback onAdd;

  const CompactSuggestionTile({
    required this.suggestion,
    required this.onAdd,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: suggestion['avatar'] != null
              ? NetworkImage(suggestion['avatar'])
              : null,
          backgroundColor: Colors.grey.shade200,
          child: suggestion['avatar'] == null
              ? Text(
            suggestion['name'] != null && suggestion['name'].toString().isNotEmpty
                ? suggestion['name'][0].toUpperCase()
                : '?',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          )
              : null,
        ),
        title: Text(
          suggestion['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${suggestion['mutualFriends'] ?? 0} mutual friends'),
        trailing: ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            minimumSize: const Size(80, 36),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Add'),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Map<String, dynamic>>('suggestion', suggestion));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onAdd', onAdd));
  }
}