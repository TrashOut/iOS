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
import SwiftDate

class DateRounding {

	static let shared = DateRounding()
    
	/// today, yesterday, this week, more than a week ago, more than a month ago, more than 6 months ago, more than a year ago
	func localizedString(for date: Date) -> String { // tailor:disable
		guard date.isInPast else { return "" }
		let now = Date()
		if date.isToday {
			return "trash.lastUpdate.today".localized
		}
		if date.isYesterday {
			return "trash.lastUpdate.yesterday".localized
		}
		if date > now - 1.week {
			return "trash.lastUpdate.thisWeek".localized
		}
		if date > now - 1.month {
			return "trash.lastUpdate.moreThanWeekAgo".localized
		}
		if date > now - 6.months {
			return "trash.lastUpdate.moreThanMonthAgo".localized
		}
		if date > now - 1.year {
			return "trash.lastUpdate.moreThanSixMonthAgo".localized
		}
		return "trash.lastUpdate.moreThanYearAgo".localized
	}

}
