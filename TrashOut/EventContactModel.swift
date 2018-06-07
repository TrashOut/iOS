//
//  EventContactModel.swift
//  TrashOut-Prod
//
//  Created by Grünvaldský Dávid on 31/05/2018.
//  Copyright © 2018 TrashOut NGO. All rights reserved.
//

import Foundation
import Cache

class EventContact: JsonDecodable, Cachable {
    typealias CacheType = EventContact
    
    var email: String?
    var name: String?
    var occupation: String?
    var phone: String?
    
    init() {}
}

// MARK: - Lifecycle

extension EventContact {
    func parse(json: [String: AnyObject]) {
        email <== json["email"]
        name <== json["name"]
        occupation <== json["occupation"]
        phone <== json["phone"]
    }
    
    static func create(from json: [String: AnyObject], usingId id: Int?) -> AnyObject {
        // Create new obj
        let contact = EventContact()
        contact.parse(json: json)
        return contact
    }
    
    func dictionary() -> [String: AnyObject] {
        var json: [String: AnyObject] = [:]

        json["email"]      = email as AnyObject?
        json["name"]       = name as AnyObject?
        json["occupation"] = occupation as AnyObject?
        json["phone"]      = phone as AnyObject?

        return json
    }
}


