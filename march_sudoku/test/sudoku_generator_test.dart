import 'package:flutter_test/flutter_test.dart';
import 'package:march_sudoku/models/sudoku_board.dart';
import 'package:march_sudoku/services/sudoku_generator.dart';
import 'package:march_sudoku/services/sudoku_solver.dart';
import 'package:march_sudoku/services/difficulty_classifier.dart';

void main() {
  group('SudokuGenerator', () {
    test('generates a valid puzzle', () {
      final puzzle = SudokuGenerator.generate();
      
      expect(puzzle, isNotNull);
      expect(puzzle.getClueCount(), greaterThan(0));
      expect(puzzle.getClueCount(), lessThan(81));
    });

    test('generated puzzle has unique solution', () {
      final puzzle = SudokuGenerator.generate();
      final hasUnique = SudokuSolver.hasUniqueSolution(puzzle);
      
      expect(hasUnique, isTrue);
    });

    test('generates puzzle with specific difficulty', () {
      final easyPuzzle = SudokuGenerator.generateWithDifficulty(Difficulty.easy);
      final difficulty = DifficultyClassifier.classify(easyPuzzle);
      
      expect(difficulty, Difficulty.easy);
    });

    test('generated puzzle can be solved', () {
      final puzzle = SudokuGenerator.generate();
      final solution = SudokuSolver.solveAndReturn(puzzle);
      
      expect(solution, isNotNull);
      expect(solution!.isComplete(), isTrue);
    });

    test('generates symmetric puzzle', () {
      final puzzle = SudokuGenerator.generate(symmetric: true);
      final hasUnique = SudokuSolver.hasUniqueSolution(puzzle);
      
      expect(hasUnique, isTrue);
    });
  });
}
