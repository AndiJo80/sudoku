//
//  MainMenuView.swift
//  Sudoku
//
//  Created by Andreas Job on 14.05.23.
//

import SwiftUI

struct HighscoreEntry {
	var name: String
	var score: Int
	
	init(_ name: String, _ score: Int) {
		self.name = name
		self.score = score
	}
}

fileprivate let highscores = [
	HighscoreEntry("Andi", 100),
	HighscoreEntry("Hugo", 80),
	HighscoreEntry("Egon", 50),
	HighscoreEntry("Dummy", 10)
]

struct MainMenuView: View {
	var body: some View {
		NavigationView {
			VStack (alignment: .center, spacing: 150) {
				Text("Sudoku")
					.font(.title)

				VStack (alignment: .center, spacing: 40) {
					Button(action: {
						Logger.debug("starting new game")
					}) {
						NavigationLink {
							NewGameView()
						} label: {
							Text("New Game")
								.frame(minWidth: 150, minHeight: 30)
								.padding(.all, 10)
								.border(.black, width: 1)
						}
					}

					Button(action: { Logger.debug("continue running game") }) {
						NavigationLink {
							BoardView(newGame: false)
								.environmentObject(BoardData(difficulty: .medium))
						} label: {
							Text("Continue")
								.frame(minWidth: 150, minHeight: 30)
								.padding(.all, 10)
								.border(.black, width: 1)
						}
					}.disabled(false)

					Button(action: { Logger.debug("showing highscore") }) {
						NavigationLink {
							// Highscore View
							VStack(alignment: .center, spacing: 150) {
								Text("Highscore")
									.font(.title)
								
								// render highscore list
								VStack(alignment: .crossAlignment, spacing: 10) {
									HStack() {
										Text("Name").font(NamedFont.headline.font)
										Text("Score").font(NamedFont.headline.font)
											.alignmentGuide(.crossAlignment,
															computeValue: { d in d[HorizontalAlignment.leading] })
									}
									ForEach(0..<highscores.count, id: \.self) { idx in
										HStack() {
											Text(highscores[idx].name)
											Text("\(highscores[idx].score)").alignmentGuide(.crossAlignment,
																							computeValue: { d in d[HorizontalAlignment.leading] })
										}
									}
								}
							}
						} label: {
							Text("Highscore")
								.frame(minWidth: 150, minHeight: 30)
								.padding(.all, 10)
								.border(.black, width: 1)
						}
					}

					Button(action: { Logger.debug("showing settings") }) {
						Text("Settings")
							.frame(minWidth: 150, minHeight: 30)
							.padding(.all, 10)
							.border(.black, width: 1)
					}.disabled(true)
				}
			}
		}
	}
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
    }
}

extension HorizontalAlignment {
	private enum CrossAlignment : AlignmentID {
		static func defaultValue(in d: ViewDimensions) -> CGFloat {
			return d[.leading]
		}
	}
	static let crossAlignment = HorizontalAlignment(CrossAlignment.self)
}
