//
//  UIColorExtension.swift
//  Lori
//
//  Created by Andreas Job on 04.12.20.
//

import UIKit

public extension UIColor {
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

	private static func color(named: String) -> UIColor {
		return UIColor(named: named)!
	}

	func brightned(factor: Float) -> UIColor {
		var hue = CGFloat(0)
		var saturation = CGFloat(0)
		var brightness = CGFloat(0)
		var alpha = CGFloat(0)
		self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
		brightness = brightness * CGFloat(factor)
		let changedColor = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
		return changedColor
	}
}
