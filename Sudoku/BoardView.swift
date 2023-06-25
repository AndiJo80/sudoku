//
//  BoardView.swift
//  Sudoku
//
//  Created by Andreas Job on 15.04.23.
//

import SwiftUI

struct Row: View {
	public var borderWidth: CGFloat

	private var quadrants = [Quadrant(border: 1),
							 Quadrant(border: 4),
							 Quadrant(border: 1)]

	@inlinable public init(border width: CGFloat) {
		borderWidth = width
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
	var borderWidth: CGFloat
	@State var value = " "
	@EnvironmentObject private var inputNumbersList: InputNumbersList
	@EnvironmentObject private var clearButton: ClearButton

	@inlinable public init(border: CGFloat, color: Color) {
		borderWidth = border
		foregroundColor = color
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
			Text(value)
				.multilineTextAlignment(.center)
				.padding(5)
				//.border(.red, width: 1)
				.gesture(TapGesture().onEnded { event in  // add tab listener
					onCellTab()
				})
		}
	}

	private func onCellTab() {
		if (clearButton.selected) {
			print("Tapped cell")
			value = ""
		} else if let selected = inputNumbersList.getSelected() {
			print("Tapped cell")
			value = String(selected.id)
		}
	}

	public func setValue(_ newVal: String) {
		value = newVal
	}
}

struct Quadrant: View {
	public var borderWidth: CGFloat

	@inlinable public init(border: CGFloat) {
		borderWidth = border
	}
	//private var cells = Array(repeating: Array(repeating: Cell(border: 1, color: .clear), count: 3), count: 3)
	private var cells = [[Cell(border: 1, color: .clear),
						  Cell(border: 1, color: .clear),
						  Cell(border: 1, color: .clear)],
						 [Cell(border: 1, color: .clear),
						  Cell(border: 1, color: .clear),
						  Cell(border: 1, color: .clear)],
						 [Cell(border: 1, color: .clear),
						  Cell(border: 1, color: .clear),
						  Cell(border: 1, color: .clear)]]

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
		} .border(.black, width: borderWidth)
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

class InputNumber: Identifiable, ObservableObject {
	public var id: Int
	public var bgColor: Color = Color.clear {
		didSet { Logger.debug("new bgColor for InputNumber \(id): \(bgColor)") }
	}
	public var selected = false {
		didSet { if (selected) { Logger.debug("selected InputNumber: \(id)"); bgColor = .blue; } else { bgColor = .clear } }
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
	let board: BoardView

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
	@Published public var bgColor: Color = Color.clear {
		didSet { Logger.debug("new bgColor for clear button: \(bgColor)") }
	}
	@Published public var selected = false {
		didSet { if (selected) { Logger.debug("selected clear button"); bgColor = .blue; } else { bgColor = .clear } }
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
	private var newGame: Bool
	private let rows = [Row(border: 1),
						Row(border: 4),
						Row(border: 1)]

	public func cellAt(row: Int, col: Int) -> Cell? {
		let rowNr = row / 3
		let cellRow = row % 3
		return (rowNr < 3) ? rows[rowNr].cellAt(row: cellRow, col: col) : nil
	}

	@StateObject private var inputNumbersList = InputNumber.getInputNumbersList()
	@StateObject private var clearButton = ClearButton()

	@Environment(\.scenePhase) private var scenePhase

	init(newGame: Bool) {
		self.newGame = newGame
	}

	var body: some View {
		VStack {
			VStack (alignment: .center, spacing: -4) {
				rows[0]
				rows[1]
				rows[2]
			}
			.padding(10)
			.aspectRatio(CGSize(width: 1, height: 1.4), contentMode: .fit)
			.environmentObject(inputNumbersList)
			.environmentObject(clearButton)
			
			HStack {
				ForEach($inputNumbersList.inputNumbersList) { inputNumber in
					InputNumberView(inputNumber: inputNumber, bgColor: inputNumber.bgColor, board: self)
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
		.onAppear(perform: {
			Logger.debug("onAppear triggered")
				for  row in 0...8 {
					for col in 0...8 {
						let cell = cellAt(row: row, col: col)
						if (cell != nil) { print("got cell") }
						cell?.setValue("2")
					}
				}
		})
		.onDisappear(perform: {
			Logger.debug("onDisappear triggered")
		})
		.onChange(of: scenePhase, perform: { value in
			Logger.debug("onChange triggered")
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
	}
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(newGame: true)
    }
}
