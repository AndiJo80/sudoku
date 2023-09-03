//
//  TimerTestView.swift
//  Sudoku
//
//  Created by Andreas Job on 24.06.23.
//

import SwiftUI

struct ParentView: View {
	@State var isTimerRunning = false
	var body: some View {
		NavigationView {
			VStack {
				NavigationLink("Go", destination: TimerTestView(isTimerRunning: $isTimerRunning))
			}
			.navigationBarHidden(isTimerRunning)
			.navigationBarTitle("Main")      // << required, at least empty !!
		}
	}
}

struct TimerTestView: View {
	@Binding var isTimerRunning: Bool

	var body: some View {
		VStack {
			Button(action:self.startTimer) {
				Text("Start Timer2")
			}.disabled(isTimerRunning)

		}
	}

	func startTimer() {
		self.isTimerRunning = true

		_ = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { timer in
			DispatchQueue.main.async {      // << required !!
				self.isTimerRunning = false
			}
		}
	}
}

struct TimerTestView_Previews: PreviewProvider {
    static var previews: some View {
		ParentView()
    }
}
