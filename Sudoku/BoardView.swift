//
//  BoardView.swift
//  Sudoku
//
//  Created by Andreas Job on 15.04.23.
//

import SwiftUI
import CoreData

//MARK: struct Row
struct Row: View {
	private let rowIdx: Int
	private let borderWidth: CGFloat
	private let quadrants: [Quadrant]
	var parent: BoardView? = nil

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
		}.border(.foreground, width: borderWidth)
	}
}

//MARK: struct Cell
struct Cell: View {
	@State var backgroundColor: Color = Color.clear
	private let borderWidth: CGFloat
	private let cellIdx: Int // global quadrant number 0-81
	@State var cellText = " "

	@EnvironmentObject private var inputNumbersList: InputNumbersList
	@EnvironmentObject private var clearButton: ClearButton
	@EnvironmentObject private var boardData: BoardData

	@inlinable public init(cellIdx: Int, border: CGFloat, color: Color) {
		borderWidth = border
		self.cellIdx = cellIdx
	}

	private var cellCanvas = Rectangle()

	var body: some View {
		ZStack(alignment: .center) {
			cellCanvas
				.foregroundColor(.clear)
				.border(.foreground, width: borderWidth)
				.background(boardData.bgColors[cellIdx])
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

	//MARK: onCellTab() event handler - old
	private func onCellTab() {
		boardData.selectedCellIdx = cellIdx
		boardData.updateBgColors()
	}

	public func setValue(_ newVal: String) {
		cellText = newVal
	}
}

//MARK: struct Quadrant
struct Quadrant: View {
	private let quadrantIdx: Int // global quadrant number 0-9
	private var borderWidth: CGFloat
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
	}

	public func cellAt(row: Int, col: Int) -> Cell? {
		//Logger.entering("cellAt()", row, col)
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
		}.border(.foreground, width: borderWidth)
	}
}

//MARK: class InputNumbersList
class InputNumbersList: ObservableObject {
	@Published var inputNumbersList : [InputNumber]

	init(inputNumbersList: [InputNumber]) {
		self.inputNumbersList = inputNumbersList
	}
}

//MARK: class InputNumber
class InputNumber: Identifiable {
	public var id: Int
	public var bgColor: Color = Color.clear /* ---debug code--- {
		didSet { Logger.debug("new bgColor for InputNumber \(id): \(bgColor)") }
	}*/

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

//MARK: struct InputNumberView
private struct InputNumberView: View {
	@Binding var inputNumber: InputNumber
	@Binding var bgColor: Color
	@EnvironmentObject var inputNumbersList: InputNumbersList
	@EnvironmentObject var clearButton: ClearButton
	@EnvironmentObject private var boardData: BoardData

	var body: some View {
		Text(String(inputNumber.id))
			.padding(10)
			.aspectRatio(CGSize(width: 1, height: 1.5), contentMode: .fit)
			.border(.foreground, width: 1)
			.gesture(TapGesture().onEnded { event in  // add tab listener
				if (boardData.countOccurences(of: inputNumber.id) >= 9) {
					Logger.debug("Do not allow to select \(inputNumber.id)")
					return
				}
				Logger.debug("Tapped \(inputNumber.id)")
				onInputNumberTab()
			})
			.background(bgColor)
			.padding(.horizontal, 1)
			.foregroundStyle((boardData.countOccurences(of: inputNumber.id) < 9) ? Color.primary : Color.gray)
			.onChange(of: boardData.score, perform: { _ in
				if (boardData.countOccurences(of: inputNumber.id) >= 9) {
					bgColor = .clear
				}
			})
	}

