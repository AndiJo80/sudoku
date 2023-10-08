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
	@Published public var colors: [Color] = Array(repeating: .black, count: 81)
	@Published public var lifes: Int
	@Published public var quit: Bool

	private var sudoku: Sudoku?
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
		for i in 0...80 {
			colors[i] = .black
			values[i] = 0
		}
	}

	public func isInitialized() -> Bool {
		return sudoku != nil
	}

	public func generatePuzzle() {
		lifes = 3
		Logger.debug("Generating sudoku puzzle with difficulty \(difficulty)")
		sudoku = nil
		repeat {
			sudoku = SudokuGenerator.generate(level: difficulty)
		} while (sudoku == nil)
		values = sudoku?.puzzle ?? ArrayUtil.array81(initial: 0)
		//Logger.debug("values: \(values)")
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
