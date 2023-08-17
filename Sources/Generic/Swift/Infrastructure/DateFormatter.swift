//
// TrashOut
// Copyright 2017 TrashOut NGO. All rights reserved.
// License GNU GPLv3
//

/**
  * TrashOut is an environmental project that teaches people how to recycle
  * and showcases the worst way of handling waste - illegal dumping. All you need is a smart phone.
  *
  *
  * There are 10 types of programmers - those who are helping TrashOut and those who are not.
  * Clean up our code, so we can clean up our planet.
  * Get in touch with us: help@trashout.ngo
  *
  * Copyright 2017 TrashOut, n.f.
  *
  * This file is part of the TrashOut project.
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
  * the Free Software Foundation; either version 3 of the License, or
  * (at your option) any later version.
  *
  * This program is distributed in the hope that it will be useful,
  * but WITHOUT ANY WARRANTY; without even the implied warranty of
  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  * GNU General Public License for more details.
  *
  * See the GNU General Public License for more details: <https://www.gnu.org/licenses/>.
 */

import Foundation

extension DateFormatter {

	static func date(from anyString: String) -> Date? {
		let date = DateFormatter.utc.date(from: anyString) ??
			DateFormatter.zulu.date(from: anyString) ??
			DateFormatter.utc2.date(from: anyString) ??
			DateFormatter.zulu2.date(from: anyString)
		#if DEBUG
			if date == nil {
				print("Unrecognized date format: \(anyString)")
			}
		#endif
		return date
	}

	/// Format: `yyyy-MM-dd'T'HH:mm:ss.SSSZ`
	static var utc: DateFormatter {
		get {
			let formatter = DateFormatter()
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.locale = Locale(identifier: "en_GB_POSIX")
			formatter.timeZone = TimeZone.current
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
			return formatter
		}
	}

	/// Format: `yyyy-MM-dd'T'HH:mm:ssZ`
	static var utc2: DateFormatter {
		get {
			let formatter = DateFormatter()
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.locale = Locale(identifier: "en_GB_POSIX")
			formatter.timeZone = TimeZone.current
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
			return formatter
		}
	}

	/// Format: `yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX`
	static var zulu: DateFormatter {
		get {
			let formatter = DateFormatter()
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
			return formatter
		}
	}

	/// Format: `yyyy-MM-dd'T'HH:mm:ssZ`
	static var zulu2: DateFormatter {
		get {
			let formatter = DateFormatter()
			formatter.calendar = Calendar(identifier: .iso8601)
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone.init(secondsFromGMT: 0)
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
			return formatter
		}
	}

}
