import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/services/search_service.dart';
import '../../mixins/loading_mixin.dart';
import '../../mixins/toast_mixin.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with LoadingMixin, ToastMixin {
  
  final _searchService = ServiceLocator().get<SearchService>();
  final _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _results = [];
  String _selectedFilter = 'All';
  bool _isSearching = false;

  final List<String> _filters = ['All', 'Users', 'Rooms', 'Posts', 'Gifts'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    await runWithLoading(() async {
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock search results
      setState(() {
        _results = List.generate(20, (index) {
          final type = _getRandomType(index);
          return {
            'id': 'result_$index',
            'type': type,
            'title': _getTitle(type, index),
            'subtitle': _getSubtitle(type, index),
            'image': null,
            'value': _getValue(type, index),
            'icon': _getIcon(type),
            'color': _getColor(type),
          };
        });
        _isSearching = false;
      });
    });
  }

  String _getRandomType(int index) {
    if (_selectedFilter != 'All') return _selectedFilter;
    final types = ['Users', 'Rooms', 'Posts', 'Gifts'];
    return types[index % types.length];
  }

  String _getTitle(String type, int index) {
    switch (type) {
      case 'Users':
        return 'User ${index + 1}';
      case 'Rooms':
        return 'Room ${index + 1}';
      case 'Posts':
        return 'Post Title ${index + 1}';
      case 'Gifts':
        return 'Gift ${index + 1}';
      default:
        return 'Result ${index + 1}';
    }
  }

  String _getSubtitle(String type, int index) {
    switch (type) {
      case 'Users':
        return '@user${index + 1} • ${100 + index} followers';
      case 'Rooms':
        return '${50 + index} viewers • ${index + 1} hosts';
      case 'Posts':
        return '${200 + index} likes • ${20 + index} comments';
      case 'Gifts':
        return '${100 * (index + 1)} coins • ${index + 1} sent';
      default:
        return 'Search result ${index + 1}';
    }
  }

  String _getValue(String type, int index) {
    switch (type) {
      case 'Users':
        return '${index + 1} mutual friends';
      case 'Rooms':
        return '${index % 2 == 0 ? 'Live' : 'Recording'}';
      case 'Posts':
        return '${index}h ago';
      case 'Gifts':
        return 'Trending #${index + 1}';
      default:
        return '';
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Users':
        return Icons.person;
      case 'Rooms':
        return Icons.meeting_room;
      case 'Posts':
        return Icons.post_add;
      case 'Gifts':
        return Icons.card_giftcard;
      default:
        return Icons.search;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'Users':
        return Colors.blue;
      case 'Rooms':
        return Colors.green;
      case 'Posts':
        return Colors.orange;
      case 'Gifts':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _clearSearch() {
    setState(() {
      _results.clear();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: Colors.teal,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users, rooms, posts...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 8),

                // Filters
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _filters.map((filter) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                              if (_results.isNotEmpty) {
                                _performSearch();
                              }
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.2),
                          selectedColor: Colors.white,
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter ? Colors.teal : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? _searchController.text.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Search for something',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Find users, rooms, posts and gifts',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : const EmptyStateWidget(
                      title: 'No Results Found',
                      message: 'Try searching with different keywords',
                      icon: Icons.search_off,
                    )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: result['color'].withOpacity(0.1),
                          child: Icon(
                            result['icon'],
                            color: result['color'],
                          ),
                        ),
                        title: Text(result['title']),
                        subtitle: Text(result['subtitle']),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              result['value'],
                              style: TextStyle(
                                color: result['color'],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _handleResultTap(result);
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _handleResultTap(Map<String, dynamic> result) {
    switch (result['type']) {
      case 'Users':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(userId: result['id']),
          ),
        );
        break;
      case 'Rooms':
        // Navigate to room
        break;
      case 'Posts':
        // Show post
        break;
      case 'Gifts':
        // Show gift details
        break;
    }
  }
}