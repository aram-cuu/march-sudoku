import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/sudoku_board.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final provider = Provider.of<GameProvider>(context, listen: false);
      provider.updateTimer(provider.elapsedSeconds + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Play Sudoku'),
        actions: [
          Consumer<GameProvider>(
            builder: (context, provider, _) {
              final minutes = provider.elapsedSeconds ~/ 60;
              final seconds = provider.elapsedSeconds % 60;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'),
              );
            },
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, provider, _) {
          if (provider.currentBoard == null) {
            return const Center(child: Text('No puzzle loaded'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final availableHeight = constraints.maxHeight;
              final buttonAreaHeight = 140.0;
              final gridAreaHeight = availableHeight - buttonAreaHeight;
              
              return Column(
                children: [
                  Expanded(
                    child: Center(
                      child: _SudokuGrid(
                        board: provider.currentBoard!,
                        puzzle: provider.puzzle!,
                        selectedCell: provider.selectedCell,
                        maxHeight: gridAreaHeight,
                        onCellTap: (row, col) {
                          provider.selectCell(row, col);
                        },
                        onCellValueChange: (row, col, value) {
                          provider.setCell(row, col, value);
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            provider.showHint();
                          },
                          child: const Text('Hint'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            provider.solvePuzzle();
                            if (provider.isSolved) {
                              _showSolvedDialog(context);
                            }
                          },
                          child: const Text('Solve'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            provider.reset();
                          },
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(9, (index) {
                        final digit = index + 1;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              final selected = provider.selectedCell;
                              if (selected != null) {
                                provider.setCell(selected.$1, selected.$2, digit);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text('$digit'),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showSolvedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Puzzle Solved!'),
          content: const Text('Congratulations! You solved the puzzle.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _SudokuGrid extends StatelessWidget {
  final SudokuBoard board;
  final SudokuBoard puzzle;
  final (int, int)? selectedCell;
  final double? maxHeight;
  final Function(int, int) onCellTap;
  final Function(int, int, int) onCellValueChange;

  const _SudokuGrid({
    required this.board,
    required this.puzzle,
    this.selectedCell,
    this.maxHeight,
    required this.onCellTap,
    required this.onCellValueChange,
  });

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
                  final isSelected = selectedCell != null &&
                      selectedCell!.$1 == row &&
                      selectedCell!.$2 == col;
                  final isGiven = puzzle.get(row, col) != 0;
                  final value = board.get(row, col);
                  final isBoxBorder = (row % 3 == 0 && row > 0) || (col % 3 == 0 && col > 0);

                  return GestureDetector(
                    onTap: () => onCellTap(row, col),
                    child: Container(
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
                        color: isSelected
                            ? Colors.blue.withValues(alpha: 0.3)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          value == 0 ? '' : '$value',
                          style: TextStyle(
                            fontSize: cellSize * 0.4,
                            fontWeight: isGiven ? FontWeight.bold : FontWeight.normal,
                            color: isGiven ? Colors.black : Colors.blue,
                          ),
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
