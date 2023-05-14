//
//  Localizer.swift
//  Lori
//
//  Created by Andreas Job on 12.06.21.
//

import Foundation

public func localize(_ text: String) -> String {
	return NSLocalizedString(text, comment: text)
}

public func localize(_ text: String, _ args: String...) -> String {
	let msg = NSLocalizedString(text, comment: text)
	if args.count > 0 {
		let result = String(format: msg, arguments: args)
		return result
	}
	return msg
}

public func localize(_ text: String, _ args: Any?...) -> String {
	let msg = NSLocalizedString(text, comment: text)
	if args.count > 0 {
		let stringArgs = args.map({"\($0 ?? "")"}) // map Any? object to a String with the "\(...)" method
		let result = String(format: msg, arguments: stringArgs)
		return result
	}
	return msg
}

/*class Localizer {

	public static func localize(_ text: String) -> String {
		return NSLocalizedString(text, comment: text)
	}

	public static func localize(_ text: String, _ args: String...) -> String {
		let msg = NSLocalizedString(text, comment: text)
		if args.count > 0 {
			return String(format: msg, args)
		}
		return msg
	}
}*/
