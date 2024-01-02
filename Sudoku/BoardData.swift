//
//  BoardData.swift
//  Sudoku
//
//  Created by Andreas Job on 01.07.23.
//

import Foundation
import SwiftUI

class BoardData: ObservableObject {
	@Published public var values: [Int]
	@Published public var notes: [Int]
	@Published public var colors: [Color] = Array(repeating: .textColor, count: 81)
	@Published public var lifes: Int
	@Published public var score: Int
	@Published public var quit: Bool
	@Published public var bgColors: [Color] = Array(repeating: .clear, count: 81)
	@Published public var selectedCellIdx: Int = -1
	@Published public var playTime: Int = 0
	@Published public var hintsAvailable = 3

	private(set) var sudoku: Sudoku?
	public var difficulty: Difficulty

	private static func hintsAvailable(for difficulty: Difficulty) -> Int {
		let hintsAvailable: Int
		switch difficulty {
		case .easy:
			hintsAvailable = 10
		case .medium:
			hintsAvailable = 10
		case .hard:
			hintsAvailable = 5
		case .expert:
			hintsAvailable = 5
		case .hell:
			hintsAvailable = 3
		}
		return hintsAvailable
	}

	private static func lifes(for difficulty: Difficulty) -> Int {
		let lifes: Int
		switch difficulty {
		case .easy:
			lifes = 6
		case .medium:
			lifes = 5
		case .hard:
			lifes = 4
		case .expert:
			lifes = 3
		case .hell:
			lifes = 3
		}
		return lifes
	}

	public init(difficulty: Difficulty) {
		Logger.entering("BoardData.<init>", difficulty)
		self.difficulty = difficulty
		values = ArrayUtil.array81(initial: 0)
		notes = ArrayUtil.array81(initial: 0)
		lifes = BoardData.lifes(for: difficulty)
		hintsAvailable = BoardData.hintsAvailable(for: difficulty)
		score = 0
		quit = false
	}

	public func resetBoard() {
		quit = false
		colors = ArrayUtil.array81(initial: Color.textColor)
		values = ArrayUtil.array81(initial: 0)
		notes = ArrayUtil.array81(initial: 0)
		bgColors = Array(repeating: .clear, count: 81)
		selectedCellIdx = -1
	}

	public func isInitialized() -> Bool {
		return sudoku != nil
	}

	public func generatePuzzle() {
		Logger.debug("Generating sudoku puzzle with difficulty \(difficulty)")
		lifes = BoardData.lifes(for: difficulty)
		score = 0
		playTime = 0
		hintsAvailable = BoardData.hintsAvailable(for: difficulty)
		repeat {
			sudoku = SudokuGenerator.generate(level: difficulty)
		} while (sudoku == nil)
		values = sudoku!.puzzle
	}

	public func generatePuzzle(saveData: SaveData) throws {
		Logger.debug("Generating sudoku puzzle from saved data")
		quit = true
		guard let saveDataPuzzle = saveData.puzzle else {
			Logger.error("Invalid save data: SaveData.puzzle")
			throw SaveDataError.invalidData("SaveData.puzzle")
		}
		guard let saveDataAnswer = saveData.answer else {
			Logger.error("Invalid save data: SaveData.answer")
			throw SaveDataError.invalidData("SaveData.answer")
		}
		guard let saveDataValues = saveData.values else {
			Logger.error("Invalid save data: SaveData.values")
			throw SaveDataError.invalidData("SaveData.values")
		}
		guard let saveDataDifficulty = Difficulty(rawValue: Int(saveData.difficulty)) else {
			Logger.error("Invalid save data: SaveData.difficulty")
			throw SaveDataError.invalidData("SaveData.difficulty")
		}
		quit = false
		lifes = max(1, Int(saveData.lifes))
		score = max(0, Int(saveData.score))
		playTime = max(0, Int(saveData.playTime))
		hintsAvailable = max(0, Int(saveData.hintsAvailable))
		let puzzle = SudokuUtil.convertToArray(dataString: saveDataPuzzle)
		let answer = SudokuUtil.convertToArray(dataString: saveDataAnswer)
		sudoku = Sudoku(puzzle: puzzle, answer: answer)
		values = SudokuUtil.convertToArray(dataString: saveDataValues)
		self.difficulty = saveDataDifficulty
	}

	public func prepareBoard() {
		bgColors = Array(repeating: .clear, count: 81)
		selectedCellIdx = -1
		for i in 0...80 {
			if (values[i] < 1 || !canChange(index: i)) {
				colors[i] = .textColor
			} else if (values[i] == sudoku?.answer[i] ) {
				colors[i] = .blue
			} else {
				colors[i] = .red
			}
		}
	}

	public func valueAt(row: Int, col: Int) -> Int {
		return values[row * 9 + col]
	}

	public func answerAt(index: Int) -> Int {
		return sudoku!.answer[index]
	}

	public func canChange(index: Int) -> Bool {
		return (sudoku!.puzzle[index] == -1)
	}

	@discardableResult
	public func validate() -> Bool {
		var valid = true
		for i in 0...80 {
			colors[i] = .textColor
			if (values[i] > 0) {
				if (sudoku!.answer[i] != values[i]) {
					colors[i] = .red
					valid = false
				} else if (canChange(index: i)) {
					colors[i] = .blue
				}
			}
		}
		return valid
	}

	public func isSolved() -> Bool {
		if (values.contains { $0 < 1 }) { // values should not contain any entry smaller than 1
			return false
		}
		for i in 0...80 {
			if (!isCorrectValue(index: i)) {
				return false
			}
		}
		return true
	}

	public func isCorrectValue(index: Int) -> Bool {
		return (values[index] == sudoku!.answer[index])
	}

	public func countOccurences(of searchValue: Int) -> Int {
		var count = 0
		for i in 0...80 {
			let boardVal = values[i]
			if (boardVal == searchValue && isCorrectValue(index: i)) {
				count+=1
			}
		}
		//Logger.debug("Number \(searchValue) appears \(count) times")
		return count
	}

	public func updateBgColors() {
		let myValue = values[selectedCellIdx]
		let myLocation = SudokuUtil.location(index: selectedCellIdx)
		for i in 0...80 {
			let currentLocation = SudokuUtil.location(index: i)
			if (   currentLocation.zone == myLocation.zone
				|| currentLocation.col == myLocation.col
				|| currentLocation.row == myLocation.row) {
				bgColors[i] = .highlightedCellColor
			} else if (myValue > 0 && values[i] == myValue) {
				bgColors[i] = .highlightedCellColor2
			} else {
				bgColors[i] = .clear
			}
		}
		bgColors[selectedCellIdx] = .selectedCellColor
	}
}
