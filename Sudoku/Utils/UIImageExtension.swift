//
//  UIImageExtension.swift
//  Lori
//
//  Created by Andreas Job on 20.02.21.
//

import UIKit

public extension UIImage {
	/*static let cloudsPatternImage = UIImage(named: "CloudsPatternImage")!
	static let catPawnPatternImage = UIImage(named: "CatPawnPatternImage")!
	static let leafsPatternImage = UIImage(named: "LeafsPatternImage")!
	static let greyPatternImage = UIImage(named: "GreyPatternImage")!

	static let cloudsPatternImageScaled = UIImage(cgImage: cloudsPatternImage.cgImage!, scale: 2, orientation: .up)
	static let catPawnPatternImageScaled = UIImage(cgImage: catPawnPatternImage.cgImage!, scale: 2, orientation: .up)
	static let leafsPatternImageScaled = UIImage(cgImage: leafsPatternImage.cgImage!, scale: 2, orientation: .up)*/

	func resizeImage(targetSize: CGSize) -> UIImage {
		let size = self.size
		let widthRatio  = targetSize.width  / size.width
		let heightRatio = targetSize.height / size.height
		let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		self.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return newImage!
	}

	static func render(size: CGSize, renderingMode: UIImage.RenderingMode = .automatic, _ draw: () -> Void) -> UIImage? {
		UIGraphicsBeginImageContext(size)
		defer { UIGraphicsEndImageContext() }
		
		draw()
		
		return UIGraphicsGetImageFromCurrentImageContext()?
			.withRenderingMode(renderingMode)
	}

	static func make(size: CGSize, color: UIColor = .white) -> UIImage? {
		return render(size: size) {
			color.setFill()
			UIRectFill(CGRect(origin: .zero, size: size))
		}
	}
}
