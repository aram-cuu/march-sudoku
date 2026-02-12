import 'package:flutter_test/flutter_test.dart';
import 'package:march_sudoku/models/sudoku_board.dart';

void main() {
  group('SudokuBoard', () {
    test('creates empty board', () {
      final board = SudokuBoard.empty();
      
      expect(board.getClueCount(), 0);
      for (int i = 0; i < SudokuBoard.size; i++) {
        for (int j = 0; j < SudokuBoard.size; j++) {
          expect(board.isEmpty(i, j), isTrue);
        }
      }
    });

    test('sets and gets values', () {
      final board = SudokuBoard.empty();
      board.set(0, 0, 5);
      
      expect(board.get(0, 0), 5);
      expect(board.isEmpty(0, 0), isFalse);
    });

    test('validates placement', () {
      final board = SudokuBoard.empty();
      board.set(0, 0, 5);
      
      expect(board.isValidPlacement(0, 1, 5), isFalse);
      expect(board.isValidPlacement(0, 1, 6), isTrue);
      expect(board.isValidPlacement(1, 0, 5), isFalse);
      expect(board.isValidPlacement(1, 1, 5), isFalse);
    });

    test('checks completeness', () {
      final board = SudokuBoard.empty();
      expect(board.isComplete(), isFalse);
      
      for (int i = 0; i < SudokuBoard.size; i++) {
        for (int j = 0; j < SudokuBoard.size; j++) {
          board.set(i, j, ((i * 9 + j) % 9) + 1);
        }
      }
      
      expect(board.isComplete(), isFalse);
    });

    test('creates copy', () {
      final board = SudokuBoard.empty();
      board.set(0, 0, 5);
      final copy = board.copy();
      
      expect(copy.get(0, 0), 5);
      copy.set(0, 0, 6);
      expect(board.get(0, 0), 5);
      expect(copy.get(0, 0), 6);
    });
  });
}
