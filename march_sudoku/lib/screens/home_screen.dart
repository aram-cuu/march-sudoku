import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/difficulty_classifier.dart';
import 'play_screen.dart';
import 'solver_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Sudoku',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => _showDifficultyDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Play Puzzle'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SolverScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  minimumSize: const Size(200, 50),
                ),
                child: const Text('Solve Puzzle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Select Difficulty'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Easy'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _startGame(context, Difficulty.easy);
                },
              ),
              ListTile(
                title: const Text('Medium'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _startGame(context, Difficulty.medium);
                },
              ),
              ListTile(
                title: const Text('Hard'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _startGame(context, Difficulty.hard);
                },
              ),
              ListTile(
                title: const Text('Samurai'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _startGame(context, Difficulty.samurai);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _startGame(BuildContext context, Difficulty difficulty) {
    final provider = Provider.of<GameProvider>(context, listen: false);
    provider.generatePuzzle(difficulty: difficulty);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlayScreen()),
    );
  }
}
