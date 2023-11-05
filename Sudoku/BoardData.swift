//
//  BoardData.swift
//  Sudoku
//
//  Created by Andreas Job on 01.07.23.
//

import Foundation
import SwiftUI

/*class SaveData1 {
	var values: [Int]
	var lifes: Int
	var puzzle: [Int]
	var answer: [Int]
	var score: Int
	var playTime: Int

	public init(puzzle: [Int], answer: [Int], values: [Int], lifes: Int, score: Int, playTime: Int) {
		self.puzzle = puzzle
		self.answer = answer
		self.values = values
		self.lifes = lifes
		self.score = score
		self.playTime = playTime
	}
}*/

class BoardData: ObservableObject {
	@Published public var values: [Int]
	@Published public var colors: [Color] = Array(repeating: .black, count: 81)
	@Published public var lifes: Int
	@Published public var quit: Bool

	private(set) var sudoku: Sudoku?
	public var difficulty: Difficulty

	public init(difficulty: Difficulty) {
		Logger.entering("BoardData.<init>", difficulty)
		self.difficulty = difficulty
		values = ArrayUtil.array81(initial: 0)
		lifes = 3
		quit = false
	}

	public func resetBoard() {
		quit = false
		colors = Array(repeating: .black, count: 81)
		values = Array(repeating: 0, count: 81)
		/*for i in 0...80 {
			colors[i] = .black
			values[i] = 0
		}*/
	}

	public func isInitialized() -> Bool {
		return sudoku != nil
	}

	public func generatePuzzle() {
		Logger.debug("Generating sudoku puzzle with difficulty \(difficulty)")
		lifes = 3
		repeat {
			sudoku = SudokuGenerator.generate(level: difficulty)
		} while (sudoku == nil)
		values = sudoku!.puzzle
	}

	public func generatePuzzle(saveData: SaveData) throws {
		Logger.debug("Generating sudoku puzzle from saved data")
		guard let saveDataPuzzle = saveData.puzzle,
			  let saveDataAnswer = saveData.answer,
			  let saveDataValues = saveData.values,
			  let saveDataDifficulty = Difficulty(rawValue: Int(saveData.difficulty)) else {
			Logger.error("Invalid save data.")
			quit = true
			throw SaveDataError(.invalidData, "Invalid save data.")
		}
		quit = false
		lifes = max(1, Int(saveData.lifes))
		let puzzle = SudokuUtil.convertToArray(dataString: saveDataPuzzle)
		let answer = SudokuUtil.convertToArray(dataString: saveDataAnswer)
		sudoku = Sudoku(puzzle: puzzle, answer: answer)
		values = SudokuUtil.convertToArray(dataString: saveDataValues)
		self.difficulty = saveDataDifficulty
		/*for i in 0...80 {
			if (values[i] < 1 || !canChange(index: i)) {
				colors[i] = .black
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
				colors[i] = .black
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
			colors[i] = .black
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

	@discardableResult
	public func isSolved() -> Bool {
		return (!values.contains { $0 < 1 }) // values should not contain any entry smaller than 1
	}
}
