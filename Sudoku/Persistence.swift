//
//  Persistence.swift
//  Sudoku
//
//  Created by Andreas Job on 10.04.23.
//

import CoreData

struct PersistenceController {
	static let shared = PersistenceController()

	/**
	 * This is only test code and should be deleted.
	 */
	static var previewForContentView: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext
		for _ in 0..<10 {
			let newItem = Item(context: viewContext)
			newItem.timestamp = Date()
		}
		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
		return result
	}()

	/*static var previewSaveData: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext

		let testSudoku = SudokuGenerator.generate(level: .easy)!

		let saveData = SaveData(context: viewContext)
		saveData.values = SudokuUtil.convertToString(numberArr: testSudoku.puzzle)
		saveData.score = 1000
		saveData.puzzle = SudokuUtil.convertToString(numberArr: testSudoku.puzzle)
		saveData.playTime = 10*60 // 10 minutes
		saveData.answer = SudokuUtil.convertToString(numberArr: testSudoku.answer)
		saveData.lifes = 2
		saveData.savedAt = Date.now

		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
		return result
	}()
	
	static var previewHighscore: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext
		
		let highscores = [ "Heinz": 100, "Hugo": 200, "Andreas": 1000, "Dummy": 500 ]
		for (name, score) in highscores {
			let highscoreEntry = HighscoreEntry(context: viewContext)
			highscoreEntry.name = name
			highscoreEntry.score = Int32(score)
		}

		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
		return result
	}()*/
	
	
	static var previewSudokuGameData: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext

		let testSudoku = SudokuGenerator.generate(level: .easy)!
		let saveData = SaveData(context: viewContext)
		saveData.values = SudokuUtil.convertToString(numberArr: testSudoku.puzzle)
		saveData.score = 1000
		saveData.puzzle = SudokuUtil.convertToString(numberArr: testSudoku.puzzle)
		saveData.playTime = 10*60 // 10 minutes
		saveData.answer = SudokuUtil.convertToString(numberArr: testSudoku.answer)
		saveData.lifes = 2
		saveData.savedAt = Date.now

		let highscores = [ "Heinz": 100, "Hugo": 200, "Andreas": 1000, "Dummy": 500 ]
		for (name, score) in highscores {
			let highscoreEntry = HighscoreEntry(context: viewContext)
			highscoreEntry.name = name
			highscoreEntry.score = Int32(score)
		}

		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
		return result
	}()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Sudoku")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
