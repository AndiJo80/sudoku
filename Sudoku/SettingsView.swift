//
//  SettingsView.swift
//  Sudoku
//
//  Created by Andreas Job on 25.11.23.
//

import SwiftUI
import CoreData

struct SettingsView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \SaveData.savedAt, ascending: false)],
		animation: .default)
	private var savegameData: FetchedResults<SaveData>
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \HighscoreEntry.score, ascending: false)],
		animation: .default)
	private var highscore: FetchedResults<HighscoreEntry>

	@State private var showingDeleteHighscoreAlert = false
	@State private var showingDeleteSavegameAlert = false
	private var version: String
	private var build: String

	init() {
		let dictionary = Bundle.main.infoDictionary!
		version = dictionary["CFBundleShortVersionString"] as! String
		build = dictionary["CFBundleVersion"] as! String
		Logger.debug("version: \(version) build: \(build)")
	}

	var body: some View {
		VStack(alignment: .trailing, spacing: 5) {
			List {
				// --- button Reset Highscore ---
				Button {
					Logger.debug("Pressed on Reset Highscore...")
					showingDeleteHighscoreAlert = true
				} label: {
					Text("Reset Highscore").background(Color.clear)
				}
				.disabled(highscore.isEmpty)
				.background(in: .rect(cornerSize: CGSize(width: 5, height: 5), style: .circular))
				.padding(10)
				.alert("Reset Highscore", isPresented: $showingDeleteHighscoreAlert) {
					Button("Yes") {
						Logger.debug("yes pressed on Reset Highscore dialog")
						do {
							for d in highscore {
								viewContext.delete(d)
							}
							try viewContext.save()
						} catch {
							// Replace this implementation with code to handle the error appropriately.
							// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
							let nsError = error as NSError
							Logger.error("Cannot delete highscore: \(nsError), \(nsError.userInfo)")
						}
					}
					Button("No") {
						Logger.debug("no pressed on Reset Highscore dialog")
					}
				} message: {
					Text("Do you want to reset the highscore list?")
				}
				
				// --- button Delete Savegame ---
				Button {
					Logger.debug("Pressed on Delete Savegame...")
					showingDeleteSavegameAlert = true
				} label: {
					Text("Delete Savegame").background(Color.clear)
				}
				.disabled(savegameData.isEmpty)
				.background(in: .rect(cornerSize: CGSize(width: 5, height: 5), style: .circular))
				.padding(10)
				.alert("Delete Saved Game", isPresented: $showingDeleteSavegameAlert) {
					Button("Yes") {
						Logger.debug("yes pressed on Delete Savegame dialog")
						do {
							for d in savegameData {
								viewContext.delete(d)
							}
							try viewContext.save()
						} catch {
							// Replace this implementation with code to handle the error appropriately.
							// fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
							let nsError = error as NSError
							Logger.error("Cannot delete savegame: \(nsError), \(nsError.userInfo)")
						}
					}
					Button("No") {
						Logger.debug("no pressed on Delete Savegame dialog")
					}
				} message: {
					Text("Do you want to delete the saved game?")
				}
			}
			Text("Version: \(version)")
				.alignmentGuide(HorizontalAlignment.trailing) { d in return d[.trailing] + 20 }
		}
	}
}

#Preview {
	SettingsView()
		.environment(\.managedObjectContext, PersistenceController.previewSudokuGameData.container.viewContext)
}
