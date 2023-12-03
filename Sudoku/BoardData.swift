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
	@Published public var colors: [Color] = Array(repeating: .primary, count: 81)
	@Published public var lifes: Int
	@Published public var score: Int
	@Published public var quit: Bool

	private(set) var sudoku: Sudoku?
	public var difficulty: Difficulty

	public init(difficulty: Difficulty) {
		Logger.entering("BoardData.<init>", difficulty)
		self.difficulty = difficulty
		values = ArrayUtil.array81(initial: 0)
		lifes = (difficulty == .easy) ? 5 : 3
		score = 0
		quit = false
	}

	public func resetBoard() {
		quit = false
		colors = Array(repeating: .primary, count: 81)
		values = Array(repeating: 0, count: 81)
		/*for i in 0...80 {
			colors[i] = .primary
			values[i] = 0
		}*/
	}

	public func isInitialized() -> Bool {
		return sudoku != nil
	}

	public func generatePuzzle() {
		Logger.debug("Generating sudoku puzzle with difficulty \(difficulty)")
		lifes = (difficulty == .easy) ? 5 : 3
		score = 0
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
		let puzzle = SudokuUtil.convertToArray(dataString: saveDataPuzzle)
		let answer = SudokuUtil.convertToArray(dataString: saveDataAnswer)
		sudoku = Sudoku(puzzle: puzzle, answer: answer)
		values = SudokuUtil.convertToArray(dataString: saveDataValues)
		self.difficulty = saveDataDifficulty
		/*for i in 0...80 {
			if (values[i] < 1 || !canChange(index: i)) {
				colors[i] = .primary
			} else if (values[i] == sudoku?.answer[i] ) {
				colors[i] = .green
			} else {
				colors[i] = .red
			}
		}*/
	}

	public func prepareBoard() {
		for i in 0...80 {
			if (values[i] < 1 || !canChange(index: i)) {
				colors[i] = .primary
			} else if (values[i] == sudoku?.answer[i] ) {
				colors[i] = .green
			} else {
				colors[i] = .red
			}
		}
	}

	public func valueAt(index: Int) -> Int {
		return values[index]
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
			colors[i] = .primary
			if (values[i] > 0) {
				if (sudoku!.answer[i] != values[i]) {
					colors[i] = .red
					valid = false
				} else if (canChange(index: i)) {
					colors[i] = .green
				}
			}
		}
		return valid
	}

	public func isSolved() -> Bool {
		return (!values.contains { $0 < 1 }) // values should not contain any entry smaller than 1
	}
	
	public func isCorrectValue(index: Int) -> Bool {
		return (values[index] == sudoku!.answer[index])
	}
}
