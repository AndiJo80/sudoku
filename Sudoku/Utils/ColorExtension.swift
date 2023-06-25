//
//  ColorExtension.swift
//  Sudoku
//
//  Created by Andreas Job on 18.06.23.
//

import SwiftUI

public extension Color {
	/*static let articleDerColor = UIColor.color(named: "ArticleDerColor")
	static let articleDieColor = UIColor.color(named: "ArticleDieColor")
	static let articleDasColor = UIColor.color(named: "ArticleDasColor")
	static let grayCardColor = UIColor.color(named: "GrayCardColor")
	static let popupBackgroundColor = UIColor.color(named: "PopupBackgroundColor")
	static let textMarkerColor = UIColor.color(named: "TextMarkerColor")
	static let customAccentColor1 = UIColor.color(named: "CustomAccentColor1")
	static let customAccentColor2 = UIColor.color(named: "CustomAccentColor2")
	static let lightGreenColor = UIColor.color(named: "LightGreenColor")
	static let lightRedColor = UIColor.color(named: "LightRedColor")
	static let lightYellowColor = UIColor.color(named: "LightYellowColor")
	static let titleBarColor = UIColor.color(named: "TitleBarColor")
	static let shadowColor = UIColor.color(named: "ShadowColor")

	static let allColors: [UIColor] = [
		articleDerColor,
		articleDieColor,
		articleDasColor,
		grayCardColor,
		popupBackgroundColor,
		textMarkerColor,
		customAccentColor1,
		customAccentColor2,
		lightGreenColor,
		lightRedColor,
		lightYellowColor,
		titleBarColor,
		shadowColor
	]

	static let allNames = [
		"ArticleDerColor",
		"ArticleDieColor",
		"ArticleDasColor",
		"GrayCardColor",
		"PopupBackgroundColor",
		"TextMarkerColor",
		"CustomAccentColor1",
		"CustomAccentColor2",
		"LightGreenColor",
		"LightRedColor",
		"LightYellowColor",
		"TitleBarColor",
		"ShadowColor"
	]*/

	static let selectedButtonColor = Color.color(name: "SelectedButtonColor")

	static let allColors: [Color] = [
		selectedButtonColor
	]

	static let allNames = [
		"SelectedButtonColor"
	]

	private static func color(name: String) -> Color {
		return Color(name)
	}

	func brightned(factor: Float) -> Color {
		let uiColor = UIColor(cgColor: self.cgColor!)
		var hue = CGFloat(0)
		var saturation = CGFloat(0)
		var brightness = CGFloat(0)
		var alpha = CGFloat(0)
		uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		brightness = brightness * CGFloat(factor)
		//let changedColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		let changedColor = Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
		return changedColor
	}
}
