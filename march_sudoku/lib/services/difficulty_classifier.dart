import '../models/sudoku_board.dart';

enum Difficulty {
  easy,
  medium,
  hard,
  samurai,
}

class DifficultyClassifier {
  static Difficulty classify(SudokuBoard board) {
    final clueCount = board.getClueCount();
    final technique = _determineTechnique(board);
    
    if (clueCount >= 35 && technique == SolvingTechnique.nakedSingle) {
      return Difficulty.easy;
    } else if (clueCount >= 28 && technique != SolvingTechnique.backtracking) {
      return Difficulty.medium;
    } else if (clueCount >= 22) {
      return Difficulty.hard;
    } else {
      return Difficulty.samurai;
    }
  }
  
  static SolvingTechnique _determineTechnique(SudokuBoard board) {
    final testBoard = board.copy();
    
    if (_canSolveWithNakedSingles(testBoard)) {
      return SolvingTechnique.nakedSingle;
    }
    
    if (_canSolveWithHiddenSingles(testBoard)) {
      return SolvingTechnique.hiddenSingle;
    }
    
    return SolvingTechnique.backtracking;
  }
  
  static bool _canSolveWithNakedSingles(SudokuBoard board) {
    bool changed = true;
    while (changed) {
      changed = false;
      for (int i = 0; i < SudokuBoard.size; i++) {
        for (int j = 0; j < SudokuBoard.size; j++) {
          if (board.isEmpty(i, j)) {
            final candidates = _getCandidates(board, i, j);
            if (candidates.length == 1) {
              board.set(i, j, candidates.first);
              changed = true;
            }
          }
        }
      }
    }
    return board.isComplete();
  }
  
  static bool _canSolveWithHiddenSingles(SudokuBoard board) {
    bool changed = true;
    while (changed) {
      changed = false;
      
      for (int i = 0; i < SudokuBoard.size; i++) {
        for (int j = 0; j < SudokuBoard.size; j++) {
          if (board.isEmpty(i, j)) {
            final candidates = _getCandidates(board, i, j);
            if (candidates.length == 1) {
              board.set(i, j, candidates.first);
              changed = true;
              continue;
            }
            
            if (_isHiddenSingleInRow(board, i, j, candidates) ||
                _isHiddenSingleInCol(board, i, j, candidates) ||
                _isHiddenSingleInBox(board, i, j, candidates)) {
              board.set(i, j, candidates.first);
              changed = true;
            }
          }
        }
      }
    }
    return board.isComplete();
  }
  
  static List<int> _getCandidates(SudokuBoard board, int row, int col) {
    final candidates = <int>[];
    for (int digit = 1; digit <= 9; digit++) {
      if (board.isValidPlacement(row, col, digit)) {
        candidates.add(digit);
      }
    }
    return candidates;
  }
  
  static bool _isHiddenSingleInRow(SudokuBoard board, int row, int col, List<int> candidates) {
    for (final candidate in candidates) {
      bool isUnique = true;
      for (int j = 0; j < SudokuBoard.size; j++) {
        if (j != col && board.isEmpty(row, j) && board.isValidPlacement(row, j, candidate)) {
          isUnique = false;
          break;
        }
      }
      if (isUnique) return true;
    }
    return false;
  }
  
  static bool _isHiddenSingleInCol(SudokuBoard board, int row, int col, List<int> candidates) {
    for (final candidate in candidates) {
      bool isUnique = true;
      for (int i = 0; i < SudokuBoard.size; i++) {
        if (i != row && board.isEmpty(i, col) && board.isValidPlacement(i, col, candidate)) {
          isUnique = false;
          break;
        }
      }
      if (isUnique) return true;
    }
    return false;
  }
  
  static bool _isHiddenSingleInBox(SudokuBoard board, int row, int col, List<int> candidates) {
    final boxRow = (row ~/ SudokuBoard.boxSize) * SudokuBoard.boxSize;
    final boxCol = (col ~/ SudokuBoard.boxSize) * SudokuBoard.boxSize;
    
    for (final candidate in candidates) {
      bool isUnique = true;
      for (int i = boxRow; i < boxRow + SudokuBoard.boxSize; i++) {
        for (int j = boxCol; j < boxCol + SudokuBoard.boxSize; j++) {
          if ((i != row || j != col) && board.isEmpty(i, j) && board.isValidPlacement(i, j, candidate)) {
            isUnique = false;
            break;
          }
        }
        if (!isUnique) break;
      }
      if (isUnique) return true;
    }
    return false;
  }
}

enum SolvingTechnique {
  nakedSingle,
  hiddenSingle,
  backtracking,
}
