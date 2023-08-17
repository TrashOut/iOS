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
import Cache


/**
Users activities

There are several types of activity for user actions, importat for app now is type of trashPoint
*/
enum Action: String, EnumCollection {
    case create
    case update
    case join
}

class Activity: JsonDecodable, Cachable {

    enum ActivityType: String {
        case trashPoint
        case collectionPoint
        case event
        case other
    }

    var id: Int = 0
    var user: User?
    var type: ActivityType = .other
    var trashUpdate: TrashUpdate?
    var created: Date?
    var gps: GPS?
    var action: Action?

    init() {}

    func parse(_ json: [String: AnyObject]) {
        id = json["id"] as? Int ?? Int(json["id"] as? String ?? "0") ?? id
		self.user <== json["userInfo"]
		self.type <== json["type"]
        self.trashUpdate <== json["activity"]
		self.created <== json["created"]
        self.gps <== json["gps"]
        if let action = json["action"] as? String {
            self.action = Action(rawValue: action)
        }
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        dict["id"] = self.id as AnyObject?
        dict["userInfo"] = self.user?.dictionary() as AnyObject?
        dict["type"] = self.type.rawValue as AnyObject?
        dict["activity"] = self.trashUpdate?.dictionary() as AnyObject?
        return dict
    }

    static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
        let activity = Activity()
        activity.id = id ?? 0
        activity.parse(json)
        return activity
    }
}
