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

class TrashUpdate: JsonDecodable {

    /**
     Status for map/list/filter
     
     Cleaned (status=cleaned) – zelená ikonka
     Reported (status=stillHere nebo more nebo less a updateNeeded=false) – červená ikonka
     UpdateNeeded (updateNeeded=true)  – žlutá ikonka
     */
    enum DisplayStatus: String, EnumCollection {
        case reported
        case updateNeeded
        case cleaned
    }
    
    enum ActivityStatus: String, EnumCollection {
        case reported
        case updated
        case cleaned
    }
    
    // MARK: - Properties
	var id: Int = 0
	var updateTime: Date?
    var note: String?
    var anonymous: Bool = false
	var status: Trash.Status?

    var size: Trash.Size?
	var types: [Trash.TrashType]?
    var images: [Image] = []
    var user: User?
    var accessibility: Accessibility?

    // MARK: - Lifecycle

	init() {}

	func dictionary() -> [String: AnyObject] {
		// TODO: fillme!
		guard let updateTime = updateTime else { return [:] }
		return ["updateTime": DateFormatter.utc.string(from: updateTime) as AnyObject]
	}

	static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
		let update = TrashUpdate()
		update.id = json["activityId"] as? Int ?? 0
		if let date = json["updateTime"] as? Date {
			update.updateTime = date
		} else if let dateString = json["updateTime"] as? String {
			update.updateTime = DateFormatter.date(from: dateString)
		} else if let dateString = json["created"] as? String {
			update.updateTime = DateFormatter.date(from: dateString)
		}
		if let change = json["changed"] as? [String: AnyObject] {
			update.parseChanges(change: change)
		} else {
			update.parseChanges(change: json) // data not wrapped in 'change', ex. last record
		}
        if let userInfo = json["userInfo"] as? [String: AnyObject] {
            update.user = User.create(from: userInfo, usingId: nil) as? User
        }
		return update
	}

	func parseChanges(change: [String: AnyObject]) {
		if let status = change["status"] as? String {
			self.status = Trash.Status(rawValue: status)
		}
		if let size = change["size"] as? String {
			self.size = Trash.Size(rawValue: size)
		}
		if let note = change["note"] as? String {
			self.note = note
		}
		if let types = change["types"] as? [String] {
			self.types = types.map{ Trash.TrashType(rawValue: $0) ?? .undefined }
		}
		if let image = change["images"] as? [[String: AnyObject]] {
			for im in image {
				self.images.append(Image.create(from: im, usingId: nil) as! Image)
			}
		}
		if let accessibility = change["accessibility"] as? [String: AnyObject] {
			self.accessibility = Accessibility.create(from: accessibility, usingId: nil) as? Accessibility
		}
		if let anonymous = change["anonymous"] as? Bool {
			self.anonymous = anonymous
		}
	}

    static func create(from date: String?, usingId id: Int?) -> AnyObject {
        let update = TrashUpdate()
        if let dateString = date {
            update.updateTime = DateFormatter.utc.date(from: dateString) ?? DateFormatter.zulu.date(from: dateString)
        }
		update.status = .stillHere
        return update
    }

}
