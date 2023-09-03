//
//  ArrayUtil.swift
//  Sudoku
//
//  Created by Andreas Job on 12.08.23.
//

import Foundation

class ArrayUtil {

	private init() {}

	public static func array81<T>(initial: T) -> [T] {
		return array(initial: initial, size: 81)
	}

	public static func array9<T>(initial: T) -> [T] {
		return array(initial: initial, size: 9)
	}

	public static func array<T>(initial: T, size: Int) -> [T] {
		return Array(repeating: initial, count: size)
	}

	static func array9x9<T>(initial: T) -> [[T]] {
		let size = 9
		let arr2: [[T]] = Array(repeating: Array(repeating: initial, count: size), count: size)
		return arr2
	}
}

/*public extension Array where Element == Int  {
	
	static func array81() -> [Int] {
		return Array(repeating: -1, count: 81)
	}
}

public extension Array where Element == Bool  {
	static func array9() -> [Bool] {
		let arr: [Bool] = Array(repeating: false, count: 9)
		return arr
	}

	static func array9x9() -> [[Bool]] {
		let arr1: [[Bool]] = [
			Array(repeating: false, count: 9),
			Array(repeating: false, count: 9),
			Array(repeating: false, count: 9),
			Array(repeating: false, count: 9),
			Array(repeating: false, count: 9),
			Array(repeating: false, count: 9),
			Array(repeating: false, count: 9),
			Array(repeating: false, count: 9)]
		return arr1
	}
}*/
