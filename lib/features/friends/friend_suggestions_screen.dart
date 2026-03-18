import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FriendSuggestionsScreen extends StatefulWidget {
  const FriendSuggestionsScreen({super.key});

  @override
  State<FriendSuggestionsScreen> createState() => _FriendSuggestionsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // Add any properties if needed
  }
}

class _FriendSuggestionsScreenState extends State<FriendSuggestionsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Sample data
    _suggestions = List.generate(10, (index) {
      return {
        'id': 'user_${index + 100}',
        'name': 'User ${index + 1}',
        'username': '@user${index + 1}',
        'avatar': null,
        'mutualFriends': index * 2,
        'isFollowing': false,
      };
    });

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend Suggestions'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade100,
                child: Text(
                  suggestion['name'][0],
                  style: const TextStyle(color: Colors.deepPurple),
                ),
              ),
              title: Text(suggestion['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(suggestion['username']),
                  Text(
                    '${suggestion['mutualFriends']} mutual friends',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              trailing: suggestion['isFollowing']
                  ? OutlinedButton(
                onPressed: () {},
                child: const Text('Following'),
              )
                  : ElevatedButton(
                onPressed: () {
                  setState(() {
                    suggestion['isFollowing'] = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Following ${suggestion['name']}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                child: const Text('Follow'),
              ),
            ),
          );
        },
      ),
    );
  }
}