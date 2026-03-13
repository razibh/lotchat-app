import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';
import '../../core/widgets/neumorphic_text_field.dart';
import '../games/chess_game.dart';
import '../games/carrom_game.dart';
import '../games/pictionary_game.dart';
import '../games/trivia_game.dart';
import '../games/truth_or_dare_game.dart';
import '../games/werewolf_game.dart';

class CreateRoomScreen extends StatefulWidget { // If provided, we're editing an existing room

  const CreateRoomScreen({
    Key? key,
    this.roomId,
  }) : super(key: key);
  final String? roomId;

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final _roomNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _maxPlayersController = TextEditingController(text: '8');
  
  String? _selectedGame;
  bool _isPrivate = false;
  bool _isTeamGame = false;
  int _teamSize = 4;
  String? _selectedDifficulty;
  int _gameDuration = 30; // in minutes
  
  final List<GameOption> _availableGames = <GameOption>[
    GameOption(name: 'Chess', icon: Icons.chess_board, category: 'Board', players: '2'),
    GameOption(name: 'Carrom', icon: Icons.sports_esports, category: 'Board', players: '2-4'),
    GameOption(name: 'Pictionary', icon: Icons.brush, category: 'Party', players: '4-8'),
    GameOption(name: 'Trivia', icon: Icons.quiz, category: 'Quiz', players: '2-8'),
    GameOption(name: 'Truth or Dare', icon: Icons.psychology, category: 'Party', players: '3-8'),
    GameOption(name: 'Werewolf', icon: Icons.nightlife, category: 'Social', players: '6-12'),
  ];
  
  final List<String> _difficulties = <String>['Easy', 'Medium', 'Hard', 'Expert'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // If editing existing room, load data
    if (widget.roomId != null) {
      _loadRoomData();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roomNameController.dispose();
    _passwordController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }

  void _loadRoomData() {
    // TODO: Load room data from backend
    // For now, set some dummy data
    setState(() {
      _roomNameController.text = 'Game Room ${widget.roomId}';
      _selectedGame = 'Chess';
      _isPrivate = true;
      _passwordController.text = '1234';
    });
  }

  void _createRoom() {
    if (_roomNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a room name')),
      );
      return;
    }

    if (_selectedGame == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a game')),
      );
      return;
    }

