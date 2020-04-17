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
import Cache
import CoreLocation

class Event: JsonDecodable, Cachable {

    // MARK: - Properties

    var id = 0
    var name: String?
    var userId: Int?
    var gps: GPS?
    var description: String?
    var duration = 0
    var start: Date?
    var bring: String?
    var have: String?
    var trash: [Trash] = []
	var users: [User] = []
    var images: [Image] = []
    var showJoinButton: Bool = false
    var contact: EventContact?
    
    // MARK: - Lifecycle

    init() {}

    func parse(json: [String: AnyObject]) {
        id <== json["id"]
        userId <== json["userId"]
        name <== json["name"]
		if let dict = json["gps"] as? [String: AnyObject] { // if wrapped as object
            gps <== dict
        } else { // if lat and lng directly
            gps <== json
        }
        description <== json["description"]
        
        let rawDuration = json["duration"] as? String
        duration <== (rawDuration != nil ? Int(rawDuration!) : nil)
		start <== json["start"]
        bring <== json["bring"]
        have <== json["have"]
		users <== json["users"]
        if let image = json["images"] as? [[String: AnyObject]] {
            for update in image {
                images.append(Image.create(from: update, usingId: nil) as! Image)
            }
        }
        if let trashPoints = json["trashPoints"] as? [[String: AnyObject]] {
            for update in trashPoints {
                trash.append(Trash.create(from: update, usingId: nil) as! Trash)
            }
        }
        
        if let contactJson = json["contact"] as? [String: AnyObject] {
            contact = EventContact.create(from: contactJson, usingId: nil) as? EventContact
        }
    }

    static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
        // Create new obj
        let event = Event()
        event.parse(json: json)
        return event
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]

        dict["id"] = id as AnyObject?
        dict["name"] = name as AnyObject?
        if let gps = gps {
            dict["gps"] = gps.dictionary() as AnyObject?
        }
        dict["description"] = description as AnyObject?
        dict["duration"] = duration as AnyObject?
        if let startTime = start {
            dict["start"] = DateFormatter.utc.string(from: startTime) as AnyObject
        }
        dict["bring"] = bring as AnyObject?
        dict["have"] = have as AnyObject?
        var trashList: [[String: AnyObject]] = []
        for update in trash {
            trashList.append(update.dictionary())
        }
        dict["trashPoints"] = trashList as AnyObject
        dict["contact"] = contact?.dictionary() as AnyObject
        return dict
    }

}
