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
     Get junkyard using id

     ```
     GET /collection-point/:id
     ```
     */
    func junkyard(_ id: Int, callback: @escaping (Junkyard?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
		UserManager.instance.tokenHeader { tokenHeader in
			Alamofire.request("\(self.apiBaseUrl)/collection-point/\(id)", headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(withId: id, response: response, callback: callback)
			}
		}
    }

    /**
     Get junkyards in area

     ```
     GET /collection-point/ ?
     position = :userPosition
     ```
     */
    func junkyards(position: CLLocationCoordinate2D, size: String?, type: [String]?, page: Int, callback: @escaping ([Junkyard]?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        let cacheKey = "junkyard/"
        // TODO: add parameters also to cache KEY, ignore location

        let positionString = "\(position.latitude),\(position.longitude)"
        var params: Parameters = [:]
        params["userPosition"] = positionString
        params["orderBy"] = "gps"
        params["attributesNeeded"] = ["id", "gpsFull", "types", "size", "note", "openingHours", "name", "phone", "email", "url"].joined(separator: ",")
		if let size = size, size != "all" {
        	params["collectionPointSize"] = size
		}
        params["collectionPointType"] = type?.joined(separator: ",")
        params["limit"] = 20
        params["page"] = page
		UserManager.instance.tokenHeader { tokenHeader in
			Alamofire.request("\(self.apiBaseUrl)/collection-point/", parameters: params, encoding: URLEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, cacheKey: cacheKey, callback: callback)
			}
		}
    }

	func junkyardReportSpam(_ junkyard: Junkyard, callback: @escaping (Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(NetworkingError.noInternetConnection)
            return
        }
        
        var params: Parameters = [:]
		params["collectionPointActivityId"] = junkyard.activityId
		UserManager.instance.tokenHeader { (tokenHeader) in
			Alamofire.request("\(self.apiBaseUrl)/spam/collection-point/", method: .post, parameters: params, headers: tokenHeader).responseJSON(completionHandler: { (response) in
				callback(response.result.error)
			})
		}
	}

}
