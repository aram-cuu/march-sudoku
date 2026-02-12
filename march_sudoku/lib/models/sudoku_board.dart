class SudokuBoard {
  static const int size = 9;
  static const int boxSize = 3;
  
  final List<List<int>> grid;
  
  SudokuBoard(this.grid) {
    if (grid.length != size || grid.any((row) => row.length != size)) {
      throw ArgumentError('Grid must be 9x9');
    }
  }
  
  SudokuBoard.empty() : grid = List.generate(size, (_) => List.filled(size, 0));
  
  SudokuBoard copy() {
    return SudokuBoard(grid.map((row) => List<int>.from(row)).toList());
  }
  
  int get(int row, int col) {
    return grid[row][col];
  }
  
  void set(int row, int col, int value) {
    if (value < 0 || value > 9) {
      throw ArgumentError('Value must be between 0 and 9');
    }
    grid[row][col] = value;
  }
  
  bool isEmpty(int row, int col) {
    return grid[row][col] == 0;
  }
  
  bool isValidPlacement(int row, int col, int value) {
    if (value < 1 || value > 9) return false;
    
    for (int i = 0; i < size; i++) {
      if (grid[row][i] == value && i != col) return false;
      if (grid[i][col] == value && i != row) return false;
    }
    
    int boxRow = (row ~/ boxSize) * boxSize;
    int boxCol = (col ~/ boxSize) * boxSize;
    
    for (int i = boxRow; i < boxRow + boxSize; i++) {
      for (int j = boxCol; j < boxCol + boxSize; j++) {
        if (grid[i][j] == value && (i != row || j != col)) return false;
      }
    }
    
    return true;
  }
  
  bool isComplete() {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (grid[i][j] == 0) return false;
        if (!isValidPlacement(i, j, grid[i][j])) return false;
      }
    }
    return true;
  }
  
  int getClueCount() {
    int count = 0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (grid[i][j] != 0) count++;
      }
    }
    return count;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SudokuBoard) return false;
    
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (grid[i][j] != other.grid[i][j]) return false;
      }
    }
    return true;
  }
  
  @override
  int get hashCode {
    return grid.fold(0, (sum, row) => sum + row.fold(0, (s, val) => s + val));
  }
  
  String toDisplayString() {
    final buffer = StringBuffer();
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (grid[i][j] == 0) {
          buffer.write('.');
        } else {
          buffer.write(grid[i][j]);
        }
      }
      if (i < size - 1) buffer.write('\n');
    }
    return buffer.toString();
  }
}
