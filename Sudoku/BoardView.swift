//
//  BoardView.swift
//  Sudoku
//
//  Created by Andreas Job on 15.04.23.
//

import SwiftUI
import CoreData

struct Row: View {
	private let rowIdx: Int
	private let borderWidth: CGFloat
	private let quadrants: [Quadrant]

	@inlinable public init(rowIdx: Int, border width: CGFloat) {
		self.rowIdx = rowIdx
		borderWidth = width

		quadrants = [Quadrant(quadrantIdx: 3 * rowIdx + 0, border: 1),
					 Quadrant(quadrantIdx: 3 * rowIdx + 1, border: 4),
					 Quadrant(quadrantIdx: 3 * rowIdx + 2, border: 1)]
	}

	public func cellAt(row: Int, col: Int) -> Cell? {
		let quadrantNr = col / 3
		let quadrantCol = col % 3
		return (quadrantNr < 3) ? quadrants[quadrantNr].cellAt(row: row, col: quadrantCol) : nil
	}

	var body: some View {
		HStack (alignment: .center, spacing: 0) {
			quadrants[0]
			quadrants[1]
			quadrants[2]
		}.border(.black, width: borderWidth)
	}
}

struct Cell: View {
	var foregroundColor: Color
	private let borderWidth: CGFloat
	private let cellIdx: Int // global quadrant number 0-81
	@State var cellText = " "
	@EnvironmentObject private var inputNumbersList: InputNumbersList
	@EnvironmentObject private var clearButton: ClearButton
	@EnvironmentObject private var boardData: BoardData

	@inlinable public init(cellIdx: Int, border: CGFloat, color: Color) {
		borderWidth = border
		foregroundColor = color
		self.cellIdx = cellIdx
	}

	private var cellCanvas = Rectangle()

	var body: some View {
		ZStack(alignment: .center) {
			cellCanvas
				.foregroundColor(foregroundColor)
				.border(.black, width: borderWidth)
				.gesture(TapGesture().onEnded { event in  // add tab listener
					onCellTab()
				})
			Text(cellText)
				.multilineTextAlignment(.center)
				.padding(5)
				//.border(.red, width: 1)
				.gesture(TapGesture().onEnded { event in  // add tab listener
					onCellTab()
				})
				.foregroundColor(boardData.colors[cellIdx])
		}
		.onAppear(perform: fillCellFromBoardData)
		.onChange(of: boardData.values, perform: { _ in fillCellFromBoardData() })
	}

	private func fillCellFromBoardData() {
		let boardDataValue = boardData.valueAt(index: cellIdx)
		cellText = (boardDataValue > 0) ? String(boardDataValue) : " "
	}

	private func onCellTab() {
		if (!boardData.canChange(index: cellIdx)) {
			Logger.debug("The value in this cell is part of the initial puzzle and you cannot change it.")
			return
		}

		if (clearButton.selected) {
			Logger.debug("Tapped cell \(cellIdx) with Clear selected")
			Logger.debug("old cell value: \(cellText)")

			// decrease score if clearing a cell with a correct value
			if (boardData.isCorrectValue(index: cellIdx)) {
				boardData.score -= 100
				Logger.debug("decreasing score to \(boardData.score)")
			}

			cellText = " "
			boardData.values[cellIdx] = -1;
			boardData.validate()
		} else if let selected = inputNumbersList.getSelected() {
			Logger.debug("Tapped cell \(cellIdx) with \(selected.id) selected")
			Logger.debug("old cell value: \(cellText)")
			let newBoardValue = selected.id
			cellText = String(newBoardValue)
			let oldBoardValue = boardData.values[cellIdx]
			let oldValueWasCorrect = boardData.isCorrectValue(index: cellIdx)
			boardData.values[cellIdx] = newBoardValue;
			
			if (oldBoardValue != newBoardValue) {
				if (boardData.isCorrectValue(index: cellIdx)) {
					// increase score if the cell now has a correct value
					boardData.score += 100
					Logger.debug("increasing score to \(boardData.score)")
				} else if (oldValueWasCorrect) {
					// a correct value (green) was replaced with a wrong value (red) -> decrease score
					boardData.score -= 100
					Logger.debug("decreasing score to \(boardData.score)")
				}
			}

			let isValid = boardData.validate()
			var solved = false
			if (isValid) {
				Logger.debug("Puzzle is valid")
				// check if puzzle is solved
				solved = boardData.isSolved()
				if (solved) {
					// calculate final score before ending the game
					boardData.score += 1000 * (1 + boardData.difficulty.rawValue) + boardData.lifes * 500
					Logger.debug("Solved. Increasing score to \(boardData.score)")
				}
			} else {
				Logger.debug("Puzzle is not valid")

				if (newBoardValue != boardData.answerAt(index: cellIdx)) {
					boardData.lifes = boardData.lifes - 1
				}
			}
			Logger.debug("Solved: \(solved)")
		}
	}

