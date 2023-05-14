//
//  StringExtension.swift
//  Lori
//
//  Created by Andreas Job on 26.11.20.
//

import Foundation
import CommonCrypto

func + (a:String, b: Int) -> String {
	return a + "\(b)"
}

public extension String {
	static func asString(_ val: Any?) -> String {
		if (val == nil) {
			return ""
		};
		if val is String {
			return val as! String
		}
		return "\(val!)"
	}

	// liefert Substring von n1 bis n2
	// Der subscript-Code definiert Computed Properties, die nur gelesen, aber nicht verändert werden können
	// benutzung: mystring[2, 3]
	subscript(start:Int, end:Int) -> Substring {
		// subscript-Methode für Test[index]-Zugriffe mit eckigen Klammern
		var n1 = start, n2=end
		if n1<0          { n1 = 0 }            // auf gültigen
		if n1>self.count { n1 = self.count }   // Wertebereich
		if n2<0          { n2 = 0 }            // achten
		if n2>self.count { n2 = self.count }

		if n2 < n1   {              // Anfang nach Ende:
			return ""                 // leere Zeichenkette
		} else  {                   // OK
			let pos1 = self.index(self.startIndex, offsetBy: n1)
			let pos2 = self.index(self.startIndex, offsetBy: n2)
			return self[pos1..<pos2]
		}
	}
	
	// liefert das Zeichen an der Position n als String
	// (self[a, b] ruft den obigen subscript-Code auf)
	subscript(n: Int) -> Substring {
		// subscript-Methode für Test[index]-Zugriffe mit eckigen Klammern
		return self[n, n+1]
	}

	// liefert Substring für Integer-Bereich
	subscript(rng: Range<Int>) -> Substring {
		// subscript-Methode für Test[index]-Zugriffe mit eckigen Klammern
		return self[rng.lowerBound, rng.upperBound]
	}
}

extension NSAttributedString {

	// https://stackoverflow.com/a/59254364/14952324
	func trimmedAttributedString(in charset: CharacterSet) -> NSAttributedString {
		let invertedSet = charset.inverted
		let startRange = string.rangeOfCharacter(from: invertedSet)
		let endRange = string.rangeOfCharacter(from: invertedSet, options: .backwards)
		guard let startLocation = startRange?.lowerBound, let endLocation = endRange?.lowerBound else {
			return self
		}
		let range = NSRange(startLocation...endLocation, in: string)
		return attributedSubstring(from: range)
	}
}

extension Character {
	func add(_ by: Int) -> Character {
		for uni in self.unicodeScalars {
			var val = uni.value
			//if val >= 0x41 && val < 0x5A { // If in the range "A"..."Y", just as an example
			if val >= 0x20 && val < 0x7F && Int(val) + by >= 0x20 && Int(val) + by < 0x7F { // If in the range "SPACE"..."DEL", just as an example
				if (by >= 0) {
					val += UInt32(by)
				} else {
					val -= UInt32(-by)
				}
			}
			return Character(UnicodeScalar(val)!)
		}
		return self
	}
}


// MARK: -Hash functions-
// https://stackoverflow.com/a/52120827/14952324
// https://stackoverflow.com/questions/32163848/how-can-i-convert-a-string-to-an-md5-hash-in-ios-using-swift

// Defines types of hash string outputs available
public enum HashOutputType {
	// standard hex string output
	case hex
	// base 64 encoded string output
	case base64
}

// Defines types of hash algorithms available
public enum HashType {
	//case md5
	case sha1
	case sha224
	case sha256
	case sha384
	case sha512

	var length: Int32 {
		switch self {
		//case .md5: return CC_MD5_DIGEST_LENGTH
		case .sha1: return CC_SHA1_DIGEST_LENGTH
		case .sha224: return CC_SHA224_DIGEST_LENGTH
		case .sha256: return CC_SHA256_DIGEST_LENGTH
		case .sha384: return CC_SHA384_DIGEST_LENGTH
		case .sha512: return CC_SHA512_DIGEST_LENGTH
		}
	}
}

public extension String {

	/// Hashing algorithm for hashing a string instance.
	///
	/// - Parameters:
	///   - type: The type of hash to use.
	///   - output: The type of output desired, defaults to .hex.
	/// - Returns: The requested hash output or nil if failure.
	func hashed(_ type: HashType, output: HashOutputType = .hex) -> String? {

		// convert string to utf8 encoded data
		guard let message = data(using: .utf8) else { return nil }
		return message.hashed(type, output: output)
	}
}

extension Data {

	/// Hashing algorithm that prepends an RSA2048ASN1Header to the beginning of the data being hashed.
	///
	/// - Parameters:
	///   - type: The type of hash algorithm to use for the hashing operation.
	///   - output: The type of output string desired.
	/// - Returns: A hash string using the specified hashing algorithm, or nil.
	public func hashWithRSA2048Asn1Header(_ type: HashType, output: HashOutputType = .hex) -> String? {

		let rsa2048Asn1Header:[UInt8] = [
			0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
			0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
		]

		var headerData = Data(rsa2048Asn1Header)
		headerData.append(self)

		return hashed(type, output: output)
	}

	/// Hashing algorithm for hashing a Data instance.
	///
	/// - Parameters:
	///   - type: The type of hash to use.
	///   - output: The type of hash output desired, defaults to .hex.
	///   - Returns: The requested hash output or nil if failure.
	public func hashed(_ type: HashType, output: HashOutputType = .hex) -> String? {

		// setup data variable to hold hashed value
		var digest = Data(count: Int(type.length))

		_ = digest.withUnsafeMutableBytes{ digestBytes -> UInt8 in
			self.withUnsafeBytes { messageBytes -> UInt8 in
				if let mb = messageBytes.baseAddress, let db = digestBytes.bindMemory(to: UInt8.self).baseAddress {
					let length = CC_LONG(self.count)
					switch type {
					//case .md5: CC_MD5(mb, length, db)
					case .sha1: CC_SHA1(mb, length, db)
					case .sha224: CC_SHA224(mb, length, db)
					case .sha256: CC_SHA256(mb, length, db)
					case .sha384: CC_SHA384(mb, length, db)
					case .sha512: CC_SHA512(mb, length, db)
					}
				}
				return 0
			}
		}

		// return the value based on the specified output type.
		switch output {
		case .hex: return digest.map { String(format: "%02hhx", $0) }.joined()
		case .base64: return digest.base64EncodedString()
		}
	}
}
