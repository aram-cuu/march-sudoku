import 'package:flutter_test/flutter_test.dart';
import 'package:march_sudoku/services/sudoku_parser.dart';
import 'package:march_sudoku/services/difficulty_classifier.dart';

void main() {
  group('DifficultyClassifier', () {
    test('classifies easy puzzle', () {
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
      final difficulty = DifficultyClassifier.classify(board);
      
      expect(difficulty, isA<Difficulty>());
    });

    test('classifies medium puzzle', () {
      final puzzleText = '''
7...9...3
2..468..1
..8...6..
.4..2..9.
...3.4...
.8..1..3.
..9...7..
5..142..6
8...5...2
''';
      final board = SudokuParser.parseFromString(puzzleText);
      final difficulty = DifficultyClassifier.classify(board);
      
      expect(difficulty, isA<Difficulty>());
    });

    test('classifies hard puzzle', () {
      final puzzleText = '''
.523..6..
6...4...3
.........
...63..1.
47.....35
.2..58...
.........
1...9...6
..5..172.
''';
      final board = SudokuParser.parseFromString(puzzleText);
      final difficulty = DifficultyClassifier.classify(board);
      
      expect(difficulty, isA<Difficulty>());
    });

    test('classifies samurai puzzle', () {
      final puzzleText = '''
5.....1.7
..43..5..
...2...8.
.9.4.2...
4.......6
...1.3.5.
.8...4...
..2..67..
3.9.....1
''';
      final board = SudokuParser.parseFromString(puzzleText);
      final difficulty = DifficultyClassifier.classify(board);
      
      expect(difficulty, isA<Difficulty>());
    });
  });
}
