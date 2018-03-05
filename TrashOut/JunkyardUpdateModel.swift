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

class JunkyardUpdate: JsonDecodable {

    // MARK: - Properties

	var id: Int = 0
    var updateTime: Date?
    var note: String?
    var size: String?
    var name: String?
    var phone: String?
    var email: String?
    var openingHours: String?
    var types: [Junkyard.JunkyardType]?

    // MARK: - Lifecycle

    init() {}

    func dictionary() -> [String: AnyObject] {
        guard let updateTime = updateTime else { return [:] }
		var dict: [String: AnyObject] = [:]
		dict["updateTime"] = DateFormatter.utc.string(from: updateTime) as AnyObject
		dict["id"] = id as AnyObject
		dict["note"] = note as AnyObject
		dict["size"] = size as AnyObject
		dict["name"] = name as AnyObject
		dict["phone"] = phone as AnyObject
		dict["email"] = email as AnyObject
		dict["openingHours"] = openingHours as AnyObject
		dict["types"] = types?.map({ $0.rawValue as AnyObject}) as AnyObject
		return dict
    }

    static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
        let update = JunkyardUpdate()
        if let date = json["updateTime"] as? Date {
            update.updateTime = date
        } else if let dateString = json["updateTime"] as? String {
            update.updateTime = DateFormatter.utc.date(from: dateString)
        }
		let change = json["changed"] as? [String: AnyObject] ?? json
		if let size = change["status"] as? String {
			update.size = size
		}
		if let note = change["note"] as? String {
			update.note = note
		}
		if let name = change["name"] as? String {
			update.name = name
		}
		if let phone = change["phone"] as? String {
			update.phone = phone
		}
		if let email = change["email"] as? String {
			update.email = email
		}
		if let openingHours = change["openingHours"] as? String {
			update.openingHours = openingHours
		}
		if let types = change["types"] as? [String] {
			update.types = types.map{ Junkyard.JunkyardType(rawValue: $0) ?? .undefined }
		}
        return update
    }

    static func create(from date: String?, usingId id: Int?) -> AnyObject {
        let update = JunkyardUpdate()
        if let dateString = date {
            update.updateTime = DateFormatter.utc.date(from: dateString)
        }
        return update
    }

}
