//
//  FileUtil.swift
//  Lori
//
//  Created by Andreas Job on 24.12.20.
//

import Foundation

class FileUtil {

	/*public func createDirectory(directory: String) {
		/*let homepath = NSHomeDirectory()
		let fullDir = homepath + (!directory.starts(with: "/") ? "/" : "") + directory*/
		print("Checking directory \(directory)...")
		var isDir : ObjCBool = true
		if !fileManager.fileExists(atPath: directory, isDirectory: &isDir) {
			print("Directory \(directory) doesn't exist")
			do {
				print("Creating directory \(directory)...")
				try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
			} catch {
				print(error.localizedDescription);
			}
		}
	}*/

	@discardableResult
	public static func createDirectory(at directoryUrl: URL) -> Bool {
		Logger.entering("createDirectory(URL)", directoryUrl)
		/*let homepath = NSHomeDirectory()
		let fullDir = homepath + (!directory.starts(with: "/") ? "/" : "") + directory*/
		Logger.debug("Checking directory \(directoryUrl.path)...")
		let fileManager = FileManager.default
		var isDir : ObjCBool = true
		if !fileManager.fileExists(atPath: directoryUrl.path, isDirectory: &isDir) {
			Logger.debug("Directory \(directoryUrl.path) doesn't exist")
			do {
				Logger.debug("Creating directory \(directoryUrl.path)...")
				try fileManager.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
			} catch {
				Logger.error(error.localizedDescription);
				Logger.exiting("createDirectory(URL)", with: false)
				return false
			}
		}
		Logger.exiting("createDirectory(URL)", with: true)
		return true
	}

	// liefert URL für Unterverzeichniss vom Documents-Verzeichnis
	public static func pathUrl(for directory: String) -> URL {
		// sollte immer genau ein Ergebnis liefern
		let fileManager = FileManager.default
		let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) // sollte immer genau ein Ergebnis liefern
		if var url = urls.first {
			if (directory.count > 0) {
				url.appendPathComponent(directory, isDirectory: true)
			}
			return url
		} else {
			let homepath = NSHomeDirectory()
			var url = URL(fileURLWithPath: homepath, isDirectory: true).appendingPathComponent("Documents", isDirectory: true)
			if (directory.count > 0) {
				url.appendPathComponent(directory, isDirectory: true)
			}
			return url
		}
	}

	// liefert URL für Datei im Documents-Verzeichnis
	public static func fileUrl(for filename: String, in subDir: String? = nil) -> URL? {
		let fileManager = FileManager.default
		let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask) // sollte immer genau ein Ergebnis liefern
		if var url = urls.first {
			if (subDir != nil && subDir!.count > 0) {
				url.appendPathComponent(subDir!, isDirectory: true)
			}
			return url.appendingPathComponent(filename)
		}
		return nil
	}

	public static func listFiles(directory: URL) -> [URL] {
		var result: [URL] = []
		if (directory.hasDirectoryPath) {
			let fileManager = FileManager.default
			do {
				result =
					try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.nameKey, .pathKey])
			} catch {
				Logger.debug("Error listing contentes of directory \(directory): \(error)")
			}
		}
		return result;
	}

	@discardableResult
	public static func deleteFile(file: URL) -> Bool {
		let fileManager = FileManager.default
		do {
			var isDir : ObjCBool = false
			if (fileManager.fileExists(atPath: file.path, isDirectory: &isDir) && isDir.boolValue == false) {
				try fileManager.removeItem(at: file)
			} else {
				Logger.debug("File \(file.lastPathComponent) doesn't exist")
			}
		} catch {
			Logger.debug("Can't delete file \(file): \(error)")
			return false
		}
		return true
	}

	public static func write<T: Encodable>(
			_ value: T,
			toDocumentNamed documentName: String,
			in subDir: String? = nil,
			encodedUsing encoder: JSONEncoder = .init()) throws -> Bool  {
		if let url = FileUtil.fileUrl(for: documentName, in: subDir) {
			let data = try encoder.encode(value)
			try data.write(to: url)
		} else {
			Logger.debug("Can't write to file \(documentName)")
			return false
		}
		/*let folderURL = try FileManager.default.url(
			for: .documentDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: false
		)
		let fileURL = folderURL.appendingPathComponent(documentName)
		let data = try encoder.encode(value)
		try data.write(to: fileURL)*/
		return true
	}
}
