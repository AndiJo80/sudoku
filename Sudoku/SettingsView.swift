//
//  SettingsView.swift
//  Sudoku
//
//  Created by Andreas Job on 25.11.23.
//

import SwiftUI
import CoreData

private enum UserNameValidationError: Error, LocalizedError {
	case noNameEntered

	var errorDescription: String? {
		switch self {
			case .noNameEntered: return "No Name Entered!"
		}
	}
}

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

	@AppStorage("userName") private var userName = "Anonymous"
	@State private var newUserName: String = ""

	@State private var showingChangeUserNameDialog = false
	@State private var showingChangeUserNameErrorAlert: Bool = false
	@State private var showingDeleteHighscoreAlert = false
	@State private var showingDeleteSavegameAlert = false
	private var version: String
	private var build: String
	
	@State private var changeUserNameAlertTitle: String = ""
	@State private var changeUserNameAlertMsg: String = ""

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
					Logger.debug("Pressed on User Name...")
					newUserName = userName
					showingChangeUserNameDialog = true
				} label: {
					Text("User Name: \(userName)").background(Color.clear)
				}
				.padding(10)
				.alert("User Name", isPresented: $showingChangeUserNameDialog) {
					TextField("Enter Name", text: $newUserName).textInputAutocapitalization(.never).autocorrectionDisabled()
					Button("Ok", action: changeUserName)
					Button("Cancel", role: .cancel) { }
				}
				.alert(isPresented: $showingChangeUserNameErrorAlert) {
					Alert(title: Text(changeUserNameAlertTitle), message: Text(changeUserNameAlertMsg), dismissButton: .cancel(Text("Ok")) {
						showingChangeUserNameDialog = true
					})
				}

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

	private func changeUserName() {
		do {
			try validateUserNameForm()
			self.userName = newUserName
		} catch {
			changeUserNameAlertTitle = "Error!"
			changeUserNameAlertMsg = error.localizedDescription
			showingChangeUserNameErrorAlert = true
		}
	}

	private func validateUserNameForm() throws {
		guard !newUserName.isEmpty else {
			throw UserNameValidationError.noNameEntered
		}
	}
}

#Preview {
	SettingsView()
		.environment(\.managedObjectContext, PersistenceController.previewSudokuGameData.container.viewContext)
}
