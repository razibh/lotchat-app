import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/utils/country_helper.dart';
import '../../core/models/country_models.dart';

class RecommendedRoomsScreen extends StatefulWidget {

  const RecommendedRoomsScreen({required this.countryId, super.key});
  final String countryId;

  @override
  State<RecommendedRoomsScreen> createState() => _RecommendedRoomsScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('countryId', countryId));
  }
}

class _RecommendedRoomsScreenState extends State<RecommendedRoomsScreen> {
  List<RoomRecommendation> _recommendedRooms = <RoomRecommendation>[];
  List<RoomRecommendation> _nearbyRooms = <RoomRecommendation>[];
  List<RoomRecommendation> _trendingRooms = <RoomRecommendation>[];
  
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _selectedCountry = Country.getCountryById(widget.countryId);
    _generateRecommendations();
  }

  void _generateRecommendations() {
    // Sample data - in real app, this would come from API based on country
    _recommendedRooms = List.generate(5, (int index) {
      return RoomRecommendation(
        id: 'room_$index',
        title: '${_selectedCountry?.name} Room ${index + 1}',
        hostName: 'Host ${index + 1}',
        viewers: 150 + (index * 50),
        tags: <String>['local', 'trending', 'music'],
        countryId: widget.countryId,
        countryFlag: _selectedCountry?.flag ?? '🌍',
      );
    });

    _nearbyRooms = List.generate(3, (int index) {
      return RoomRecommendation(
        id: 'near_$index',
        title: 'Nearby Session ${index + 1}',
        hostName: 'Local Host ${index + 1}',
        viewers: 50 + (index * 25),
        tags: <String>['nearby', 'local'],
        countryId: widget.countryId,
        countryFlag: _selectedCountry?.flag ?? '🌍',
      );
    });

    _trendingRooms = List.generate(4, (int index) {
      return RoomRecommendation(
        id: 'trend_$index',
        title: 'Trending Room ${index + 1}',
        hostName: 'Star Host ${index + 1}',
        viewers: 1000 + (index * 500),
        tags: <String>['trending', 'popular', 'hot'],
        countryId: widget.countryId,
        countryFlag: _selectedCountry?.flag ?? '🌍',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <>[
                      _buildCountryInfo(),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Recommended for You'),
                      _buildHorizontalRoomList(_recommendedRooms),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Nearby Rooms'),
                      _buildHorizontalRoomList(_nearbyRooms),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Trending in ${_selectedCountry?.name}'),
                      _buildTrendingList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            'Recommended Rooms',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showCountrySelector,
          ),
        ],
      ),
    );
  }

  Widget _buildCountryInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <>[
            Colors.purple.withValues(alpha: 0.3),
            Colors.blue.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <>[
          Text(
            _selectedCountry?.flag ?? '🌍',
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  _selectedCountry?.name ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_selectedCountry?.currency} • ${_selectedCountry?.phoneCode}',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Local',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHorizontalRoomList(List<RoomRecommendation> rooms) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: rooms.length,
        itemBuilder: (BuildContext context, int index) {
          final RoomRecommendation room = rooms[index];
          return _buildRoomCard(room);
        },
      ),
    );
  }

  Widget _buildRoomCard(RoomRecommendation room) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          Row(
            children: <>[
              CircleAvatar(
                radius: 15,
                backgroundColor: Colors.purple,
                child: Text(
                  room.hostName[0],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  room.hostName,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            room.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: <>[
              const Icon(Icons.visibility, color: Colors.white70, size: 12),
              const SizedBox(width: 4),
              Text(
                '${room.viewers}',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              const Spacer(),
              Text(
                room.countryFlag,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: room.tags.take(2).map((String tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#$tag',
                  style: const TextStyle(color: Colors.purple, fontSize: 8),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _trendingRooms.length,
      itemBuilder: (BuildContext context, int index) {
        final RoomRecommendation room = _trendingRooms[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: <>[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.trending_up, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <>[
                    Text(
                      room.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      room.hostName,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <>[
                  Text(
                    '${room.viewers} viewers',
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                  Row(
                    children: <>[
                      const Icon(Icons.favorite, color: Colors.red, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${500 + index * 200}',
                        style: const TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <>[
            const Text(
              'Select Country',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...Country.getSupportedCountries().map((Country country) {
              return ListTile(
                leading: Text(country.flag, style: const TextStyle(fontSize: 24)),
                title: Text(country.name, style: const TextStyle(color: Colors.white)),
                trailing: country.id == widget.countryId
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecommendedRoomsScreen(countryId: country.id),
                    ),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class RoomRecommendation {

  RoomRecommendation({
    required this.id,
    required this.title,
    required this.hostName,
    required this.viewers, required this.tags, required this.countryId, required this.countryFlag, this.hostAvatar,
  });
  final String id;
  final String title;
  final String hostName;
  final String? hostAvatar;
  final int viewers;
  final List<String> tags;
  final String countryId;
  final String countryFlag;
}