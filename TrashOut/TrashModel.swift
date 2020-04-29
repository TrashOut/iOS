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
import CoreLocation

class Trash: JsonDecodable, Cachable {

    // MARK: - Enums

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

    /**
     Status in history log

     Reported (status=stillHere, první záznam v historii) – červená ikonka
     Updated (status=stillHere) – oranžová ikonka
     More (status=more) – oranžová ikonka
     Less (status=less) – oranžová ikonka
     Cleaned (status=cleaned) – zelená ikonka
     */
    enum HistoryStatus: String, EnumCollection {
        case reported
        case updated
        case more
        case less
        case cleaned
    }

    /**
     Status for detail

     Reported (status=stillHere, první záznam v historii) – červená ikonka
     Updated (status=stillHere, neprvní záznam) – oranžová ikonka
     More (status=more) – oranžová ikonka
     Less (status=less) – oranžová ikonka
     Cleaned (status=cleaned) – zelená ikonka
     Update Needed (updateNeeded=true) – žlutá ikonka
     */
    enum DetailStatus: String, EnumCollection {
        case reported
        case updated
        case more
        case less
        case cleaned
        case updateNeeded
    }

    /**
     Status for api

     */
    enum Status: String, EnumCollection {
        case stillHere
        case less
        case more
        case cleaned
    }

    enum TrashType: String, EnumCollection {
        /// type's string not defined in app
        case undefined
        case domestic
        case liquid
        case plastic
        case automotive
        case dangerous
        case metal
        case electronic
        case deadAnimals
        case organic
        case construction
        case glass
    }

    enum Size: String, EnumCollection {
        case bag
        case car
        case wheelbarrow
    }

    // MARK: - Properties

    var id: Int = 0
    var activityId: Int = 0
    var status: Status = .stillHere
    var size: Size = .bag
    var images: [Image] = []
    var gps: GPS?
    var types: [TrashType] = []
    var note: String?
    var userId: Int?
    var anonymous: Bool = false
    var updates: [TrashUpdate] = []
    var created: Date?
    // Used on list
    var activityCreated:Date?
    // Used on detail
    var updateTime:Date?
    var url: String?
    var accessibility: Accessibility?
    var user: User?
    var events: [Event] = []
    var updateNeeded: Bool = false

	var sharingUrl: String {
        let url = self.url.flatMap(URL.init) ?? Link.dump(id: id).url
        return url.absoluteString
	}

    // MARK: - Lifecycle

    init() {}

