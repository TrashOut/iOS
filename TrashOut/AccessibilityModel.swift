//
// TrashOut
// Copyright 2017 TrashOut NGO. All rights reserved.
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

class Accessibility: JsonDecodable {

    // MARK: - Properties

    enum AccessibilityType: String, EnumCollection {
        case byCar
        case inCave
        case underWater
        case notForGeneralCleanup

        func value(_ accessibility: Accessibility) -> Bool {
            switch self {
            case .byCar:
                return accessibility.byCar ?? false
            case .inCave:
                return accessibility.inCave ?? false
            case .underWater:
                return accessibility.underWater ?? false
            case .notForGeneralCleanup:
                return accessibility.notForGeneralCleanup ?? false
            }
        }

        func set(value: Bool, accessibility: inout Accessibility) {
            switch self {
            case .byCar:
                accessibility.byCar = value
                return
            case .inCave:
                accessibility.inCave = value
                return
            case .notForGeneralCleanup:
                accessibility.notForGeneralCleanup = value
                return
            case .underWater:
                accessibility.underWater = value
                return
            }
        }
    }

    static let types: [AccessibilityType] = [.byCar, .inCave, .underWater, .notForGeneralCleanup]

    var byCar: Bool?
    var inCave: Bool?
    var underWater: Bool?
    var notForGeneralCleanup: Bool?

    // MARK: - Lifecycle

    init() {}

    func parse(json: [String: AnyObject]) {
        byCar = json["byCar"] as? Bool
        inCave = json["inCave"] as? Bool
        underWater = json["underWater"] as? Bool
        notForGeneralCleanup = json["notForGeneralCleanup"] as? Bool
    }

    static func create(from json: [String: AnyObject], usingId _: Int? = nil) -> AnyObject {
        // Create new obj
        let accessibility = Accessibility()
        accessibility.parse(json: json)
        return accessibility
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]

        dict["byCar"] = byCar as AnyObject?
        dict["inCave"] = inCave as AnyObject?
        dict["underWater"] = underWater as AnyObject?
        dict["notForGeneralCleanup"] = notForGeneralCleanup as AnyObject?

        return dict
    }
}
