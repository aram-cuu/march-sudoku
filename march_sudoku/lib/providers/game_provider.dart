import 'package:flutter/foundation.dart';
import '../models/sudoku_board.dart';
import '../services/sudoku_solver.dart';
import '../services/sudoku_generator.dart';
import '../services/difficulty_classifier.dart';

class GameProvider extends ChangeNotifier {
  SudokuBoard? _puzzle;
  SudokuBoard? _solution;
  SudokuBoard? _currentBoard;
  Difficulty? _difficulty;
  bool _isSolved = false;
  bool _hasUniqueSolution = false;
  (int, int)? _selectedCell;
  int _elapsedSeconds = 0;
  
  SudokuBoard? get puzzle => _puzzle;
  SudokuBoard? get solution => _solution;
  SudokuBoard? get currentBoard => _currentBoard;
  Difficulty? get difficulty => _difficulty;
  bool get isSolved => _isSolved;
  bool get hasUniqueSolution => _hasUniqueSolution;
  (int, int)? get selectedCell => _selectedCell;
  int get elapsedSeconds => _elapsedSeconds;
  
  void loadPuzzle(SudokuBoard board) {
    _puzzle = board;
    _currentBoard = board.copy();
    _solution = null;
    _isSolved = false;
    _hasUniqueSolution = false;
    _selectedCell = null;
    _elapsedSeconds = 0;
    _difficulty = DifficultyClassifier.classify(board);
    notifyListeners();
  }
  
  void generatePuzzle({Difficulty? difficulty, bool symmetric = true}) {
    final board = difficulty != null
        ? SudokuGenerator.generateWithDifficulty(difficulty)
        : SudokuGenerator.generate(symmetric: symmetric);
    loadPuzzle(board);
  }
  
  void solvePuzzle() {
    if (_currentBoard == null) return;
    
    _solution = SudokuSolver.solveAndReturn(_currentBoard!);
    _hasUniqueSolution = SudokuSolver.hasUniqueSolution(_currentBoard!);
    
    if (_solution != null) {
      _currentBoard = _solution!.copy();
      _isSolved = true;
    }
    
    notifyListeners();
  }
  
  void setCell(int row, int col, int value) {
    if (_currentBoard == null || _puzzle == null) return;
    
    if (_puzzle!.get(row, col) != 0) {
      return;
    }
    
    if (value < 0 || value > 9) return;
    
    _currentBoard!.set(row, col, value);
    _isSolved = _currentBoard!.isComplete();
    notifyListeners();
  }
  
  void clearCell(int row, int col) {
    if (_currentBoard == null || _puzzle == null) return;
    
    if (_puzzle!.get(row, col) != 0) {
      return;
    }
    
    _currentBoard!.set(row, col, 0);
    _isSolved = false;
    notifyListeners();
  }
  
  void selectCell(int row, int col) {
    _selectedCell = (row, col);
    notifyListeners();
  }
  
  void clearSelection() {
    _selectedCell = null;
    notifyListeners();
  }
  
  void updateTimer(int seconds) {
    _elapsedSeconds = seconds;
    notifyListeners();
  }
  
  void reset() {
    if (_puzzle != null) {
      _currentBoard = _puzzle!.copy();
      _isSolved = false;
      _selectedCell = null;
      _elapsedSeconds = 0;
      notifyListeners();
    }
  }
  
  void showHint() {
    if (_currentBoard == null || _solution == null) {
      solvePuzzle();
    }
    
    if (_solution == null) return;
    
    for (int i = 0; i < SudokuBoard.size; i++) {
      for (int j = 0; j < SudokuBoard.size; j++) {
        if (_currentBoard!.isEmpty(i, j)) {
          _currentBoard!.set(i, j, _solution!.get(i, j));
          notifyListeners();
          return;
        }
      }
    }
  }
}