    /**
     Parse json data into object vars
     */
    func parse(json: [String: AnyObject]) {
        if let intId = json["id"] as? Int {
            id = intId
        } else if let stringId = json["id"] as? String, let intId = Int(stringId) {
            id = intId
        }
        activityId <== json["activityId"]
        if let statusValue = json["status"] as? String {
            status = Status.init(rawValue: statusValue) ?? .stillHere
        }
        if let sizeValue = json["size"] as? String {
            size = Size.init(rawValue: sizeValue) ?? .bag
        }
        if let dict = json["gps"] as? [String: AnyObject] { // if wrapped as object
            gps = GPS.create(from: dict) as? GPS
        } else { // if lat and lng directly
            gps = GPS.create(from: json) as? GPS
        }
        if let typesValues = json["types"] as? [String] {
            types = typesValues.map { TrashType.init(rawValue: $0) ?? .undefined }
        }
        note = json["note"] as? String
        userId = json["userId"] as? Int
        anonymous = json["anonymous"] as? Bool ?? false

        if let history = json["updateHistory"] as? [[String: AnyObject]] {
            for update in history {
                updates.append(TrashUpdate.create(from: update, usingId: nil) as! TrashUpdate)
            }
            //            if history.isEmpty {
            //                let update = json["updateTime"] as? String
            //                updates.append(TrashUpdate.create(from: update, usingId: nil) as! TrashUpdate)
            //            }
        }
        updates.append(TrashUpdate.create(from: json, usingId: nil) as! TrashUpdate)
        updates = updates.sorted(by: { (u1, u2) -> Bool in
            guard let time2 = u2.updateTime else { return true}
            guard let time1 = u1.updateTime else { return false }
            return time1 >= time2
        })

        if let image = json["images"] as? [[String: AnyObject]] {
            for update in image {
                images.append(Image.create(from: update, usingId: nil) as! Image)
            }
        }

        if let date = json["created"] as? Date {
            created = date
        } else if let dateString = json["created"] as? String {
            created = DateFormatter.date(from: dateString)
        }
        
        if let date = json["activityCreated"] as? Date {
            activityCreated = date
        } else if let dateString = json["activityCreated"] as? String {
            activityCreated = DateFormatter.date(from: dateString)
        }
        
        if let date = json["updateTime"] as? Date {
            updateTime = date
        } else if let dateString = json["updateTime"] as? String {
            updateTime = DateFormatter.date(from: dateString)
        }

        url = json["url"] as? String

        if let access = json["accessibility"] as? [String: AnyObject] {
            accessibility = Accessibility.create(from: access) as? Accessibility
        }

        if let userInfo = json["userInfo"] as? [String: AnyObject] {
            user = User.create(from: userInfo) as? User
        }

        if let event = json["events"] as? [[String: AnyObject]] {
            for update in event {
                events.append(Event.create(from: update, usingId: nil) as! Event)
            }
        }

        updateNeeded = json["updateNeeded"] as? Bool ?? false
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        dict["id"] = id as AnyObject?
        dict["status"] = status.rawValue as AnyObject?
        dict["types"] = types.map { $0.rawValue } as AnyObject?
        dict["note"] = note as AnyObject?
        dict["size"] = size.rawValue as AnyObject?
        if let gps = gps {
            dict["gps"] = gps.dictionary() as AnyObject?
        }
        dict["userId"] = userId as AnyObject?
        dict["anonymous"] = anonymous as AnyObject
        var updatesList: [[String: AnyObject]] = []
        for update in updates {
            updatesList.append(update.dictionary())
        }
        if updatesList.count > 0 {
            updatesList.removeLast()
        }
        dict["updateHistory"] = updatesList as AnyObject
        if let created = created {
            dict["created"] = DateFormatter.utc.string(from: created) as AnyObject
        }
        var imageList: [[String: AnyObject]] = []
        for update in images {
            imageList.append(update.dictionary())
        }
        dict["images"] = imageList as AnyObject
        dict["url"] = url as AnyObject?
        if let accessibility = accessibility {
            dict["accessibility"] = accessibility.dictionary() as AnyObject?
        }
        if let user = user {
            dict["userInfo"] = user.dictionary() as AnyObject?
        }
        var eventsList: [[String: AnyObject]] = []
        for update in events {
            eventsList.append(update.dictionary())
        }
        dict["events"] = eventsList as AnyObject
        dict["updateNeeded"] = updateNeeded as AnyObject

        return dict
    }

    /**
     For each update resolve status (by copying status of previous update aka no change)
     */
    func copyStatusForUpdates() {
        var status: Trash.Status = .stillHere
        for update in updates {
            if let s = update.status {
                status = s
            } else {
                update.status = status
            }
        }
    }

    /**
     Create or update cached Trash object from json data with caching
     */
    static func create(from json: [String: AnyObject], usingId id: Int? = nil) -> AnyObject {
        // Create new trash
        let trash = Trash()
        trash.parse(json: json)
        if let id = id {
            trash.id = id
        }
        trash.copyStatusForUpdates()
        return trash
    }
}

class TrashUpdateGalleryData {
    
    private var updates: [TrashUpdate]
    
    public lazy var images: [Image] = {
        return self.updates
            .map { $0.images }
            .reduce([], +)
    } ()
    
    public lazy var users: [User?] = {
        var users: [User?] = []
        self.updates.forEach { update in
            update.images.forEach { _ in
                users.append(update.user)
            }
        }
        return users
    } ()
    
    public lazy var updateTimes: [Date?] = {
        var updateTimes: [Date?] = []
        self.updates.forEach { update in
            update.images.forEach { _ in
                updateTimes.append(update.updateTime)
            }
        }
        
        return updateTimes
    } ()
    
    init(updates: [TrashUpdate]) {
        self.updates = updates
    }
    
    func getUpdate(forSelectedImageIndex index: Int) -> TrashUpdate {
        let image = self.images[index]
        let update = self.updates.filter { $0.images.contains(where: { $0 === image }) }.first!
        return update
    }
}

