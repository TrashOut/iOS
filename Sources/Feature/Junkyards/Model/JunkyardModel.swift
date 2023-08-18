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

class Junkyard: JsonDecodable, Cachable {

    // MARK: - Enums

	enum Category: String, EnumCollection {
		case scrapyard
		case dustbin
	}

    enum DustbinType: String, EnumCollection {
        case undefined
        case paper
        //case glass
        case glassAll
        case glassGreen
        case glassGold
        case glassWhite
        case metal
        case plastic
        case dangerous
        case cardboard
        case clothes
        case biodegradable
        case electronic
        case everything
        case recyclables
    }
    
    enum JunkyardType: String, EnumCollection {
        /// type's string not defined in app
        case undefined
		case paper
		//case glass
		case glassAll
		case glassGreen
		case glassGold
		case glassWhite
		case metal
		case plastic
		case dangerous
		case cardboard
		case clothes
		case biodegradable
		case electronic
		case everything
		case recyclables

		case wiredGlass
		case battery
		case tires
		case iron
		case woodenAndUpholsteredFurniture
		case carpets
		case wooden
		case window
		case buildingRubble
		case oil
		case fluorescentLamps
		case neonLamps
		case lightBulbs
		case color
		case thinner
		case mirror
		case carParts
		case medicines
		case materialsFromBituminousPaper
		case eternitCoverings
		case asbestos
		case fireplaces
		case slag
		case glassWool
		case cinder
		case asphalt
		case bitumenPaper
    }

    // MARK: - Properties

    var id: Int = 0
    var images: [String] = []
    var gps: GPS?
    var types: [JunkyardType] = []
    var note: String?
    var size: String?
    var name: String?
    var phone: String?
    var email: String?
    var website: String?
    var openingHours: [DayOpeningHours] = []
    var userId: Int?
    var anonymous: Bool = false
    var updates: [JunkyardUpdate] = []
	var activityId: Int = 0

    // MARK: - Lifecycle

    init() {}

    /**
    Parse json data into object vars
    */
    func parse(json: [String: AnyObject]) {
        id = json["id"] as? Int ?? id
		activityId <== json["activityId"]
        images = json["images"] as? [String] ?? []
        // TODO: why is in list gps not wrapped in object??, FIXME?
        if let dict = json["gps"] as? [String: AnyObject] { // if wrapped as object
            gps = GPS.create(from: dict) as? GPS
        } else { // if lat and lng directly
            gps = GPS.create(from: json) as? GPS
        }
        if let typesValues = json["types"] as? [String] {
            types = typesValues.map{ JunkyardType.init(rawValue: $0) ?? .undefined }
        }
        note = json["note"] as? String
        size = json["size"] as? String
        name = json["name"] as? String
        phone = json["phone"] as? String
        email = json["email"] as? String
        website = json["url"] as? String
        userId = json["userId"] as? Int
        anonymous = json["anonymous"] as? Bool ?? false

        if let history = json["updateHistory"] as? [[String: AnyObject]] {
        for update in history {
                updates.append(JunkyardUpdate.create(from: update, usingId: nil) as! JunkyardUpdate)
            }
            if history.isEmpty {
                let update = json["updateTime"] as? String
                updates.append(JunkyardUpdate.create(from: update, usingId: nil) as! JunkyardUpdate)
            }
        }
        
        if let openingHours = json["openingHours"] as? [[String: AnyObject]] {
            for day in openingHours {
                self.openingHours.append(DayOpeningHours.create(from: day, usingId: nil) as! DayOpeningHours)
            }
        }
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        dict["id"] = id as AnyObject?
		dict["activityId"] = activityId as AnyObject
        dict["images"] = images as AnyObject?
        dict["types"] = types.map{$0.rawValue} as AnyObject?
        dict["note"] = note as AnyObject?
        dict["size"] = size as AnyObject?
        dict["name"] = name as AnyObject?
        dict["phone"] = phone as AnyObject?
        dict["email"] = email as AnyObject?
        dict["url"] = website as AnyObject?
        dict["openingHours"] = size as AnyObject?
        if let gps = gps {
            dict["gps"] = gps.dictionary() as AnyObject?
        }
        dict["userId"] = userId as AnyObject?
        dict["anonymous"] = anonymous as AnyObject
        var updatesList: [[String: AnyObject]] = []
        for update in updates {
            updatesList.append(update.dictionary())
        }
        dict["updateHistory"] = updatesList as AnyObject

        return dict
    }

    /**
    Create or update cached Junkyard object from json data with caching
    */
    static func create(from json: [String: AnyObject], usingId id: Int? = nil) -> AnyObject {
        // Create new junkyard
        let junkyard = Junkyard()
        junkyard.parse(json: json)
        if let id = id {
            junkyard.id = id
        }
        return junkyard
    }

}

class DayOpeningHours: JsonDecodable, Cachable {
    
    var name: String?
    var periods: [OpeningPeriod] = []
    
    public var localizedName: String? {
        guard let name = self.name else { return nil }
        
        switch name {
        case "Monday":
            return "global.days.Monday".localized
        case "Tuesday":
            return "global.days.Tuesday".localized
        case "Wednesday":
            return "global.days.Wednesday".localized
        case "Thursday":
            return "global.days.Thursday".localized
        case "Friday":
            return "global.days.Friday".localized
        case "Saturday":
            return "global.days.Saturday".localized
        case "Sunday":
            return "global.days.Sunday".localized
        default:
            return nil
        }
    }
    
    /**
     Parse json data into object vars
     */
    func parse(json: [String: AnyObject]) {
        if let name = json.keys.first {
            self.name = name
        }
        
        if let periods = json.values.first as? [[String: AnyObject]] {
            for period in periods {
                self.periods.append(OpeningPeriod.create(from: period, usingId: nil) as! OpeningPeriod)
            }
        }
    }
    
    func dictionary() -> [String: AnyObject] {
        let dict: [String: AnyObject] = [:]
        return dict
    }
    
    static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
        let openingHours = DayOpeningHours()
        openingHours.parse(json: json)
        return openingHours
    }
}

class OpeningPeriod: JsonDecodable, Cachable {
    
    var start: String!
    var finish: String!
    
    func parse(json: [String: AnyObject]) {
     
        if let start = json["Start"] as? String {
            self.start = start
        }
        if let start = json["Start"] as? Int {
            self.start = String(describing: start)
        }
        if let finish = json["Finish"] as? String {
            self.finish = finish
        }
        if let finish = json["Finish"] as? Int {
            self.finish = String(describing: finish)
        }
    }

    static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
        let openingPeriod = OpeningPeriod()
        openingPeriod.parse(json: json)
        return openingPeriod
    }
    
    func dictionary() -> [String: AnyObject] {
        let dict: [String: AnyObject] = [:]
        return dict
    }
    
}
