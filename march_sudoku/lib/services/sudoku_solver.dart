import 'dart:math';
import '../models/sudoku_board.dart';

class SudokuSolver {
  static bool solve(SudokuBoard board) {
    return _solveRecursive(board);
  }
  
  static bool _solveRecursive(SudokuBoard board) {
    final emptyCell = _findEmptyCell(board);
    if (emptyCell == null) {
      return true;
    }
    
    final (row, col) = emptyCell;
    final digits = List.generate(9, (i) => i + 1);
    digits.shuffle(Random());
    
    for (final digit in digits) {
      if (board.isValidPlacement(row, col, digit)) {
        board.set(row, col, digit);
        if (_solveRecursive(board)) {
          return true;
        }
        board.set(row, col, 0);
      }
    }
    
    return false;
  }
  
  static (int, int)? _findEmptyCell(SudokuBoard board) {
    for (int i = 0; i < SudokuBoard.size; i++) {
      for (int j = 0; j < SudokuBoard.size; j++) {
        if (board.isEmpty(i, j)) {
          return (i, j);
        }
      }
    }
    return null;
  }
  
  static bool hasUniqueSolution(SudokuBoard board) {
    return _countSolutions(board.copy(), 0, 2) == 1;
  }
  
  static int _countSolutions(SudokuBoard board, int count, int limit) {
    if (count >= limit) {
      return count;
    }
    
    final emptyCell = _findEmptyCell(board);
    if (emptyCell == null) {
      return count + 1;
    }
    
    final (row, col) = emptyCell;
    final digits = List.generate(9, (i) => i + 1);
    
    for (final digit in digits) {
      if (board.isValidPlacement(row, col, digit)) {
        board.set(row, col, digit);
        count = _countSolutions(board, count, limit);
        if (count >= limit) {
          board.set(row, col, 0);
          return count;
        }
        board.set(row, col, 0);
      }
    }
    
    return count;
  }
  
  static SudokuBoard? solveAndReturn(SudokuBoard board) {
    final solution = board.copy();
    if (solve(solution)) {
      return solution;
    }
    return null;
  }
}
