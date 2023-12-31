//
//  SudokuApp.swift
//  Sudoku
//
//  Created by Andreas Job on 10.04.23.
//

import SwiftUI

@main
struct SudokuApp: App {
	public static let deviceType: UIUserInterfaceIdiom = UIDevice.current.userInterfaceIdiom

	let persistenceController = PersistenceController.shared
	@AppStorage("userName") private var userName = NSUserName() // "Anonymous"

	public init() {
		if (userName == "") {
			userName = "Anonymous"
		}
		switch SudokuApp.deviceType {
		case .phone:
			Logger.debug("Running on an an iPhone")
		case .pad:
			print("Running on an iPad")
		default:
			print("Running on an unrecognized device type")
		}
	}

	var body: some Scene {
		WindowGroup {
			/*ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)*/
			MainMenuView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}
