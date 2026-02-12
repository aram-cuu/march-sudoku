import 'package:flutter_test/flutter_test.dart';
import 'package:march_sudoku/models/sudoku_board.dart';
import 'package:march_sudoku/services/sudoku_parser.dart';
import 'package:march_sudoku/services/sudoku_solver.dart';

void main() {
  group('SudokuSolver', () {
    test('solves a valid puzzle', () {
      final puzzleText = '''
51.....83
8..416..5
.........
.985.461.
...9.1...
.642.357.
.........
6..157..4
78.....96
''';
      final board = SudokuParser.parseFromString(puzzleText);
      final solution = SudokuSolver.solveAndReturn(board);
      
      expect(solution, isNotNull);
      expect(solution!.isComplete(), isTrue);
    });

    test('verifies unique solution', () {
      final puzzleText = '''
51.....83
8..416..5
.........
.985.461.
...9.1...
.642.357.
.........
6..157..4
78.....96
''';
      final board = SudokuParser.parseFromString(puzzleText);
      final hasUnique = SudokuSolver.hasUniqueSolution(board);
      
      expect(hasUnique, isTrue);
    });

    test('solves empty board', () {
      final board = SudokuBoard.empty();
      final solved = SudokuSolver.solve(board);
      
      expect(solved, isTrue);
      expect(board.isComplete(), isTrue);
    });

    test('handles invalid puzzle', () {
      final puzzleText = '''
11.....83
8..416..5
.........
.985.461.
...9.1...
.642.357.
.........
6..157..4
78.....96
''';
      final board = SudokuParser.parseFromString(puzzleText);
      final solution = SudokuSolver.solveAndReturn(board);
      
      expect(solution, isNull);
    });
  });
}
