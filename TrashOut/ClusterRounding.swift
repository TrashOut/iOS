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

class ClusterRounding {

	static let shared = ClusterRounding()

	/// 2,3,4,5,10,20,50,100, 200, 500, 1k, 2k, 5k, 10k, 20k, 50k, 100k
	func round(count: Int) -> String { // tailor:disable
		switch count {
		case 0...5: return "\(count)"
		case 6..<10: return "5+"
		case 10..<20: return "10+"
		case 20..<50: return "20+"
		case 50..<100: return "50+"
		case 100..<200: return "100+"
		case 200..<500: return "200+"
		case 500..<1000: return "500+"
		case 1000..<2000: return "1k+"
		case 2000..<5000: return "2k+"
		case 5000..<10000: return "5k+"
		case 10000..<20000: return "10k+"
		case 20000..<50000: return "20k+"
		case 50000..<100000: return "50k+"
		default: return "100k+"
		}
	}

}
