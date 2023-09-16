//
//  Sudoku.swift
//  Sudoku
//
//  Created by Andreas Job on 06.08.23.
//

import Foundation

public class Sudoku {
	private(set) var puzzle: [Int] = ArrayUtil.array81(initial: -1)
	private(set) var answer: [Int] = ArrayUtil.array81(initial: -1)
	public  var solution: [Int] { return answer }
	// private members
	private var rows: [[Bool]] = ArrayUtil.array9x9(initial: false)
	private var cols: [[Bool]] = ArrayUtil.array9x9(initial: false)
	private var zones: [[Bool]] = ArrayUtil.array9x9(initial: false)
	private var nums: [Int] = ArrayUtil.array9(initial: -1)
	private var finishes = 0
	private var isOneSolutionMode = false
	private var beginTime: Date = Date.now
	private var endTime: Date = Date.now

	init(_ source: Sudoku) throws {
		puzzle = source.puzzle
		answer = source.answer
		rows = source.rows
		cols = source.cols
		zones = source.zones
		nums = source.nums
		finishes = source.finishes
		isOneSolutionMode = source.isOneSolutionMode
		beginTime = source.beginTime
		endTime = source.endTime
	}

	convenience init(puzzle: [Int]) throws {
		try self.init(puzzle: puzzle, strict: false)
	}

	init(puzzle: [Int], strict: Bool) throws {
		beginTime = Date.now
		self.puzzle = puzzle
		answer = puzzle
		nums = SudokuUtil.shuffleNumbers()
		finishes = 0
		isOneSolutionMode = strict
		defer {
			endTime = Date.now
		}

		for (i, val) in puzzle.enumerated() {
			if (val == -1) {
				continue
			}

			let location = SudokuUtil.location(index: i)
			rows[location.row][val - 1] = true
			cols[location.col][val - 1] = true
			zones[location.zone][val - 1] = true
		}

		// calculate
		try calculate()
	}

	private func calculate() throws {
		guard let firstCheckPoint = answer.firstIndex(where: { $0 == -1 }) else {
			return
		}

		if isOneSolutionMode {
			let solved = try dsfOneSolutionCalculate(index: firstCheckPoint)
			if (finishes > 1) {
				throw SudokuError("puzzle is not one-solution sudoku")
			}
			if (!solved || answer.contains { $0 == -1 }) {
				throw SudokuError("puzzle can't solve")
			}
			/*if (finishes == 0) {
				throw SudokuError("puzzle can't solve")
			}*/
			return
		}

		if try !backtrackCalculate(index: firstCheckPoint) {
			throw SudokuError("puzzle can't solve")
		}
	}

	@discardableResult
	private func dsfOneSolutionCalculate(index: Int) throws -> Bool {
		if (finishes > 1) {
			return true
		}

		if (index >= 81) {
			if (answer.contains { $0 == -1 }) {
				return false
			}
			finishes += 1
			return true
		}

		if (answer[index] != -1) {
			return try dsfOneSolutionCalculate(index: index + 1)
		}

		let location = SudokuUtil.location(index: index)
		for num in nums {
			if (!rows[location.row][num] && !cols[location.col][num] && !zones[location.zone][num]) {
				rows[location.row][num] = true
				cols[location.col][num] = true
				zones[location.zone][num] = true
				answer[index] = num + 1;

				if (try dsfOneSolutionCalculate(index: index + 1) == false) {
					rows[location.row][num] = false
					cols[location.col][num] = false
					zones[location.zone][num] = false
					answer[index] = -1;
				}
			}
		}
		return finishes > 0
	}

	private func backtrackCalculate(index: Int) throws -> Bool {
		if (index >= 81) {
			return true
		}

		if (answer[index] != -1) {
			return try backtrackCalculate(index: index + 1)
		}

		let location = SudokuUtil.location(index: index)
		for num in nums {
			if (!rows[location.row][num] && !cols[location.col][num] && !zones[location.zone][num]) {
				rows[location.row][num] = true
				cols[location.col][num] = true
				zones[location.zone][num] = true
				answer[index] = num + 1;

				if (try !backtrackCalculate(index: index + 1)) {
					rows[location.row][num] = false
					cols[location.col][num] = false
					zones[location.zone][num] = false
					answer[index] = -1;
				} else {
					return true
				}
			}
		}
		return false
	}
}

public class SudokuError: Error {
	public let error: String

	init(_ error: String) {
		self.error = error
	}
}
/*enum SudokuError: Error {
	 case puzzleCantSolve
	 case moreThanOneSolve
}*/

public struct Location {
	var row: Int
	var col: Int
	var zone: Int
	var index: Int
}

public class SudokuUtil {

	private init() {}

	public static func location(index: Int) -> Location {
		let row = index / 9
		let col = index % 9
		let zone = row/3*3 + col/3
		return Location(row: row, col: col, zone: zone, index: index)
	}

	public static func locationAtZone(zone: Int, indexFromZone: Int) -> Location {
		let row = zone/3*3 + indexFromZone/3
		let col = zone%3*3 + indexFromZone%3
		let index = row*9 + col
		return Location(row: row, col: col, zone: zone, index: index)
	}

	public static func indexesAtZone(zone: Int) -> [Int] {
		var indexes = ArrayUtil.array9(initial: 0)
		var i = 0
		for col in 0...2 {
			for row in 0...2 {
				indexes[i] = ((col + (zone/3)*3) * 9) + (row + (zone%3)*3)
				i += 1
			}
		}
		return indexes
	}

	public static func shuffleNumbers() -> [Int] {
		let shuffleNums: [Int] = Array(0...8).shuffled() // [0, 1, 2, 3, 4, 5, 6, 7, 8].shuffled()
		return shuffleNums
	}
}
