//
//  LanguageSettings.swift
//  Lori
//
//  Created by Andreas Job on 06.03.21.
//

import Foundation

class LanguageSettings {

	//private static let LanguageSettingsUserDefaultKey = "language"

	static var selectedLanguage: Language {
		get {
			let langCode = Bundle.main.preferredLocalizations.first
			let language = Language(langCode)
			return language
			/*let langStr = UserDefaults.standard.value(forKey: LanguageSettings.LanguageSettingsUserDefaultKey)
			if let langStr = langStr as? String {
				let lang = Language.valueOf(val: langStr)
				return (lang != nil) ? lang! : Language.system
			}
			return Language.system*/
		}
		set {
			let langCode = newValue.code
			UserDefaults.standard.set([langCode], forKey: "AppleLanguages")
			UserDefaults.standard.synchronize()
			/*// store new value in user defaults program properties
			UserDefaults.standard.setValue(newValue.rawValue, forKeyPath: LanguageSettings.LanguageSettingsUserDefaultKey)*/
		}
	}

	static func allLanguages() -> [Language] {
		return Bundle.main.localizations.filter({ $0 != "Base" }).map({ Language($0) })
		/*var allLanguages: [Language] = []
		for languageCode in Bundle.main.localizations.filter({ $0 != "Base" }) {
			allLanguages.append(Language(languageCode))
		}
		return allLanguages*/
	}
}

class Language : Comparable, Equatable {
	var code: String?
	var name: String {
		get {
			if let code = code {
				let englishLocale = Locale(identifier: "en")
				let langName = englishLocale.localizedString(forLanguageCode: code)
				return langName ?? "System"
			}
			return "System"
		}
	}
	var nameLocalized: String {
		get {
			if let code = code {
				let langName = Locale.current.localizedString(forLanguageCode: code)
				return langName ?? "System"
			}
			return "System"
		}
	}

	init(_ code: String?) {
		self.code = code
	}

	func nameLocalized(languageCode: String?) -> String {
		if let code = code {
			let locale = (languageCode != nil) ? Locale(identifier: languageCode!) : Locale.current
			let langName = locale.localizedString(forLanguageCode: code)
			return langName ?? "System"
		}
		return "System"
	}

	static func == (lhs: Language, rhs: Language) -> Bool {
		return lhs.code == rhs.code
	}

	static func < (lhs: Language, rhs: Language) -> Bool {
		return lhs.nameLocalized.compare(rhs.nameLocalized) == .orderedAscending
		/*if (lhs.code == nil) {
			return lhs.code != nil
		}
		if (rhs.code == nil) {
			return false
		}
		let s1 = Locale.current.localizedString(forLanguageCode: lhs.code!) ?? ""
		let s2 = Locale.current.localizedString(forLanguageCode: rhs.code!) ?? ""
		return s1.compare(s2) == .orderedAscending*/
	}
}
