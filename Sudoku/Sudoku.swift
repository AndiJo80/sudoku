//
//  Sudoku.swift
//  Sudoku
//
//  Created by Andreas Job on 06.08.23.
//

import Foundation

//MARK: class Sudoku
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

	init(puzzle: [Int], answer: [Int]) {
		self.puzzle = puzzle
		self.answer = answer
	}

	private func calculate() throws {
		guard let firstCheckPoint = answer.firstIndex(where: { $0 == -1 }) else {
			return
		}

		if isOneSolutionMode {
			let solved = try dsfOneSolutionCalculate(index: firstCheckPoint)
			if (finishes > 1) {
				throw SudokuError.moreThanOneSolve//("puzzle is not one-solution sudoku")
			}
			if (!solved || answer.contains { $0 == -1 }) {
				throw SudokuError.puzzleCantSolve//("puzzle can't solve")
			}
			/*if (finishes == 0) {
				throw SudokuError.puzzleCantSolve//("puzzle can't solve")
			}*/
			return
		}

		if try !backtrackCalculate(index: firstCheckPoint) {
			throw SudokuError.puzzleCantSolve//("puzzle can't solve")
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

public enum SudokuError: Error {
	 case puzzleCantSolve,
		  moreThanOneSolve
}

public enum SaveDataError: Error {
	case noSaveData,
		 invalidData(String)
}

public struct Location {
	var row: Int
	var col: Int
	var zone: Int
	var index: Int
}

//MARK: class SudokuUtil
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

	public static func indexFor(row: Int, col: Int) -> Int {
		return row * 9 + col
	}

	public static func indexesFor(row: Int) -> [Int] {
		let indicesInRow = (0...8).map { row * 9 + $0 }
		return indicesInRow
	}

	public static func indexesFor(col: Int) -> [Int] {
		let indicesInRow = (0...8).map { $0 * 9 + col }
		return indicesInRow
	}

	public static func shuffleNumbers() -> [Int] {
		let shuffleNums: [Int] = [0, 1, 2, 3, 4, 5, 6, 7, 8].shuffled() // Array(0...8).shuffled()
		return shuffleNums
	}

	public static func convertToString(numberArr: [Int]) -> String {
		let dataString = numberArr.map { ($0 < 0) ? "-" : String($0) }.joined()
		return dataString
	}

	public static func convertToArray(dataString: String) -> [Int] {
		let numberArr = dataString.map { ($0 == "-") ? -1 : ($0.wholeNumberValue ?? -1) }
		return numberArr

		// convert String to [Int]
		// see: https://stackoverflow.com/a/28611698/14952324
		// Swift 5.2 or later can use "Key Path Expressions as Functions"
		//    -> use code \.wholeNumberValue instead of $0.wholeNumberValue
		// more info: https://github.com/apple/swift-evolution/blob/main/proposals/0249-key-path-literal-function-expressions.md
		//let digits = dataString.compactMap(\.wholeNumberValue) // -> digits is Array<Int> -> [1, 2, 3, 4, 5, 6, 7, 8, 9]
	}
}
