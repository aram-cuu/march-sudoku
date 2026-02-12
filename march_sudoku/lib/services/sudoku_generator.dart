import 'dart:math';
import '../models/sudoku_board.dart';
import 'sudoku_solver.dart';
import 'difficulty_classifier.dart';

class SudokuGenerator {
  static SudokuBoard generate({Difficulty? targetDifficulty, bool symmetric = true}) {
    final completeBoard = _generateCompleteBoard();
    final puzzle = _removeCells(completeBoard, targetDifficulty: targetDifficulty, symmetric: symmetric);
    return puzzle;
  }
  
  static SudokuBoard _generateCompleteBoard() {
    final board = SudokuBoard.empty();
    _fillCompleteBoard(board);
    return board;
  }
  
  static bool _fillCompleteBoard(SudokuBoard board) {
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
        if (_fillCompleteBoard(board)) {
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
  
  static SudokuBoard _removeCells(SudokuBoard completeBoard, {Difficulty? targetDifficulty, bool symmetric = true}) {
    final puzzle = completeBoard.copy();
    final cells = _getAllCells();
    cells.shuffle(Random());
    
    for (final cell in cells) {
      final (row, col) = cell;
      
      if (puzzle.isEmpty(row, col)) continue;
      
      final originalValue = puzzle.get(row, col);
      puzzle.set(row, col, 0);
      
      if (symmetric) {
        final symmetricRow = SudokuBoard.size - 1 - row;
        final symmetricCol = SudokuBoard.size - 1 - col;
        final symmetricValue = puzzle.get(symmetricRow, symmetricCol);
        
        if (symmetricRow != row || symmetricCol != col) {
          if (symmetricValue != 0) {
            puzzle.set(symmetricRow, symmetricCol, 0);
            
            if (!SudokuSolver.hasUniqueSolution(puzzle)) {
              puzzle.set(row, col, originalValue);
              puzzle.set(symmetricRow, symmetricCol, symmetricValue);
              continue;
            }
          } else {
            if (!SudokuSolver.hasUniqueSolution(puzzle)) {
              puzzle.set(row, col, originalValue);
              continue;
            }
          }
        } else {
          if (!SudokuSolver.hasUniqueSolution(puzzle)) {
            puzzle.set(row, col, originalValue);
            continue;
          }
        }
      } else {
        if (!SudokuSolver.hasUniqueSolution(puzzle)) {
          puzzle.set(row, col, originalValue);
          continue;
        }
      }
      
      if (targetDifficulty != null) {
        final currentDifficulty = DifficultyClassifier.classify(puzzle);
        if (currentDifficulty == targetDifficulty) {
          break;
        }
      }
    }
    
    return puzzle;
  }
  
  static List<(int, int)> _getAllCells() {
    final cells = <(int, int)>[];
    for (int i = 0; i < SudokuBoard.size; i++) {
      for (int j = 0; j < SudokuBoard.size; j++) {
        cells.add((i, j));
      }
    }
    return cells;
  }
  
  static SudokuBoard generateWithDifficulty(Difficulty difficulty) {
    return generate(targetDifficulty: difficulty, symmetric: true);
  }
}
