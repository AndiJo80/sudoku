//
//  Timer.swift
//  Sudoku
//
//  Created by Andreas Job on 23.12.23.
//

import Foundation

class TimerData: ObservableObject {
	@Published var timerValue: Int = 0
	var timer: Timer? = nil

	init() {
	}

	func startTimer() {
		if timer == nil {
			timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
		}
	}

	func stopTimer() {
		if let timer = timer {
			timer.invalidate()
			self.timer = nil
		}
	}

	@objc func updateData() {
		// Code here to keep data up to date
		timerValue = timerValue + 1
	}
}

public func formatTime(seconds: Int) -> String {
	let min: Int = seconds / 60
	let sec: Int = seconds % 60
	if (min == 0) {
		return "\(sec)s"
	}
	return "\(min)m  \(sec)s"
}
