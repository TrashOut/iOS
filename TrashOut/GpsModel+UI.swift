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

extension GPS {

	var shortName: String {
		if let zip = zip, let street = street {
			return "\(zip) " + street
		} else if zip == nil, let street = street {
			return street
		} else if let subLocality = subLocality {
			return subLocality
		} else if let locality = locality {
			return locality
		} else if let aa3 = aa3 {
			return aa3
		} else if let aa2 = aa2 {
			return aa2
		} else if let aa1 = aa1 {
			return aa1
		} else if let country = country {
			return country
		} else if let continent = continent {
			return continent
		} else {
			return "global.noAddress".localized
		}
	}
}
