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

class NavigationPath: ObservableObject {
	@Published var path: [String] = []
}

struct MainMenuView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \SaveData.savedAt, ascending: false)],
		animation: .default)
	private var data: FetchedResults<SaveData>

	//@State private var navigationPath = NavigationPath()
	//@State private var path: [String] = []

	//@State private var presentMe = false
	@State private var isNavigateToContinue = false

	var body: some View {
		NavigationStack {
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

					let boardData = BoardData(difficulty: .medium)
					/*NavigationLink {
						BoardView(newGame: false)
							.environmentObject(boardData)
					} label: {
						Text("Continue")
							.frame(minWidth: 150, minHeight: 30)
							.padding(.all, 10)
							.border(.black, width: 1)
					}
					.simultaneousGesture(TapGesture().onEnded{
						print("Hello world tap!")
					})
					.simultaneousGesture(LongPressGesture().onEnded {val in
						print("Hello world long press! \(val)")
					})
					.disabled(false)*/
					NavigationLink(destination: EmptyView()) {
						Button {
							// run your code before the navigation to the new view (BoardView)
							Logger.debug("Continue saved game...")
							// then set
							do {
								guard let saveData = data.first else {
									throw SaveDataError.noSaveData
								}

								// build the board data with the loaded savegame
								Logger.debug("Save data: \(saveData)")
								try boardData.generatePuzzle(saveData: saveData)
								boardData.prepareBoard()
								isNavigateToContinue = true
							} catch SaveDataError.invalidData(let details) {
								Logger.error("Cannot continue game because save data has errors. Empty value for \(details)")
							} catch SaveDataError.noSaveData {
								Logger.error("Cannot continue game because no save data exists.")
							} catch {
								Logger.error("Cannot continue game. \(error)")
							}
						} label: {
							Text("Continue")
								.frame(minWidth: 150, minHeight: 30)
								.padding(.all, 10)
								.border(.black, width: 1)
						}.navigationDestination(isPresented: $isNavigateToContinue) {
							BoardView(newGame: false)
								.environmentObject(boardData)
						}
					}
					.disabled(data.isEmpty)

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
		}.onAppear {
			viewContext.refreshAllObjects()
		}
	}
}

struct ColorDetail: View {
	var color: Color

	var body: some View {
		color.navigationTitle(color.description)
	}
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView()
			.environment(\.managedObjectContext, PersistenceController.previewSaveData.container.viewContext)
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
