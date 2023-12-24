//
//  NewGameView.swift
//  Sudoku
//
//  Created by Andreas Job on 17.06.23.
//

import SwiftUI

enum Difficulty : Int {
	case easy = 0, medium = 1, hard = 2, expert = 3, hell = 4
}

struct NewGameView: View {
	@Environment(\.dismiss) private var dismiss
	@State var difficulty: Difficulty = Difficulty.medium
	var boardData = BoardData(difficulty: .medium)

	var body: some View {
		NavigationStack {
			VStack (alignment: .center, spacing: 150) {
				Text("Start New Game")
					.font(.title)

				VStack (alignment: .center, spacing: 20) {
					//MARK: difficulty buttons
					Text("Difficulty")
						.font(.title)
					HStack(spacing: 10) {
						Button(action: {
							difficulty = .easy
							boardData.difficulty = difficulty
							Logger.debug("difficult is now: \(difficulty)")
						}) {
							Text("Easy")
								.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
								.padding(.all, 10)
								.background((difficulty == .easy) ? Color.selectedButtonColor : Color.clear)
								.border(.foreground, width: 1)
						}
						Button(action: {
							difficulty = .medium
							boardData.difficulty = difficulty
							Logger.debug("difficult is now: \(difficulty)")
						}) {
							Text("Medium")
								.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
								.padding(.all, 10)
								.background((difficulty == .medium) ? Color.selectedButtonColor : Color.clear)
								.border(.foreground, width: 1)
						}
					}.padding(.horizontal, 50)
					HStack(spacing: 10) {
						Button(action: {
							difficulty = .hard
							boardData.difficulty = difficulty
							Logger.debug("difficult is now: \(difficulty)")
						}) {
							Text("Hard")
								.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
								.padding(.all, 10)
								.background((difficulty == .hard) ? Color.selectedButtonColor : Color.clear)
								.border(.foreground, width: 1)
						}
						Button(action: {
							difficulty = .expert
							boardData.difficulty = difficulty
							Logger.debug("difficult is now: \(difficulty)")
						}) {
							Text("Expert")
								.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
								.padding(.all, 10)
								.background((difficulty == .expert) ? Color.selectedButtonColor : Color.clear)
								.border(.foreground, width: 1)
						}
					}.padding(.horizontal, 50)
				}
				//MARK: Start button
				Button(action: { Logger.debug("starting new game") }) {
					NavigationLink {
						BoardView(newGame: true)
							.environmentObject(boardData)
							//.navigationBarBackButtonHidden(true)
							.onDisappear {
								Logger.debug("NewGameView.BoardView.onDisappear triggered.")
								if (boardData.quit) {
									Logger.debug("Value of boardData.quit is true. Dismissing NewGameView.")
									dismiss()
								}
							}
					} label: {
						Text("Start")
							.frame(minWidth: 150, minHeight: 30)
							.padding(.all, 10)
							.border(.foreground, width: 1)
					}
					.onChange(of: boardData.quit, perform: { quit in
						Logger.debug("NewGameView.onChange triggered. Quit changed to: \(boardData.quit)")
						if (quit) {
							dismiss()
						}
					})
				}
			}
		}
	}
}

#Preview {
	NewGameView()
}
