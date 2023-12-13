//
//  SwiftUIInputAlert.swift
//  Sudoku
//
//  Created by Andreas Job on 10.12.23.
//

import SwiftUI

import SwiftUI

struct SwiftUIInputAlert: View {
	
	@State var name: String?
	@State var jobTitle: String?
	
	@State private var isInputAlertShown = false
	@State private var newName: String = ""
	@State private var newJobTitle: String = ""
	@State private var isErrorAlertShown: Bool = false
	@State private var alertTitle: String = ""
	@State private var alertMsg: String = ""
	
	private enum FormValidationError: Error, LocalizedError {
		case noNemeEntered
		case noJobTitleEntered
		
		var errorDescription: String? {
			switch self {
			case .noNemeEntered:        return "No Name Entered!"
			case .noJobTitleEntered:    return "No Job Title Entered"
			}
		}
		
	}
	
	var body: some View {
		VStack(spacing: 8) {
			Text(name ?? "")
			Text(jobTitle ?? "")
			Button((name ?? "" + (jobTitle ?? "")).isEmpty ? "Add Info" : "Edit Info") {
				isInputAlertShown = true
			}
			.alert("Add Your Info", isPresented: $isInputAlertShown) {
				TextField("Enter Name", text: $newName).textInputAutocapitalization(.words)
				
				TextField("Enter Job Title", text: $newJobTitle)
						.textInputAutocapitalization(.sentences)
				Button("Add", action: addInfo)
				Button("Cancel", role: .cancel) { }
			}
			.alert(isPresented: $isErrorAlertShown) {
				Alert(title: Text(alertTitle), message: Text(alertMsg), dismissButton: .cancel(Text("Ok")) {
					isInputAlertShown = true
				})
			}
		}
	}
	
	private func addInfo() {
		do {
			try validateForm()
			self.name = newName
			self.jobTitle = newJobTitle
		} catch {
			alertTitle = "Error!"
			alertMsg = error.localizedDescription
			isErrorAlertShown = true
		}
	}
	
	private func validateForm() throws {
		guard !newName.isEmpty else {
			throw FormValidationError.noNemeEntered
		}
		guard !newJobTitle.isEmpty else {
			throw FormValidationError.noJobTitleEntered
		}
	}
	
}

#Preview {
	SwiftUIInputAlert()
}
