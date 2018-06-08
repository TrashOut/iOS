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
import Alamofire
import CoreLocation

extension Networking {


	/**
	List events

	```
	GET /event ?  page=:page & limit=:limit
	```
	*/
	func events(position: CLLocationCoordinate2D, limit: Int, callback: @escaping ([Event]?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
		var params: Parameters = [:]
		let date = try! Date().atTime(hour: 0, minute: 0, second: 0)
		let end = date.addDays(daysToAdd: 8)
		params["limit"] = limit
		params["orderBy"] = "gps"
		params["attributesNeeded"] = ["id", "name", "start", "gpsShort", "description"].joined(separator: ",")
		params["userPosition"] = "\(position.latitude),\(position.longitude)"
		params["startFrom"] = DateFormatter.zulu.string(from: date)
		params["startTo"] = DateFormatter.zulu.string(from: end)
		UserManager.instance.tokenHeader { tokenHeader in
			let req = Networking.manager.request("\(self.apiBaseUrl)/event", parameters: params, encoding: URLEncoding.default, headers: tokenHeader)
			print(req.debugDescription)
			req.responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, callback: callback)
			}
		}
	}

    /**
     Get event using id

     ```
     GET /event/:id
     ```
     */
    func event(_ id: Int, callback: @escaping (Event?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        UserManager.instance.tokenHeader { tokenHeader in
            Networking.manager.request("\(self.apiBaseUrl)/event/\(id)", headers: tokenHeader).responseJSON { [weak self] (response) in
                self?.callbackHandler(withId: id, response: response, callback: callback)
            }
		}
    }

    /*
    User joined cleaning event
    */
    func userJoinedEvent(_ eventId: Int, userId: Int, callback: @escaping (Trash?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        var params: Parameters = [:]
        params["userIds"] = userId
		UserManager.instance.tokenHeader { tokenHeader in
            Networking.manager.request("\(self.apiBaseUrl)/event/\(eventId)/users", method: .post, parameters: params, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
                self?.callbackHandler(response: response, callback: callback)
            }
		}
    }

    /*
    User creates event
	
	- Note: doesnt returns event nor trash
    */
    func createEvent(_ name: String, gps: Coordinates, description: String, start: String, duration: Int, bring: String, have: String, contact: Contact, trashPointsId: [Int]?, collectionPointIds: [Int], callback: @escaping (Trash?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        var params: Parameters = [:]
        params["name"] = name
        params["gps"] = ["lat": gps.lat, "long": gps.long, "accuracy": gps.accuracy, "source": gps.source]
        params["description"] = description
        params["start"] = start
        params["duration"] = duration
        params["have"] = have
        params["bring"] = bring
        params["contact"] = ["email": contact.email, "phone": contact.phone]
        params["trashPointIds"] = trashPointsId
        params["collectionPointIds"] = collectionPointIds
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/event/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, callback: callback)
			}
		}
    }

}
