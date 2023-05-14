//
//  Logging.swift
//  Lori
//
//  Created by Andreas Job on 29.11.20.
//

import Foundation

enum LogLevel : Int {
	case none = 0, debug = 4, path = 3, warning = 2, error = 1
}

class Logger {

#if DEBUG
	static var globalLogLevel = LogLevel.debug
#else
	static var globalLogLevel = LogLevel.error
#endif

	public static func isLogged(level: LogLevel) -> Bool {
		return (globalLogLevel.rawValue >= level.rawValue) ? true : false
	}

	public static func entering(_ method: String) {
		if (globalLogLevel.rawValue >= LogLevel.path.rawValue) {
			print("Entering \(method)")
		}
	}

	public static func entering(_ method: String, _ value: Any?) {
		if (globalLogLevel.rawValue >= LogLevel.path.rawValue) {
			var valueString: String
			if let value = value {
				if (value is String) {
					valueString = "\"\(value)\""
				} else {
					valueString = "\(value)"
				}
			} else {
				valueString = "<nil>"
			}
			print("Entering \(method) with: \(valueString)")
		}
	}
	
	/*public static func entering(_ method: String, with values: [Any?]?) {
		if (globalLogLevel.rawValue >= LogLevel.path.rawValue) {
			var valuesString: String
			if let values = values {
				valuesString = "["
				for i in 0..<values.count {
					if (i > 0) {
						valuesString.append(", ")
					}
					//let val = (values1[i] != nil) ? "\(values1[i]!)" : "<nil>"
					let val: String
					if (values[i] != nil) {
						if (values[i] is String) {
							val = "\"\(values[i]!)\""
						} else {
							val = "\(values[i]!)"
						}
					} else {
						val = "<nil>"
					}
					valuesString.append(val)
				}
				valuesString.append("]")
			} else {
				valuesString = "<nil>"
			}
			print("Entering \(method) with: \(valuesString)")
		}
	}*/

	public static func entering(_ method: String, _ values: Any?...) {
		if (globalLogLevel.rawValue >= LogLevel.path.rawValue) {
			var valuesString: String
			if values.count > 0 {
				valuesString = "["
				for i in 0..<values.count {
					if (i > 0) {
						valuesString.append(", ")
					}
					//let val = (values1[i] != nil) ? "\(values1[i]!)" : "<nil>"
					let val: String
					if (values[i] != nil) {
						if (values[i] is String) {
							val = "\"\(values[i]!)\""
						} else {
							val = "\(values[i]!)"
						}
					} else {
						val = "<nil>"
					}
					valuesString.append(val)
				}
				valuesString.append("]")
			} else {
				valuesString = "<nil>"
			}
			print("Entering \(method) with: \(valuesString)")
		}
	}

	public static func exiting(_ method: String) {
		if (globalLogLevel.rawValue >= LogLevel.path.rawValue) {
			print("Exiting \(method)")
		}
	}

	@discardableResult
	public static func exiting<T>(_ method: String, with value: T?) -> T? {
		if (globalLogLevel.rawValue >= LogLevel.path.rawValue) {
			let valueString = (value != nil) ? "\(value!)" : "<nil>"
			print("Exiting \(method) with \(valueString)")
		}
		return value
	}

	public static func debug(_ text: String) {
		if (globalLogLevel.rawValue >= LogLevel.debug.rawValue) {
			print("Debug: \(text)")
		}
	}

	public static func debug(method: String, text: String) {
		if (globalLogLevel.rawValue >= LogLevel.debug.rawValue) {
			print("Debug: \(method): \(text)")
		}
	}

	public static func warning(_ text: String) {
		if (globalLogLevel.rawValue >= LogLevel.warning.rawValue) {
			print("Warning: \(text)")
		}
	}

	public static func warning(method: String, text: String) {
		if (globalLogLevel.rawValue >= LogLevel.warning.rawValue) {
			print("Warning: \(method): \(text)")
		}
	}

	public static func error(_ text: String) {
		if (globalLogLevel.rawValue >= LogLevel.error.rawValue) {
			print("Error: \(text)")
		}
	}

	public static func error(method: String, text: String) {
		if (globalLogLevel.rawValue >= LogLevel.error.rawValue) {
			print("Error: \(method): \(text)")
		}
	}
}
