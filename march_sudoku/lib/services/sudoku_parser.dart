import 'package:flutter/services.dart';
import '../models/sudoku_board.dart';

class SudokuParser {
  static SudokuBoard parseFromString(String text) {
    final lines = text.trim().split('\n');
    
    if (lines.length != SudokuBoard.size) {
      throw FormatException('Sudoku must have exactly 9 lines');
    }
    
    final grid = <List<int>>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.length != SudokuBoard.size) {
        throw FormatException('Line ${i + 1} must have exactly 9 characters');
      }
      
      final row = <int>[];
      for (int j = 0; j < line.length; j++) {
        final char = line[j];
        if (char == '.' || char == ' ' || char == '0') {
          row.add(0);
        } else {
          final digit = int.tryParse(char);
          if (digit == null || digit < 1 || digit > 9) {
            throw FormatException('Invalid character "$char" at line ${i + 1}, column ${j + 1}');
          }
          row.add(digit);
        }
      }
      grid.add(row);
    }
    
    return SudokuBoard(grid);
  }
  
  static Future<SudokuBoard> parseFromAsset(String assetPath) async {
    try {
      final text = await rootBundle.loadString(assetPath);
      return parseFromString(text);
    } catch (e) {
      throw Exception('Failed to load puzzle from asset: $e');
    }
  }
}