	public func setValue(_ newVal: String) {
		cellText = newVal
	}
}

struct Quadrant: View {
	private let quadrantIdx: Int // global quadrant number 0-9
	private var borderWidth: CGFloat

	//private let cells = Array(repeating: Array(repeating: Cell(border: 1, color: .clear), count: 3), count: 3)
	private let cells: [[Cell]]

	@inlinable public init(quadrantIdx: Int, border: CGFloat) {
		self.quadrantIdx = quadrantIdx
		borderWidth = border

		// create cells in this quadrant. need to calculate global index for each cell
		var cells: [[Cell]] = []
		let quadrantRow: Int = quadrantIdx / 3
		let quadrantCol: Int = quadrantIdx % 3
		for cellRow in 0...2 {
			var rowCells: [Cell] = []
			for cellCol in 0...2 {
				let cellIdx = quadrantRow *  27 + quadrantCol * 3 + cellRow * 9 + cellCol
				let newCell: Cell = Cell(cellIdx: cellIdx, border: 1, color: .clear)
				rowCells.append(newCell)
			}
			cells.append(rowCells)
		}
		self.cells = cells

		/*cells = [[Cell(cellIdx: 0, border: 1, color: .clear),
				  Cell(cellIdx: 0, border: 1, color: .clear),
				  Cell(cellIdx: 0, border: 1, color: .clear)],
				 [Cell(cellIdx: 0, border: 1, color: .clear),
				  Cell(cellIdx: 0, border: 1, color: .clear),
				  Cell(cellIdx: 0, border: 1, color: .clear)],
				 [Cell(cellIdx: 0, border: 1, color: .clear),
				  Cell(cellIdx: 0, border: 1, color: .clear),
				  Cell(cellIdx: 0, border: 1, color: .clear)]]*/
	}

	public func cellAt(row: Int, col: Int) -> Cell? {
		Logger.entering("cellAt()", row, col)
		return (row < 3 && col < 3) ? cells[row][col] : nil
	}

	var body: some View {
		VStack (alignment: .center, spacing: -1) {
			HStack (alignment: .center, spacing: -1) {
				cells[0][0]
				cells[0][1]
				cells[0][2]
			}
			HStack (alignment: .center, spacing: -1) {
				cells[1][0]
				cells[1][1]
				cells[1][2]
			}
			HStack (alignment: .center, spacing: -1) {
				cells[2][0]
				cells[2][1]
				cells[2][2]
			}
		}.border(.black, width: borderWidth)
	}
}

class InputNumbersList: ObservableObject {
	@Published var inputNumbersList : [InputNumber]

	init(inputNumbersList: [InputNumber]) {
		self.inputNumbersList = inputNumbersList
	}

	public func getSelected() -> InputNumber? {
		return inputNumbersList.first {
			$0.selected
		}
	}
}

class InputNumber: Identifiable {
	public var id: Int
	public var bgColor: Color = Color.clear /* ---debug code--- {
		didSet { Logger.debug("new bgColor for InputNumber \(id): \(bgColor)") }
	}*/
	public var selected = false {
		didSet { if (selected) { /* ---debug code--- Logger.debug("selected InputNumber: \(id)");*/ bgColor = .blue; } else { bgColor = .clear } }
	}

	init(_ id: Int) {
		self.id = id
	}

	static func getInputNumbersList() -> InputNumbersList {
		return InputNumbersList(inputNumbersList: [
			InputNumber(1),
			InputNumber(2),
			InputNumber(3),
			InputNumber(4),
			InputNumber(5),
			InputNumber(6),
			InputNumber(7),
			InputNumber(8),
			InputNumber(9)
		])
	}
}

private struct InputNumberView: View {
	@Binding var inputNumber: InputNumber
	@Binding var bgColor: Color
	@EnvironmentObject var inputNumbersList: InputNumbersList
	@EnvironmentObject var clearButton: ClearButton
	//let board: BoardView

	var body: some View {
		Text(String(inputNumber.id))
			.padding(10)
			.aspectRatio(CGSize(width: 1, height: 1.5), contentMode: .fit)
			.border(.black, width: 1)
			.gesture(TapGesture().onEnded { event in  // add tab listener
				print("Tapped \(inputNumber.id)")
				for inputNumber in inputNumbersList.inputNumbersList {
					inputNumber.selected = (inputNumber.id == self.inputNumber.id)
				}
				clearButton.selected = false
			})
			.background(bgColor)
	}
}

