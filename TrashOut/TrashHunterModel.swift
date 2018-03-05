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


class TrashHunterConfig {

	var distance: TrashHunterDistance = .default
	var duration: TrashHunterDuration = .default

	//  (500m → 5 min., 1km → 10 min., 5km → 10 min., 20km → 15 min.)
	var timeFilter: TimeInterval {
		switch distance {
		case .m500: return 5*60
		case .km1: return 10*60
		case .km5: return 10*60
		case .km20: return 15*60
		}
	}

	/// minimum needed traveled distance for notification
	let minimumMovement: Int = 50


	init() { }

}

/**
Distance to hunt

(500m - default, 1 km, 5 km, 20km)
*/
enum TrashHunterDistance: String, EnumCollection {
	case m500
	case km1
	case km5
	case km20

	static var `default`: TrashHunterDistance = .m500

	var meters: Int {
		switch self {
		case .m500: return 500
		case .km1: return 1000
		case .km5: return 5000
		case .km20: return 20000
		}
	}

	var localizedName: String {
		switch self {
		case .m500: return "500 m".localized
		case .km1: return "1 km".localized
		case .km5: return "5 km".localized
		case .km20: return "20 km".localized
		}
	}

}

/**
Duration of hunt

(10min, 30 min, 60 min)
*/
enum TrashHunterDuration: String, EnumCollection {
	case m10
	case m30
	case m60

	static var `default`: TrashHunterDuration = .m10

	var duration: TimeInterval {
		switch self {
		case .m10: return 10*60
		case .m30: return 30*60
		case .m60: return 60*60
		}
	}

	var localizedName: String {
		switch self {
		case .m10: return "10 min".localized
		case .m30: return "30 min".localized
		case .m60: return "1 " + "global.time.hour".localized
		}
	}
}
