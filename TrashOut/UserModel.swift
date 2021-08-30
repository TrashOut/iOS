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

class User: JsonDecodable, Cachable {

    struct Stats {
        var reported: Int = 0
        var updated: Int = 0
        var cleaned: Int = 0
    }

    enum ReportAsType {

        case anonymous
        case personal(name: String)
        case organisation(organisation: Organization)

        var title: String {
            switch self {
            case .anonymous: return "trash.anonymous".localized
            case .organisation(organisation: let organisation): return organisation.name
            case .personal(name: let name): return name
            }
        }

        var isAnonymous: Bool {
            switch self {
            case .anonymous: return true
            default: return false
            }
        }

    }

    static func create(from json: [String: AnyObject], usingId id: Int? = nil) -> AnyObject {
        // Create new entity
        let user = User()
        user.parse(json: json)
        //let resolvedId: Int? = id ?? json["id"] as? Int
        //user.id = resolvedId ?? 0
        return user
    }

    // MARK: - Properties

    var id: Int = 0
    var firstName: String?
    var lastName: String?
    var email: String?
    var registered: Date?
    var organizations: [Organization] = []
    var points: Int?
    var image: Image?
    var uid: String?
    var token: String?
    var phone: String?
    var eventOrganizer: Bool = false
    var newsletter: Bool = false
    var volunteerCleanup: Bool = false
    var stats: Stats = Stats()

    var badges: [Badge] = []
    var areas: [Area] = []

    // MARK: - Lifecycle

    init() {}

    func parse(json: [String: AnyObject]) {
        id = json["id"] as? Int ?? Int(json["id"] as? String ?? "0") ?? id
        firstName = json["firstName"] as? String
        lastName = json["lastName"] as? String
        email = json["email"] as? String
        if let rd = json["created"] as? String {
            registered = DateFormatter.utc.date(from: rd)
        }
        
        let rawPoints = json["points"] as? String
        points = rawPoints != nil ? Int(rawPoints!) : nil
        
        if let img = json["image"] as? [String: AnyObject] {
            image = Image.create(from: img, usingId: nil) as? Image
        }
        uid = json["uid"] as? String
        phone = json["phoneNumber"] as? String
        eventOrganizer = json["eventOrganizer"] as? Bool ?? false
        newsletter = json["newsletter"] as? Bool ?? false
        volunteerCleanup = json["volunteerCleanup"] as? Bool ?? false

        if let stats = json["stats"] as? [String: AnyObject] {
            self.stats.reported = Int(stats["reported"] as? String ?? "0") ?? 0
            self.stats.updated = Int(stats["updated"] as? String ?? "0") ?? 0
            self.stats.cleaned = Int(stats["cleaned"] as? String ?? "0") ?? 0
        }
        for badge in json["badges"] as? [[String: AnyObject]] ?? [] {
            if let b = Badge.create(from: badge, usingId: nil) as? Badge {
                self.badges.append(b)
            }
        }
        for a in json["areas"] as? [[String: AnyObject]] ?? [] {
            if let area = Area.create(from: a, usingId: nil) as? Area {
                self.areas.append(area)
            }
        }
		self.organizations <== json["organizations"]
    }

    func dictionary() -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        dict["firstName"] = firstName as AnyObject?
        dict["lastName"] = lastName as AnyObject?
        dict["points"] = points as AnyObject?
        dict["email"] = email as AnyObject?
        if let image = image {
            dict["image"] = image.dictionary() as AnyObject?
        }
        dict["uid"] = uid as AnyObject?
        dict["phoneNumber"] = phone as AnyObject?
        dict["eventOrganizer"] = eventOrganizer as AnyObject?
        dict["newsletter"] = newsletter as AnyObject?

        var stats: [String: AnyObject] = [:]
        stats["reported"] = self.stats.reported as AnyObject?
        stats["updated"] = self.stats.updated as AnyObject?
        stats["cleaned"] = self.stats.cleaned as AnyObject?
        dict["stats"] = stats as AnyObject?

        var badges: [[String: AnyObject]] = []
        for b in self.badges {
            badges.append(b.dictionary())
        }
        dict["badges"] = badges as AnyObject?
        var areas: [[String: AnyObject]] = []
        for a in self.areas {
            areas.append(a.dictionary())
        }
        dict["areas"] = areas as AnyObject?

		var orgs: [[String: AnyObject]] = []
		for o in organizations {
			orgs.append(o.dictionary())
		}
		dict["organizations"] = orgs as AnyObject?
        return dict
    }

}

// MARK: - Computed Properties

extension User {

    var displayName: String {
        if let fn = firstName, let ln = lastName {
            return "\(fn) \(ln)"
        }
        if let fn = firstName {
            return fn
        }
        if let ln = lastName {
            return ln
        }
        return "trash.anonymous".localized
    }

    var displayFirstName: String {
        if let fn = firstName {
            return fn
        }
        return "trash.anonymous".localized
    }

    var level: Int {
        guard let points = points else { return 0 }
        var a: Int = 0
        var b: Int = 1
        var c: Int = 0
        var index: Int = -1
        repeat {
            c = a + b
            a = b
            b = c
            index += 1
        } while (c <= (points/10))
        return index
    }

    var fullName: String {
        guard firstName != nil && lastName != nil else { return "" }

        return (firstName ?? "") + " " + (lastName ?? "")
    }

    var reportTypes: [ReportAsType] {
        var result = [ReportAsType]()

        if !fullName.isEmpty {
            result.append(.personal(name: fullName))
        }
        result.append(.anonymous)

        let relevantOrganisations = organizations.filter { ($0.organizationRoleId ?? "") == "1" }
        result.append(contentsOf: relevantOrganisations.map { .organisation(organisation: $0) })

        return result
    }

}

class Badge: JsonDecodable, Cachable {

    func dictionary() -> [String: AnyObject] {
        return [:]
    }

    static func create(from _: [String: AnyObject], usingId _: Int?) -> AnyObject {
        return Badge()
    }
}