    if (_isPrivate && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password for private room')),
      );
      return;
    }

    // Navigate to the selected game
    Widget gameWidget;
    switch (_selectedGame) {
      case 'Chess':
        gameWidget = ChessGame(gameId: 'room_${DateTime.now().millisecondsSinceEpoch}');
      case 'Carrom':
        gameWidget = CarromGame(gameId: 'room_${DateTime.now().millisecondsSinceEpoch}');
      case 'Pictionary':
        gameWidget = PictionaryGame(gameId: 'room_${DateTime.now().millisecondsSinceEpoch}');
      case 'Trivia':
        gameWidget = TriviaGame(gameId: 'room_${DateTime.now().millisecondsSinceEpoch}');
      case 'Truth or Dare':
        gameWidget = TruthOrDareGame(gameId: 'room_${DateTime.now().millisecondsSinceEpoch}');
      case 'Werewolf':
        gameWidget = WerewolfGame(gameId: 'room_${DateTime.now().millisecondsSinceEpoch}');
      default:
        gameWidget = ChessGame(gameId: 'room_${DateTime.now().millisecondsSinceEpoch}');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => gameWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <>[
                    _buildBasicSettings(),
                    _buildAdvancedSettings(),
                  ],
                ),
              ),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            widget.roomId == null ? 'Create Room' : 'Edit Room',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: AppColors.accentPurple,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        tabs: const <>[
          Tab(text: 'Basic'),
          Tab(text: 'Advanced'),
        ],
      ),
    );
  }

  Widget _buildBasicSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          // Room Name
          const Text(
            'Room Name',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          NeumorphicTextField(
            controller: _roomNameController,
            hintText: 'Enter room name',
            prefixIcon: Icons.meeting_room,
          ),
          const SizedBox(height: 20),

          // Game Selection
          const Text(
            'Select Game',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildGameGrid(),
          const SizedBox(height: 20),

          // Max Players
          const Text(
            'Maximum Players',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          NeumorphicTextField(
            controller: _maxPlayersController,
            hintText: 'Enter max players',
            prefixIcon: Icons.people,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),

          // Private Room Toggle
          _buildSwitchTile(
            title: 'Private Room',
            subtitle: 'Require password to join',
            value: _isPrivate,
            icon: Icons.lock,
            onChanged: (value) {
              setState(() {
                _isPrivate = value;
              });
            },
          ),
          
          if (_isPrivate) ...<>[
            const SizedBox(height: 16),
            NeumorphicTextField(
              controller: _passwordController,
              hintText: 'Enter room password',
              prefixIcon: Icons.password,
              obscureText: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _availableGames.length,
      itemBuilder: (context, index) {
        final GameOption game = _availableGames[index];
        final bool isSelected = _selectedGame == game.name;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedGame = game.name;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.accentPurple.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? AppColors.accentPurple 
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <>[
                Icon(
                  game.icon,
                  size: 32,
                  color: isSelected ? AppColors.accentPurple : Colors.white70,
                ),
                const SizedBox(height: 8),
                Text(
                  game.name,
                  style: TextStyle(
                    color: isSelected ? AppColors.accentPurple : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '👥 ${game.players}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    game.category,
                    style: const TextStyle(color: Colors.white70, fontSize: 8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAdvancedSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <>[
          // Team Game Toggle
          _buildSwitchTile(
            title: 'Team Game',
            subtitle: 'Split players into teams',
            value: _isTeamGame,
            icon: Icons.groups,
            onChanged: (value) {
              setState(() {
                _isTeamGame = value;
              });
            },
          ),
          
          if (_isTeamGame) ...<>[
            const SizedBox(height: 16),
            const Text(
              'Team Size',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildTeamSizeSelector(),
            const SizedBox(height: 20),
          ],

          // Difficulty
          const Text(
            'Difficulty',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildDifficultySelector(),
          const SizedBox(height: 20),

          // Game Duration
          const Text(
            'Game Duration (minutes)',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildDurationSlider(),

          // Additional Options
          const SizedBox(height: 30),
          const Text(
            'Additional Options',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          _buildCheckboxTile(
            title: 'Enable Voice Chat',
            value: true,
            onChanged: (value) {},
          ),
          _buildCheckboxTile(
            title: 'Enable Spectators',
            value: false,
            onChanged: (value) {},
          ),
          _buildCheckboxTile(
            title: 'Allow Late Join',
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.accentPurple, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <>[
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <>[
          Checkbox(
            value: value,
            onChanged: onChanged,
            checkColor: Colors.white,
            activeColor: AppColors.accentPurple,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSizeSelector() {
    return Row(
      children: <>[
        _buildSizeButton(Icons.remove, () {
          if (_teamSize > 2) {
            setState(() {
              _teamSize--;
            });
          }
        }),
        const SizedBox(width: 16),
        Text(
          '$_teamSize',
          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 16),
        _buildSizeButton(Icons.add, () {
          if (_teamSize < 6) {
            setState(() {
              _teamSize++;
            });
          }
        }),
        const SizedBox(width: 16),
        const Text(
          'players per team',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildSizeButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: _difficulties.map((String difficulty) {
        final bool isSelected = _selectedDifficulty == difficulty;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDifficulty = difficulty;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.accentPurple.withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.accentPurple : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: isSelected ? AppColors.accentPurple : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDurationSlider() {
    return Column(
      children: <>[
        Slider(
          value: _gameDuration.toDouble(),
          min: 5,
          max: 120,
          divisions: 23,
          onChanged: (value) {
            setState(() {
              _gameDuration = value.round();
            });
          },
          activeColor: AppColors.accentPurple,
          inactiveColor: Colors.white.withOpacity(0.1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <>[
            Text(
              '$_gameDuration minutes',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            Text(
              '${(_gameDuration / 60).toStringAsFixed(1)} hours',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: NeumorphicButton(
        onPressed: _createRoom,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              widget.roomId == null ? 'CREATE ROOM' : 'UPDATE ROOM',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameOption {

  GameOption({
    required this.name,
    required this.icon,
    required this.category,
    required this.players,
  });
  final String name;
  final IconData icon;
  final String category;
  final String players;
}