	private func onInputNumberTab() {
		let cellIdx = boardData.selectedCellIdx
		if (cellIdx < 0 || cellIdx > 80) {
			Logger.debug("No cell selected.")
			return;
		}
		if (!boardData.canChange(index: cellIdx)) {
			Logger.debug("The value in this cell is part of the initial puzzle and you cannot change it.")
			return
		}

		Logger.debug("Tapped input number \(inputNumber.id) with cell \(cellIdx) selected")
		let newBoardValue = inputNumber.id
		let oldBoardValue = boardData.values[cellIdx]
		let oldValueWasCorrect = boardData.isCorrectValue(index: cellIdx)
		boardData.values[cellIdx] = newBoardValue;
		Logger.debug("old cell value: \(oldBoardValue)")

		boardData.updateBgColors()

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

//MARK: class ClearButton
class ClearButton: ObservableObject {
	@Published public var bgColor: Color = Color.clear /* ---debug code--- {
		didSet { Logger.debug("new bgColor for clear button: \(bgColor)") }
	}*/
}

//MARK: struct ClearButtonView
private struct ClearButtonView: View {
	@EnvironmentObject var clearButton: ClearButton
	@EnvironmentObject var inputNumbersList: InputNumbersList
	@EnvironmentObject var boardData: BoardData

	var body: some View {
		Text("Clear")
			.padding(10)
			.aspectRatio(CGSize(width: 1, height: 1.5), contentMode: .fit)
			.border(.foreground, width: 1)
			.gesture(TapGesture().onEnded { event in  // add tab listener
				print("Tapped Clear")
				onClearButtonTab()
			})
			.background(clearButton.bgColor)
	}

	//MARK: onClearButtonTab() event handler
	private func onClearButtonTab() {
		let cellIdx = boardData.selectedCellIdx
		if (cellIdx < 0 || cellIdx > 80) {
			Logger.debug("No cell selected.")
			return;
		}
		if (!boardData.canChange(index: cellIdx)) {
			Logger.debug("The value in this cell is part of the initial puzzle and you cannot change it.")
			return
		}

		// decrease score if clearing a cell with a correct value
		if (boardData.isCorrectValue(index: cellIdx)) {
			boardData.score -= 100
			Logger.debug("decreasing score to \(boardData.score)")
		}

		boardData.values[cellIdx] = -1
		boardData.validate()

		boardData.updateBgColors()
	 }
}

//MARK: struct BoardView
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

	public func cellAt(index: Int) -> Cell? {
		let cellLocation = SudokuUtil.location(index: index)
		return cellAt(row: cellLocation.row, col: cellLocation.col)
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
	@AppStorage("userName") private var userName = "Anonymous"

	private(set) static var instance: BoardView? = nil

	init(newGame: Bool) {
		self.newGame = newGame
		/*self.rows = [Row(rowIdx: 0, border: 1, parent: self),
					Row(rowIdx: 1, border: 4, parent: self),
					Row(rowIdx: 2, border: 1, parent: self)]*/
		BoardView.instance = self
	}

	private func deleteSaveGame() {
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
	}

	/*
	 * Save the game
	 */
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

	/*
	 * Save highscore list. Make sure that there are max. 10 entries in the list.
	 */
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

		// do before return - save changes to persistence
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
				rows[0].zIndex(0)
				rows[1].zIndex(1) // Top layer.
				rows[2].zIndex(0)
			}
			.padding(10)
			.aspectRatio(CGSize(width: 1, height: 1.4), contentMode: .fit)
			.environmentObject(inputNumbersList)
			.environmentObject(clearButton)
			//.environmentObject(boardData)

			HStack {
				ForEach($inputNumbersList.inputNumbersList) { inputNumber in
					InputNumberView(inputNumber: inputNumber, bgColor: inputNumber.bgColor)
						.environmentObject(inputNumbersList)
						.environmentObject(clearButton)
						//.environmentObject(boardData)
				}
			}.padding(.horizontal, 0)

			ClearButtonView()
				.environmentObject(inputNumbersList)
				.environmentObject(clearButton)
				//.environmentObject(boardData)

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
			//MARK: prepare boardData to play the game
			Logger.debug("BoardView.onAppear triggered")
			for var row in rows {
				row.parent = self
			}
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
				saveHighScore(name: userName)
			}
		})
		.onChange(of: boardData.score, perform: { score in
			Logger.debug("BoardView.onChange triggered. Score changed to: \(score)")
			if (boardData.isSolved()) {
				gameWon = true
			}
		})
		.alert("Game Over", isPresented: $gameOver) {
			Button("OK") {
				// delete old save data
				deleteSaveGame()

				boardData.quit = true
				//self.presentationMode.wrappedValue.dismiss()
				dismiss()
			}
		} message: {
			Text("You lost all lifes. Final Score is: \(boardData.score)")
		}
		.alert("Game Won", isPresented: $gameWon) {
			Button("OK") {
				// delete old save data
				deleteSaveGame()

				// save highscore
				saveHighScore(name: userName)

				boardData.quit = true
				//self.presentationMode.wrappedValue.dismiss()
				dismiss()
			}
		} message: {
			Text("Congratulations. You solved the puzzle. Final Score is: \(boardData.score)")
		}
	}
}

#Preview {
	BoardView(newGame: true)
		.environmentObject(BoardData(difficulty: .medium))
		.environment(\.managedObjectContext, PersistenceController.previewSudokuGameData.container.viewContext)
}
