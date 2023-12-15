//
//  SudokuApp.swift
//  Sudoku
//
//  Created by Andreas Job on 10.04.23.
//

import SwiftUI

@main
struct SudokuApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
		
        WindowGroup {
            /*ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)*/
			MainMenuView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
	
	
}
