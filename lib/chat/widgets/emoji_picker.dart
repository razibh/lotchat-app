import 'package:flutter/material.dart';

class EmojiPicker extends StatelessWidget {

  const EmojiPicker({
    Key? key,
    required this.onEmojiSelected,
  }) : super(key: key);
  final Function(String) onEmojiSelected;

  final List<String> recentEmojis = const <String>[
    '😊', '😂', '❤️', '👍', '😍', '😢', '😭', '😘', '🥰', '😁',
  ];

  final List<List<String>> emojiCategories = const <List<String>>[
    <String>['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇'],
    <String>['😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜'],
    <String>['🤪', '🤨', '🧐', '🤓', '😎', '🥸', '🤩', '🥳', '😏', '😒'],
    <String>['😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖', '😫', '😩'],
    <String>['😤', '😠', '😡', '🤬', '🤯', '😳', '🥺', '😨', '😰', '😥'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: <>[
          // Recent Emojis
          const Text(
            'Recent',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildEmojiRow(recentEmojis),
          const Divider(),
          
          // Categories
          Expanded(
            child: DefaultTabController(
              length: 5,
              child: Column(
                children: <>[
                  const TabBar(
                    isScrollable: true,
                    tabs: <>[
                      Tab(text: '😊'),
                      Tab(text: '😍'),
                      Tab(text: '🤪'),
                      Tab(text: '😞'),
                      Tab(text: '😤'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: emojiCategories.map((List<String> category) {
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            childAspectRatio: 1,
                          ),
                          itemCount: category.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => onEmojiSelected(category[index]),
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                child: Center(
                                  child: Text(
                                    category[index],
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiRow(List<String> emojis) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: emojis.map((String emoji) {
        return GestureDetector(
          onTap: () => onEmojiSelected(emoji),
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      }).toList(),
    );
  }
}