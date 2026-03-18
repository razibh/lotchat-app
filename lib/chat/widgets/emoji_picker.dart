import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // 🟢 DiagnosticPropertiesBuilder এর জন্য

class EmojiPicker extends StatelessWidget {
  const EmojiPicker({
    super.key,
    required this.onEmojiSelected,
  });

  final Function(String) onEmojiSelected;

  final List<String> recentEmojis = const [
    '😊', '😂', '❤️', '👍', '😍', '😢', '😭', '😘', '🥰', '😁',
  ];

  final List<List<String>> emojiCategories = const [
    ['😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇'],
    ['😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜'],
    ['🤪', '🤨', '🧐', '🤓', '😎', '🥸', '🤩', '🥳', '😏', '😒'],
    ['😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖', '😫', '😩'],
    ['😤', '😠', '😡', '🤬', '🤯', '😳', '🥺', '😨', '😰', '😥'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
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
                children: [
                  const TabBar(
                    isScrollable: true,
                    tabs: [
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
                          ),
                          itemCount: category.length,
                          itemBuilder: (BuildContext context, int index) {
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ObjectFlagProperty<Function(String)>.has('onEmojiSelected', onEmojiSelected));
    // 🟢 IterableProperty সরিয়ে দেওয়া হয়েছে
    properties.add(DiagnosticsProperty<List<String>>('recentEmojis', recentEmojis));
    properties.add(DiagnosticsProperty<List<List<String>>>('emojiCategories', emojiCategories));
  }
}