//
//  SudokuGenerator.swift
//  Sudoku
//
//  Created by Andreas Job on 13.08.23.
//

import Foundation

enum Holes: Int {
	case CONST_EASY_HOLES = 40,
	CONST_MEDIUM_HOLES = 45,
	CONST_HARD_HOLES = 50,
	CONST_EXPERT_HOLES = 56,
	// ⚠️ hell is really hard and very consumptive performance ⚠️
	CONST_HELL_HOLES = 60
}

/*
 * Generate a Sudoku puzzle according to the difficulty
 */
class SudokuGenerator {

	private init() {}

	public static func generate(level: Difficulty) -> Sudoku? {
		var maxHoles = Holes.CONST_EASY_HOLES;
		switch (level) {
		case .easy:
			maxHoles = Holes.CONST_EASY_HOLES
		case .medium:
			maxHoles = Holes.CONST_MEDIUM_HOLES
		case .hard:
			maxHoles = Holes.CONST_HARD_HOLES
		case .expert:
			maxHoles = Holes.CONST_EXPERT_HOLES
		case .hell:
			maxHoles = Holes.CONST_HELL_HOLES
		}

		do {
			let basicSudoku = try Sudoku(puzzle: generateSimplePuzzle())
			//Logger.debug("basic sudoku: \(basicSudoku.puzzle)")
			Logger.debug("Basic sudoku and answer generated.")

			// the dig hole process 
			var maxDigHoleProcessTimes = 3
			var resultSudoku: Sudoku? = nil
			Logger.debug("Digging \(maxHoles.rawValue) holes...")
			repeat {
				resultSudoku = digHoles(basicSudoku: basicSudoku, holes: maxHoles.rawValue)
				maxDigHoleProcessTimes -= 1
			} while (resultSudoku == nil && maxDigHoleProcessTimes > 0)

			Logger.debug("Returning result sudoku: \(resultSudoku?.puzzle ?? [0])")
			return resultSudoku
		} catch SudokuError.moreThanOneSolve {
			Logger.error("Cannot generate Sudoku. Puzzle is not one-solution sudoku (has more than 1 solutions).")
		} catch SudokuError.puzzleCantSolve {
			Logger.error("Cannot generate Sudoku. Puzzle can't solve")
		} catch {
			Logger.error("Cannot generate Sudoku. \(error)")
		}
		return nil
	}

	private static func generateSimplePuzzle() -> [Int] {
		var data = ArrayUtil.array81(initial: -1);
		let nums = SudokuUtil.shuffleNumbers()
		var i = 0
		for col in 3...5 {
			for row in 3...5 {
				data[row*9 + col] = nums[i] + 1
				i += 1
			}
		}
		return data;
	}

	private static func digHoles(basicSudoku: Sudoku, holes digHoleTotal: Int) -> Sudoku? {
		var puzzle = basicSudoku.solution
		var holeCounter = 0
		let candidateHoles = randCandidateHoles()
		for holeIndex in candidateHoles {
			holeCounter += 1
			let old = puzzle[holeIndex]
			puzzle[holeIndex] = -1
			let resultSudoku = sudokuVerifyWithDfs(puzzle: puzzle)
			if resultSudoku == nil {
				puzzle[holeIndex] = old
				holeCounter -= 1
			}

			if (holeCounter >= digHoleTotal && resultSudoku != nil) {
				return resultSudoku
			}
		}
		return nil
	}

	private static func randCandidateHoles() -> [Int] {
		var arr = Array(0..<81)

		// make sure each zone must have one cell to fixed
		// need calculate random index on each zone , and sort them
		var fixedPositionByZones = Array(0...8)
		fixedPositionByZones.enumerated().forEach { i, zone in
			let randomLocation = SudokuUtil.locationAtZone(zone: zone, indexFromZone: Int.random(in: 0...8))
			fixedPositionByZones[i] = randomLocation.index
		}
		// remove fixed positions from hole candidates
		fixedPositionByZones.enumerated().forEach { i, fixedPosition in
			arr.remove(at: fixedPosition - i)
		}

		arr = arr.shuffled()
		return arr
	}

	private static func sudokuVerifyWithDfs(puzzle: [Int]) -> Sudoku? {
		let validSudoku = try? Sudoku(puzzle: puzzle, strict: true)
		return validSudoku
	}
}