class ClearButton: ObservableObject {
	@Published public var bgColor: Color = Color.clear /* ---debug code--- {
		didSet { Logger.debug("new bgColor for clear button: \(bgColor)") }
	}*/
	@Published public var selected = false {
		didSet { if (selected) { /* ---debug code--- Logger.debug("selected clear button");*/ bgColor = .blue; } else { bgColor = .clear } }
	}
}

private struct ClearButtonView: View {
	@EnvironmentObject var clearButton: ClearButton
	@EnvironmentObject var inputNumbersList: InputNumbersList

	var body: some View {
		Text("Clear")
			.padding(10)
			.aspectRatio(CGSize(width: 1, height: 1.5), contentMode: .fit)
			.border(.black, width: 1)
			.gesture(TapGesture().onEnded { event in  // add tab listener
				print("Tapped Clear")
				for inputNumber in inputNumbersList.inputNumbersList {
					inputNumber.bgColor = .clear
					inputNumber.selected = false
				}
				clearButton.selected = true
				clearButton.bgColor = .blue
			})
			.background(clearButton.bgColor)
	}
}

struct BoardView: View {
	//let dismiss: DismissAction
	private var newGame: Bool
	private let rows = [Row(rowIdx: 0, border: 1),
						Row(rowIdx: 1, border: 4),
						Row(rowIdx: 2, border: 1)]

	public func cellAt(row: Int, col: Int) -> Cell? {
		let rowNr = row / 3
		let cellRow = row % 3
		return (rowNr < 3) ? rows[rowNr].cellAt(row: cellRow, col: col) : nil
	}

	@StateObject private var inputNumbersList = InputNumber.getInputNumbersList()
	@StateObject private var clearButton = ClearButton()
	@EnvironmentObject private var boardData: BoardData
	@State private var gameOver = false
	@State private var showingSaveQuitAlert = false
	@State private var gameWon = false

	@Environment(\.scenePhase) private var scenePhase
	//@Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
	@Environment(\.dismiss) private var dismiss
	@Environment(\.managedObjectContext) private var viewContext

	init(newGame: Bool) {
		self.newGame = newGame
	}

