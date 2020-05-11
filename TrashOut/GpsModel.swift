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
import UIKit
import Cache

class GPS: JsonDecodable {

    // MARK: - Properties

	var long: Double = 0
    var lat: Double = 0
    var accuracy: Int = 0
    var continent: String?
    var country: String?
    var aa1: String?
    var aa2: String?
    var aa3: String?
    var locality: String?
    var subLocality: String?
    var street: String?
    var zip: Int?

    // MARK: - Lifecycle

    init() {}

    func parse(json: [String: AnyObject]) {
        long = json.double("long") ?? 0
        lat = json.double("lat") ?? 0
        accuracy <== json["accuracy"]
        let area = json["area"] as? [String: AnyObject] ?? json
            self.continent <== area["continent"]
            self.country <== area["country"]
            self.aa1 <== area["aa1"]
            self.aa2 <== area["aa2"]
            self.aa3 <== area["aa3"]
            self.locality <== area["locality"]
            self.subLocality <== area["sublocality"]
            self.street <== area["street"]
            self.zip <== area["zip"]
        /*if let area = json["area"] as? [String: AnyObject] {
            self.continent <== area["continent"]
            self.country <== area["country"]
            self.aa1 <== area["aa1"]
            self.aa2 <== area["aa2"]
            self.aa3 <== area["aa3"]
            self.locality <== area["locality"]
            self.subLocality <== area["sublocality"]
            self.street <== area["street"]
            self.zip <== area["zip"]
        }*/
    }

    class func create(from json: [String: AnyObject], usingId _: Int? = nil) -> AnyObject {
        // Create new obj
        let gps = GPS()
        gps.parse(json: json)
        return gps
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        dict["long"] = long as AnyObject
        dict["lat"] = lat as AnyObject
        dict["accuracy"] = accuracy as AnyObject
        dict["continent"] = continent as AnyObject?
        dict["country"] = country as AnyObject?
        dict["aa1"] = aa1 as AnyObject?
        dict["aa2"] = aa2 as AnyObject?
        dict["aa3"] = aa3 as AnyObject?
        dict["locality"] = locality as AnyObject?
        dict["subLocality"] = subLocality as AnyObject?
        dict["street"] = street as AnyObject?
        dict["zip"] = zip as AnyObject?

        return dict
    }
}


class Area: GPS, Cachable, Hashable, Equatable {

	enum AreaType: String, EnumCollection {
		case continent
		case country
		case aa1
		case aa2
		case aa3
		case locality // city
		case sublocality = "subLocality"
		case street
		case zip

		func isSubtype(of type: AreaType) -> Bool {
			let all = AreaType.allValues
			guard let selfindex = all.index(of: self) else { return false }
			guard let typeindex = all.index(of: type) else { return false }
			return typeindex < selfindex
		}
	}

	var id: Int = 0
	var centerLat: Double = 0
	var centerLong: Double = 0

	override func parse(json: [String: AnyObject]) {
		super.parse(json: json)
		self.centerLong = json.double("centerLong") ?? 0
		self.centerLat = json.double("centerLat") ?? 0
		self.id <== json["id"]
	}

	override func dictionary() -> [String: AnyObject] {
		var dict = super.dictionary()
		dict["id"] = id as AnyObject
		dict["centerLat"] = centerLat as AnyObject
		dict["centerLong"] = centerLong as AnyObject
		return dict
	}

	override class func create(from json: [String: AnyObject], usingId id: Int? = nil) -> AnyObject {
		let area = Area()
		area.id = id ?? 0
		area.parse(json: json)
		return area
	}

	var type: AreaType {
		if let _ = zip {
			return .zip
		} else if let _ = street {
			return .street
		} else if let _ = subLocality {
			return .sublocality
		} else if let _ = locality {
			return .locality
		} else if let _ = aa3 {
			return .aa3
		} else if let _ = aa2 {
			return .aa2
		} else if let _ = aa1 {
			return .aa1
		} else if let _ = country {
			return .country
		} else if let _ = continent {
			return .continent
		} else {
			return .continent // something what shouldnt happen
		}
	}

	var typeValue: String {
		if let zip = zip {
			return "\(zip)"
		} else if let street = street {
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
			return ""
		}
	}

	var subtype: AreaType? {
		switch self.type {
		case .continent:
			return .country
		case .country:
			return .aa1
		case .aa1:
			return .aa2
		case .aa2:
			return .aa3
		case .aa3:
			return .locality
		case .locality:
			return .sublocality
		case .sublocality:
			return .street
		case .street:
			return .zip
		default:
			return nil
		}
	}
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

	static func == (lhs: Area, rhs: Area) -> Bool {
		return lhs.id == rhs.id
	}

}