/**
 TrashPoint for simplified Trash without data, just to show location on map

 There is extra class to not confuse with filled Trash containing data
 */
class TrashPoint: JsonDecodable, Cachable {

    var coords: CLLocationCoordinate2D?
    var id: Int?
    var status: Trash.Status?
    var updateNeeded: Bool = false

    static func create(from json: [String: AnyObject], usingId _: Int?) -> AnyObject {
        let tc = TrashPoint()

        if let gps = json["gps"] as? [String: AnyObject],
            let lat = gps.double("lat"),
            let lng = gps.double("long") {
            tc.coords = CLLocationCoordinate2D.init(latitude: lat, longitude: lng)
        }
        tc.id = json["id"] as? Int
        if let status = json["status"] as? String {
            tc.status = Trash.Status(rawValue: status)
        }
        tc.updateNeeded = json["updateNeeded"] as? Bool ?? false
        return tc
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        guard let gps = self.coords else {
            return [:]
        }
        dict["id"] = id as AnyObject?
        var gpsDict: [String: AnyObject] = [:]

        gpsDict["long"] = gps.longitude as AnyObject?
        gpsDict["lat"] = gps.latitude as AnyObject?
        dict["gps"] = gpsDict as AnyObject?

        dict["status"] = status?.rawValue as AnyObject?

        return dict
    }
}

/**
 Grouped trashes according location
 */
class GeoCell: JsonDecodable, Cachable {

    var coords: CLLocationCoordinate2D?
    var geocell: String?

    var count: Int?
    var remains: Int?
    var cleaned: Int?
    var updateNeeded: Int?
    var trashes: [TrashPoint]?

    init() {}

    static func create(from json: [String: AnyObject], usingId _: Int?) -> AnyObject {
        
        let c = GeoCell()
        c.geocell = json["geocell"] as? String
        if let lat = json.double("lat"),
            let lng = json.double("long") {
            c.coords = CLLocationCoordinate2D.init(latitude: lat, longitude: lng)
        }
        if let counts = json["counts"] as? [String: AnyObject] {
            /**
             cleaned = 0;
             less = 0;
             more = 0;
             stillHere = 1;
             updateNeeded = 0;
             */
            let cleaned = counts["cleaned"] as? Int ?? 0
            let less = counts["less"] as? Int ?? 0
            let more = counts["more"] as? Int ?? 0
            let stillHere = counts["stillHere"] as? Int ?? 0
            let updateNeeded = counts["updateNeeded"] as? Int ?? 0
            
            c.remains = stillHere + less + more
            c.cleaned = cleaned
            c.updateNeeded = updateNeeded
            c.count = stillHere + less + more + cleaned
        }
        if let trashes = json["trashes"] as? [[String: AnyObject]] {
            var trashesArray: [TrashPoint] = []
            for t in trashes {
                let trash = TrashPoint.create(from: t, usingId: nil) as! TrashPoint
                trashesArray.append(trash)
            }
            c.trashes = trashesArray
        }
        return c
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        if let gps = self.coords {
            dict["long"] = gps.longitude as AnyObject?
            dict["lat"] = gps.latitude as AnyObject?
        }
        dict["geocell"] = self.geocell as AnyObject?

        var counts: [String: AnyObject] = [:]
        counts["cleaned"] = self.cleaned as AnyObject?
        counts["stillHere"] = self.remains as AnyObject?

        dict["counts"] = counts as AnyObject?

        if let trashes = trashes {
            var trashesArray: [[String: AnyObject]] = []
            for t in trashes {
                trashesArray.append(t.dictionary())
            }
            dict["trashes"] = trashesArray as AnyObject?
        }
        return dict
    }
}

extension Dictionary {

    /**
     Treat value for key as a double

     Supports Double, Int and String (with `.` decimal separator) conversion to Double
     */
    func double(_ key: Key) -> Double? {
        guard let value = self[key] else { return nil }
        if let d = value as? Double { return d }
        if let i = value as? Int { return Double(i) }
        if let s = value as? String {
            let nf = NumberFormatter()
            nf.decimalSeparator = "."
            return nf.number(from: s)?.doubleValue
        }
        return nil
    }
}
