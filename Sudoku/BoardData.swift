//
//  BoardData.swift
//  Sudoku
//
//  Created by Andreas Job on 01.07.23.
//

import Foundation

class BoardData: ObservableObject {
	@Published public var values: [Int]

	public init(difficulty: Difficulty) {
		values = Array(repeating: 0, count: 81)
		for _ in 0...5 {
			values[Int.random(in: 0...80)] = Int.random(in: 0...9)
		}
	}

	public func valueAt(index: Int) -> Int {
		return values[index]
	}

	public func valueAt(row: Int, col: Int) -> Int {
		return values[row * 9 + col]
	}

	
}
