import 'package:flutter/material.dart';
import '../../../core/utils/date_formatter.dart';
import '../../profile/profile_screen.dart';

class RequestTile extends StatelessWidget {

  const RequestTile({
    Key? key,
    required this.request,
    this.onAccept,
    this.onReject,
    this.onCancel,
    this.isIncoming = true,
  }) : super(key: key);
  final Map<String, dynamic> request;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;
  final bool isIncoming;

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
                    builder: (context) => ProfileScreen(userId: request['userId']),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 30,
                backgroundImage: request['avatar'] != null
                    ? NetworkImage(request['avatar'])
                    : null,
                child: request['avatar'] == null
                    ? Text(request['name'][0].toUpperCase())
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
                    request['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${request['username']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (request['mutualFriends'] != null) ...<>[
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
                          '${request['mutualFriends']} mutual friends',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (request['commonInterests'] != null &&
                      request['commonInterests'].isNotEmpty) ...<>[
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 20,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: request['commonInterests'].length > 2
                            ? 2
                            : request['commonInterests'].length,
                        itemBuilder: (context, index) {
                          final interest = request['commonInterests'][index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            margin: const EdgeInsets.only(right: 4),
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
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Received ${DateFormatter.timeAgo(request['timestamp'])}',
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            if (isIncoming) ...<>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <>[
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: onAccept,
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: onReject,
                  ),
                ],
              ),
            ] else ...<>[
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: onCancel,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SentRequestTile extends StatelessWidget {

  const SentRequestTile({
    Key? key,
    required this.request,
    required this.onCancel,
  }) : super(key: key);
  final Map<String, dynamic> request;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: request['avatar'] != null
              ? NetworkImage(request['avatar'])
              : null,
          child: request['avatar'] == null
              ? Text(request['name'][0].toUpperCase())
              : null,
        ),
        title: Text(request['name']),
        subtitle: Text('Request sent ${DateFormatter.timeAgo(request['timestamp'])}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: onCancel,
            ),
          ],
        ),
      ),
    );
  }
}