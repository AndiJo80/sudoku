//
//  NewGameView.swift
//  Sudoku
//
//  Created by Andreas Job on 17.06.23.
//

import SwiftUI

enum Difficulty {
	case easy, medium, hard, expert, hell
}

struct NewGameView: View {
	@State var difficulty: Difficulty = Difficulty.medium

	var body: some View {
		NavigationView {
			VStack (alignment: .center, spacing: 150) {
				Text("Start New Game")
					.font(.title)

				VStack (alignment: .center, spacing: 20) {
					Text("Difficulty")
						.font(.title)
					HStack(spacing: 10) {
						Button(action: {
							difficulty = .easy
							Logger.debug("difficult is now: \(difficulty)")
						}) {
							Text("Easy")
								.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
								.padding(.all, 10)
								.background((difficulty == .easy) ? Color.selectedButtonColor : Color.clear)
								.border(.black, width: 1)
						}
						Button(action: {
							difficulty = .medium
							Logger.debug("difficult is now: \(difficulty)")
						}) {
							Text("Medium")
								.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
								.padding(.all, 10)
								.background((difficulty == .medium) ? Color.selectedButtonColor : Color.clear)
								.border(.black, width: 1)
						}
					}.padding(.horizontal)
					HStack(spacing: 10) {
						Button(action: {
							difficulty = .hard
							Logger.debug("difficult is now: \(difficulty)")
						}) {
							Text("Hard")
								.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
								.padding(.all, 10)
								.background((difficulty == .hard) ? Color.selectedButtonColor : Color.clear)
								.border(.black, width: 1)
						}
						Button(action: {
							difficulty = .expert
							Logger.debug("difficult is now: \(difficulty)")
						}) {
							Text("Expert")
								.frame(minWidth: 0, maxWidth: .infinity, minHeight: 30)
								.padding(.all, 10)
								.background((difficulty == .expert) ? Color.selectedButtonColor : Color.clear)
								.border(.black, width: 1)
						}
					}.padding(.horizontal)
				}

				Button(action: { Logger.debug("starting new game") }) {
					NavigationLink {
						BoardView(newGame: true)
							.environmentObject(BoardData(difficulty: difficulty))
							//.navigationBarBackButtonHidden(true)
					} label: {
						Text("Start")
							.frame(minWidth: 150, minHeight: 30)
							.padding(.all, 10)
							.border(.black, width: 1)
					}
				}
			}
		}
	}
}

struct NewGameView_Previews: PreviewProvider {
    static var previews: some View {
		NewGameView()
    }
}
