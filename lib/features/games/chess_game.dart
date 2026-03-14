import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/neumorphic_button.dart';

class ChessGame extends StatefulWidget {

  const ChessGame({
    required this.gameId, super.key,
    this.gameData,
  });
  final String gameId;
  final Map<String, dynamic>? gameData;

  @override
  State<ChessGame> createState() => _ChessGameState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('gameId', gameId));
    properties.add(DiagnosticsProperty<Map<String, dynamic>?>('gameData', gameData));
  }
}

class _ChessGameState extends State<ChessGame> {
  late List<List<ChessPiece?>> board;
  bool isWhiteTurn = true;
  int? selectedRow;
  int? selectedCol;
  String gameStatus = 'Your turn';

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(8, (int row) => List.generate(8, (int col) {
      if (row == 1) return ChessPiece(type: ChessPieceType.pawn, isWhite: false);
      if (row == 6) return ChessPiece(type: ChessPieceType.pawn, isWhite: true);
      
      if (row == 0) {
        if (col == 0 || col == 7) return ChessPiece(type: ChessPieceType.rook, isWhite: false);
        if (col == 1 || col == 6) return ChessPiece(type: ChessPieceType.knight, isWhite: false);
        if (col == 2 || col == 5) return ChessPiece(type: ChessPieceType.bishop, isWhite: false);
        if (col == 3) return ChessPiece(type: ChessPieceType.queen, isWhite: false);
        if (col == 4) return ChessPiece(type: ChessPieceType.king, isWhite: false);
      }
      
      if (row == 7) {
        if (col == 0 || col == 7) return ChessPiece(type: ChessPieceType.rook, isWhite: true);
        if (col == 1 || col == 6) return ChessPiece(type: ChessPieceType.knight, isWhite: true);
        if (col == 2 || col == 5) return ChessPiece(type: ChessPieceType.bishop, isWhite: true);
        if (col == 3) return ChessPiece(type: ChessPieceType.queen, isWhite: true);
        if (col == 4) return ChessPiece(type: ChessPieceType.king, isWhite: true);
      }
      
      return null;
    }),);
  }

  void _onSquareTapped(int row, int col) {
    if (selectedRow == null && selectedCol == null) {
      // Select piece
      if (board[row][col] != null && board[row][col]!.isWhite == isWhiteTurn) {
        setState(() {
          selectedRow = row;
          selectedCol = col;
        });
      }
    } else {
      // Move piece
      if (selectedRow != null && selectedCol != null) {
        setState(() {
          board[row][col] = board[selectedRow!][selectedCol!];
          board[selectedRow!][selectedCol!] = null;
          selectedRow = null;
          selectedCol = null;
          isWhiteTurn = !isWhiteTurn;
          gameStatus = isWhiteTurn ? 'Your turn' : "Opponent's turn";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: <>[
              _buildHeader(),
              _buildGameStatus(),
              Expanded(
                child: Center(
                  child: _buildChessBoard(),
                ),
              ),
              _buildGameControls(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <>[
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Chess',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        gameStatus,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildChessBoard() {
    return Container(
      width: 350,
      height: 350,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.brown.shade800, width: 4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (BuildContext context, int index) {
          final row = index ~/ 8;
          final col = index % 8;
          final var isSelected = selectedRow == row && selectedCol == col;
          
          return GestureDetector(
            onTap: () => _onSquareTapped(row, col),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _getSquareColor(row, col, isSelected),
                border: Border.all(
                  color: Colors.brown.shade400,
                  width: 0.5,
                ),
              ),
              child: Center(
                child: _buildChessPiece(row, col),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getSquareColor(int row, int col, bool isSelected) {
    if (isSelected) {
      return Colors.yellow.withValues(alpha: 0.5);
    }
    return (row + col) % 2 == 0 
        ? Colors.brown.shade300 
        : Colors.brown.shade600;
  }

  Widget? _buildChessPiece(int row, int col) {
    final ChessPiece? piece = board[row][col];
    if (piece == null) return null;
    
    IconData iconData;
    switch (piece.type) {
      case ChessPieceType.pawn:
        iconData = Icons.agriculture;
      case ChessPieceType.rook:
        iconData = Icons.account_balance;
      case ChessPieceType.knight:
        iconData = Icons.pets;
      case ChessPieceType.bishop:
        iconData = Icons.church;
      case ChessPieceType.queen:
        iconData = Icons.star;
      case ChessPieceType.king:
        iconData = Icons.star_border;
    }
    
    return Icon(
      iconData,
      color: piece.isWhite ? Colors.white : Colors.black,
      size: 30,
    );
  }

  Widget _buildGameControls() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <>[
          NeumorphicButton(
            onPressed: () {
              setState(() {
                _initializeBoard();
                isWhiteTurn = true;
                gameStatus = 'Your turn';
              });
            },
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
          NeumorphicButton(
            onPressed: () {},
            child: const Icon(Icons.emoji_events, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<List<ChessPiece?>>('board', board));
    properties.add(DiagnosticsProperty<bool>('isWhiteTurn', isWhiteTurn));
    properties.add(IntProperty('selectedRow', selectedRow));
    properties.add(IntProperty('selectedCol', selectedCol));
    properties.add(StringProperty('gameStatus', gameStatus));
  }
}

enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {

  ChessPiece({required this.type, required this.isWhite});
  final ChessPieceType type;
  final bool isWhite;
}