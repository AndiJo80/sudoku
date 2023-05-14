//
//  NamedFont.swift
//  Sudoku
//
//  Created by Andreas Job on 14.05.23.
//

import SwiftUI

struct NamedFont: Identifiable {
	static let largeTitle = NamedFont(name: "Large Title", font: .largeTitle);
	static let title = NamedFont(name: "Title", font: .title);
	static let headline = NamedFont(name: "Headline", font: .headline);
	static let body = NamedFont(name: "Body", font: .body);
	static let caption = NamedFont(name: "Caption", font: .caption);

	static let namedFonts: [String : NamedFont] = [
		largeTitle.name : largeTitle,
		title.name : title,
		headline.name : headline,
		body.name : body,
		caption.name : caption
	]

	let name: String
	let font: Font
	public var id: String { name }
}

/*private let namedFonts: [NamedFont] = [
	NamedFont(name: "Large Title", font: .largeTitle),
	NamedFont(name: "Title", font: .title),
	NamedFont(name: "Headline", font: .headline),
	NamedFont(name: "Body", font: .body),
	NamedFont(name: "Caption", font: .caption)
]*/