	private func saveGame() {
		if let oldSaveData = try? viewContext.fetch(NSFetchRequest<SaveData>(entityName: SaveData.entity().managedObjectClassName)) {
			for d in oldSaveData {
				viewContext.delete(d)
			}
		}

		let saveData = SaveData(context: viewContext)
		saveData.values = SudokuUtil.convertToString(numberArr: boardData.values)
		saveData.score = 1000
		saveData.puzzle = SudokuUtil.convertToString(numberArr: boardData.sudoku!.puzzle)
		saveData.playTime = 10*60 // 10 minutes
		saveData.answer = SudokuUtil.convertToString(numberArr: boardData.sudoku!.answer)
		saveData.lifes = Int32(boardData.lifes)
		saveData.score = Int32(boardData.score)
		saveData.savedAt = Date.now
		saveData.difficulty = Int16(boardData.difficulty.rawValue)

		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			Logger.error("Cannot save game: \(nsError), \(nsError.userInfo)")
		}
	}

	private func saveHighScore(name: String? = nil) {
		let score = boardData.score
		Logger.entering("saveHighScore()", score, name)
		if (score <= 0) {
			Logger.debug("Don't add highscore entry, since score is \(score).")
			return
		}

		var playerName = name
		if (playerName == nil) {
			playerName = NSUserName();
		}
		if (playerName == nil || playerName!.isEmpty) {
			playerName = "Anonymous"
		}

		// do before return
		defer {
			do {
				if (viewContext.hasChanges) {
					Logger.debug("Saving changes to highscore list.")
					try viewContext.save()
				} else {
					Logger.debug("Do not have to save highscore list because there are no changes.")
				}
			} catch {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
				let nsError = error as NSError
				Logger.error("Cannot save highscore: \(nsError), \(nsError.userInfo)")
			}
		}

		// only keep 10 highscore entries with highest score
		let fetchRequest = NSFetchRequest<HighscoreEntry>(entityName: HighscoreEntry.entity().managedObjectClassName)
		fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \HighscoreEntry.score, ascending: false)]
		//let c = try? viewContext.count(for: fetchRequest)
		if var highscore = try? viewContext.fetch(fetchRequest) {
			Logger.debug("found \(highscore.count) highscore entries")
			while (highscore.count > 10) { // limit to 10 entries
				Logger.debug("Deleting surplus highscore entry.")
				viewContext.delete(highscore.removeLast())
			}
			if (highscore.count == 10) {
				if (highscore.last!.score < score) { // if new score is higher than lowest score in list, then delete the lowest score
					Logger.debug("Deleting lowest highscore entry.")
					viewContext.delete(highscore.last!)
				} else {
					return // we didn't reach a new highscore and the list is already full -> do not save a new entry
				}
			}
		}

		Logger.debug("Adding new highscore entry with name: \(playerName ?? "<nil>"), score: \(score)")
		let highScoreEntry = HighscoreEntry(context: viewContext)
		highScoreEntry.name = playerName
		highScoreEntry.score = Int32(score)

		
	}

	var body: some View {
		VStack {
			HStack(spacing: 10) {
				Text("Lives: \(boardData.lifes)")
				Text("Score: \(boardData.score)")
			}
			VStack (alignment: .center, spacing: -4) {
				rows[0]
				rows[1]
				rows[2]
			}
			.padding(10)
			.aspectRatio(CGSize(width: 1, height: 1.4), contentMode: .fit)
			.environmentObject(inputNumbersList)
			.environmentObject(clearButton)
			.environmentObject(boardData)

			HStack {
				ForEach($inputNumbersList.inputNumbersList) { inputNumber in
					InputNumberView(inputNumber: inputNumber, bgColor: inputNumber.bgColor)
						.environmentObject(inputNumbersList)
						.environmentObject(clearButton)
				}
			}.padding(.horizontal, 10)

			ClearButtonView()
				.environmentObject(inputNumbersList)
				.environmentObject(clearButton)

			/*ForEach(Array(NamedFont.namedFonts.values)) { namedFont in
			 Text(namedFont.name)
			 .font(namedFont.font)
			 }*/
		}
		.toolbar(content: {
			Button(action: {
				Logger.debug("pressed on toolbar button Save&Quit")
				showingSaveQuitAlert = true
			}) {
				Text("Save&Quit")
			}
			.alert("Save & Quit", isPresented: $showingSaveQuitAlert) {
				Button("Yes") {
					Logger.debug("yes pressed on Save&Quit dialog")

					saveGame();

					boardData.quit = true
					dismiss()
				}
				Button("No") {
					Logger.debug("no pressed on Save&Quit dialog")
				}
			} message: {
				Text("Save and return to Main Menu? You can continue this game later.")
			}
		})
		.onAppear(perform: {
			Logger.debug("BoardView.onAppear triggered")
			if (newGame) {
				boardData.resetBoard()
				boardData.generatePuzzle()
			}
			boardData.prepareBoard()
		})
		.onDisappear(perform: {
			Logger.debug("BoardView.onDisappear triggered")
		})
		.onChange(of: scenePhase, perform: { scenePhaseValue in // DEBUG code to try out stuff
			Logger.debug("BoardView.onChange triggered. scenePhase changed to \(scenePhase)")
			switch scenePhase {
				case .active:
					print("Active")
				case .inactive:
					print("Inactive")
				case .background:
					print("Background")
				default:
					print("Unknown scenephase")
			}
		})
		.onChange(of: boardData.lifes, perform: { lifes in
			Logger.debug("BoardView.onChange triggered. Lifes changed to: \(lifes)")
			if (lifes <= 0) {
				gameOver = true
				saveHighScore()
			}
		})

		.onChange(of: boardData.score, perform: { score in
			Logger.debug("BoardView.onChange triggered. Score changed to: \(score)")
			if (boardData.isSolved()) {
				gameWon = true
				saveHighScore()
			}
		})
		.alert("Game Over", isPresented: $gameOver) {
			Button("OK") {
				// delete old save data
				if let oldSaveData = try? viewContext.fetch(NSFetchRequest<SaveData>(entityName: SaveData.entity().managedObjectClassName)) {
					for d in oldSaveData {
						viewContext.delete(d)
					}
					do {
						try viewContext.save()
					} catch {
						// Replace this implementation with code to handle the error appropriately.
						// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
						let nsError = error as NSError
						Logger.error("Cannot save game: \(nsError), \(nsError.userInfo)")
					}
				}

				boardData.quit = true
				//self.presentationMode.wrappedValue.dismiss()
				dismiss()
			}
		} message: {
			Text("You lost all lifes. Final Score is: \(boardData.score)")
		}
		.alert("Game Won", isPresented: $gameWon) {
			Button("OK") {
				boardData.quit = true
				//self.presentationMode.wrappedValue.dismiss()
				dismiss()
			}
		} message: {
			Text("Congratulations. You solved the puzzle. Final Score is: \(boardData.score)")
		}
	}
}

struct BoardView_Previews: PreviewProvider {
	static var previews: some View {
		BoardView(newGame: true)
			.environmentObject(BoardData(difficulty: .medium))
			.environment(\.managedObjectContext, PersistenceController.previewSudokuGameData.container.viewContext)
	}
}
