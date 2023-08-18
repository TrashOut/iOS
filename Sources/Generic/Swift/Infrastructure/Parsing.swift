//
//  TrashOut
//  Copyright 2017 TrashOut NGO. All rights reserved.
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


infix operator <==

func <== (assignee: inout Int?, value: Any?) {
	assignee = value as? Int
}

func <== (assignee: inout Int, value: Any?) {
	if let v = value as? Int {
		assignee = v
	}
}

func <== (assignee: inout Double, value: Any?) {
	if let d = value as? Double {
		assignee = d
	} else if let i = value as? Int {
		assignee = Double(i)
	} else if let s = value as? String {
		let nf = NumberFormatter()
		nf.decimalSeparator = "."
		if let d = nf.number(from: s)?.doubleValue {
			assignee = d
		}
	}
}

func <== (assignee: inout String?, value: Any?) {
	assignee = value as? String
}

func <== (assignee: inout Date?, value: Any?) {
	if let string = value as? String {
		assignee = DateFormatter.date(from: string)
	}
}

func <== <T: JsonDecodable>(assignee: inout T?, value: Any?) {
	if let dict = value as? [String: AnyObject] {
		assignee = T.create(from: dict, usingId: nil) as? T
	}
}

func <== <T: JsonDecodable>(assignee: inout [T], value: Any?) {
	var assigned: [T] = []
	if let arr = value as? [[String: AnyObject]] {
		for a in arr {
			if let v = T.create(from: a, usingId: nil) as? T {
				assigned.append(v)
			}
		}
	}
	assignee = assigned
}

func <== <T: RawRepresentable> (assignee: inout T, value: Any?) where T.RawValue == String {
	if let string = value as? String {
		if let v = T(rawValue: string) {
			assignee = v
		}
	}
}
