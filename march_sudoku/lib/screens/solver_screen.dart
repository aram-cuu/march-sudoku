import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/sudoku_parser.dart';
import '../models/sudoku_board.dart';

class SolverScreen extends StatefulWidget {
  const SolverScreen({super.key});

  @override
  State<SolverScreen> createState() => _SolverScreenState();
}

class _SolverScreenState extends State<SolverScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSolution = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _solvePuzzle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final text = _textController.text.trim();
      if (text.isEmpty) {
        setState(() {
          _errorMessage = 'Please enter a puzzle';
          _isLoading = false;
        });
        return;
      }

      final board = SudokuParser.parseFromString(text);
      final provider = Provider.of<GameProvider>(context, listen: false);
      provider.loadPuzzle(board);
      provider.solvePuzzle();

      setState(() {
        _isLoading = false;
        _showSolution = true;
      });

      _showResultDialog();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _showResultDialog() {
    final provider = Provider.of<GameProvider>(context, listen: false);
    final difficulty = provider.difficulty;
    final hasUniqueSolution = provider.hasUniqueSolution;
    final isSolved = provider.isSolved;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Solution Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Solved: ${isSolved ? "Yes" : "No"}'),
              const SizedBox(height: 8),
              Text('Unique Solution: ${hasUniqueSolution ? "Yes" : "No"}'),
              const SizedBox(height: 8),
              Text('Difficulty: ${difficulty?.name ?? "Unknown"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solve Sudoku')),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          return _showSolution &&
                  provider.puzzle != null &&
                  provider.solution != null
              ? _buildSolutionView(provider)
              : _buildInputView();
        },
      ),
    );
  }

  Widget _buildInputView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Enter puzzle (9 lines, 9 characters each):',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    '51.....83\n8..416..5\n.........\n.985.461.\n...9.1...\n.642.357.\n.........\n6..157..4\n78.....96',
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _solvePuzzle,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Solve Puzzle'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Clipboard.getData(Clipboard.kTextPlain).then((data) {
                if (data?.text != null) {
                  _textController.text = data!.text!;
                }
              });
            },
            child: const Text('Paste from Clipboard'),
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionView(GameProvider provider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final gridHeight = (availableHeight - 200) / 2;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Original Puzzle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _SudokuGridDisplay(
                board: provider.puzzle!,
                maxHeight: gridHeight,
              ),
              const SizedBox(height: 24),
              const Text(
                'Solution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              _SudokuGridDisplay(
                board: provider.solution!,
                maxHeight: gridHeight,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showSolution = false;
                    _textController.clear();
                  });
                },
                child: const Text('Solve Another Puzzle'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SudokuGridDisplay extends StatelessWidget {
  final SudokuBoard board;
  final double? maxHeight;

  const _SudokuGridDisplay({required this.board, this.maxHeight});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = maxHeight ?? constraints.maxHeight;
        final cellSizeByWidth = (availableWidth - 32) / 9;
        final cellSizeByHeight = (availableHeight - 32) / 9;
        final cellSize = cellSizeByWidth < cellSizeByHeight
            ? cellSizeByWidth
            : cellSizeByHeight;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(9, (row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(9, (col) {
                  final value = board.get(row, col);
                  final isBoxBorder =
                      (row % 3 == 0 && row > 0) || (col % 3 == 0 && col > 0);

                  return Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          width: row == 0 ? 2 : (isBoxBorder ? 1 : 0.5),
                          color: Colors.black,
                        ),
                        bottom: BorderSide(
                          width: row == 8 ? 2 : (row % 3 == 2 ? 2 : 0.5),
                          color: Colors.black,
                        ),
                        left: BorderSide(
                          width: col == 0 ? 2 : (isBoxBorder ? 1 : 0.5),
                          color: Colors.black,
                        ),
                        right: BorderSide(
                          width: col == 8 ? 2 : (col % 3 == 2 ? 2 : 0.5),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        value == 0 ? '' : '$value',
                        style: TextStyle(
                          fontSize: cellSize * 0.4,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        );
      },
    );
  }
}
