# Algorithms documentation

This document explains the algorithms used in the Sudoku application. All algorithms are designed to be simple and easy to understand, making them suitable for discussion in a technical interview.

## Sudoku solver

The solver uses a recursive backtracking algorithm, which is a straightforward approach that is easy to explain and understand.

### Algorithm

```
function solve(board):
    emptyCell = findEmptyCell(board)
    if emptyCell is null:
        return true  // Puzzle is solved
    
    (row, col) = emptyCell
    for digit from 1 to 9 (in random order):
        if isValidPlacement(board, row, col, digit):
            board[row][col] = digit
            if solve(board):
                return true
            board[row][col] = 0  // Backtrack
    
    return false  // No valid solution found
```

### Uniqueness verification

To verify that a puzzle has a unique solution, we count the number of solutions:

```
function countSolutions(board, currentCount, limit):
    if currentCount >= limit:
        return currentCount
    
    emptyCell = findEmptyCell(board)
    if emptyCell is null:
        return currentCount + 1  // Found a solution
    
    (row, col) = emptyCell
    for digit from 1 to 9:
        if isValidPlacement(board, row, col, digit):
            board[row][col] = digit
            currentCount = countSolutions(board, currentCount, limit)
            if currentCount >= limit:
                board[row][col] = 0
                return currentCount
            board[row][col] = 0
    
    return currentCount
```

The function stops counting as soon as it finds two solutions, since we only need to know if there is exactly one solution.

### Complexity

Time complexity: O(9^m) where m is the number of empty cells. In practice, backtracking is much faster because most branches are pruned early.

Space complexity: O(m) for the recursion stack.

## Difficulty classifier

The classifier determines puzzle difficulty by analyzing two factors: the number of given clues and the solving techniques required.

### Algorithm

```
function classify(board):
    clueCount = countClues(board)
    technique = determineTechnique(board)
    
    if clueCount >= 35 and technique == NAKED_SINGLE:
        return EASY
    else if clueCount >= 28 and technique != BACKTRACKING:
        return MEDIUM
    else if clueCount >= 22:
        return HARD
    else:
        return SAMURAI
```

### Technique detection

The classifier attempts to solve the puzzle using progressively more advanced techniques:

**Naked singles**: A cell that has only one possible candidate value.

```
function canSolveWithNakedSingles(board):
    changed = true
    while changed:
        changed = false
        for each empty cell (row, col) in board:
            candidates = getCandidates(board, row, col)
            if candidates.length == 1:
                board[row][col] = candidates[0]
                changed = true
    
    return board.isComplete()
```

**Hidden singles**: A candidate that appears only once in a row, column, or box.

```
function canSolveWithHiddenSingles(board):
    changed = true
    while changed:
        changed = false
        for each empty cell (row, col) in board:
            candidates = getCandidates(board, row, col)
            if candidates.length == 1:
                board[row][col] = candidates[0]
                changed = true
            else if isHiddenSingleInRow(board, row, col, candidates) or
                    isHiddenSingleInCol(board, row, col, candidates) or
                    isHiddenSingleInBox(board, row, col, candidates):
                board[row][col] = candidates[0]
                changed = true
    
    return board.isComplete()
```

If neither technique can solve the puzzle, it requires backtracking.

### Complexity

Time complexity: O(n^2) for each technique attempt, where n is the number of cells. The classifier may try multiple techniques, but typically stops early.

Space complexity: O(1) for the classification itself, though the technique detection may use O(n) for candidate lists.

## Puzzle generator

The generator creates puzzles with unique solutions by starting with a complete valid board and removing cells while maintaining uniqueness.

### Algorithm

```
function generate():
    completeBoard = generateCompleteBoard()
    puzzle = removeCells(completeBoard)
    return puzzle

function generateCompleteBoard():
    board = emptyBoard()
    fillCompleteBoard(board)
    return board

function fillCompleteBoard(board):
    emptyCell = findEmptyCell(board)
    if emptyCell is null:
        return true
    
    (row, col) = emptyCell
    digits = [1, 2, 3, 4, 5, 6, 7, 8, 9] shuffled randomly
    for digit in digits:
        if isValidPlacement(board, row, col, digit):
            board[row][col] = digit
            if fillCompleteBoard(board):
                return true
            board[row][col] = 0
    
    return false

function removeCells(completeBoard, targetDifficulty, symmetric):
    puzzle = copy(completeBoard)
    cells = getAllCells() shuffled randomly
    
    for each cell (row, col) in cells:
        if puzzle[row][col] is empty:
            continue
        
        originalValue = puzzle[row][col]
        puzzle[row][col] = 0
        
        if symmetric:
            symmetricRow = 8 - row
            symmetricCol = 8 - col
            if (symmetricRow, symmetricCol) != (row, col):
                symmetricValue = puzzle[symmetricRow][symmetricCol]
                puzzle[symmetricRow][symmetricCol] = 0
                if not hasUniqueSolution(puzzle):
                    puzzle[row][col] = originalValue
                    puzzle[symmetricRow][symmetricCol] = symmetricValue
                    continue
        else:
            if not hasUniqueSolution(puzzle):
                puzzle[row][col] = originalValue
                continue
        
        if targetDifficulty is not null:
            currentDifficulty = classify(puzzle)
            if currentDifficulty == targetDifficulty:
                break
    
    return puzzle
```

### Symmetry

When symmetric generation is enabled, cells are removed in rotationally symmetric pairs. If cell (r, c) is removed, cell (8-r, 8-c) is also removed. This creates visually appealing puzzles that match the style of published Sudoku puzzles.

### Complexity

Time complexity: O(n * s) where n is the number of cells and s is the time to verify uniqueness. In practice, the generator may need to try many cell removals before finding a puzzle of the desired difficulty.

Space complexity: O(1) for the board representation, O(n) for the cell list.

## Parser

The parser converts text representations of puzzles into `SudokuBoard` instances.

### Algorithm

```
function parseFromString(text):
    lines = text.trim().split('\n')
    if lines.length != 9:
        throw error
    
    grid = []
    for i from 0 to 8:
        line = lines[i].trim()
        if line.length != 9:
            throw error
        
        row = []
        for j from 0 to 8:
            char = line[j]
            if char is '.' or ' ' or '0':
                row.append(0)
            else:
                digit = parseInt(char)
                if digit is null or digit < 1 or digit > 9:
                    throw error
                row.append(digit)
        
        grid.append(row)
    
    return SudokuBoard(grid)
```

### Input format

The parser expects 9 lines of text, each containing exactly 9 characters. Digits 1-9 represent filled cells, and any other character (typically `.` or `0`) represents an empty cell.

### Complexity

Time complexity: O(1) since we always process exactly 81 characters.

Space complexity: O(1) for the fixed-size grid.
