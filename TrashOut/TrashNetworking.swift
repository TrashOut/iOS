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

extension TrashFilter {

	@discardableResult
	func filter(to params: inout Parameters) -> Parameters {
		if self.sizes.count > 0 {
			let sizes: [String] = self.sizes.map { (s) -> String in
				return s.rawValue
			}
			params["trashSize"] = sizes.joined(separator: ",")
		}
		if self.types.count > 0 {
			let types: [String] = self.types.map { (type) -> String in
				return type.rawValue
			}
			params["trashType"] = types.joined(separator: ",")
		}
		/*
		Filtr
		Cleaned (status=cleaned)
		Reported (status=stillHere nebo more nebo less a updateNeeded=false)
		UpdateNeeded (updateNeeded=true)
		Cleaned+Reported (updateNeeded=false)
		Cleaned+UpdateNeeded (status=cleaned)
		Reported+UpdateNeeded (status=stillHere, more nebo less)
		*/
		var states: [String] = []

		// Cleaned (status=cleaned)
		if status[.cleaned] == true {
			states.append("cleaned")
		}
		// Reported (status=stillHere,more,less&updateNeeded=0)
		if status[.reported] == true {
			states.append("more")
			states.append("less")
			states.append("stillHere")
			params["updateNeeded"] = false
		}
		// UpdateNeeded (updateNeeded=true)
		if status[.updateNeeded] == true {
			params["updateNeeded"] = true
		}
		// Cleaned + Reported (updateNeeded = false)
		if status[.cleaned] == true, status[.reported] == true {
			params["updateNeeded"] = false
		}
		// Cleaned + updateNeeded (status=cleaned)
		if status[.cleaned] == true, status[.updateNeeded] == true, status[.reported] == false {
			states = ["cleaned"]
			params.removeValue(forKey: "updateNeeded")
			//params["updateNeeded"] = false
		}
		if status[.reported] == true, status[.updateNeeded] == true, status[.cleaned] == true {
			params.removeValue(forKey: "updateNeeded")
		}

		params["trashStatus"] = states.joined(separator: ",")

		if let lu = self.lastUpdate {
			params["timeBoundaryFrom"] = DateFormatter.zulu.string(from: lu.date)
			params["timeBoundaryTo"]  = DateFormatter.zulu.string(from: Date())
		}

		var access: [String] = []
		if let byCar = accessibility.byCar, byCar == true {
			access.append("byCar")
		}
		if let inCave = accessibility.inCave, inCave == true {
			access.append("inCave")
		}
		if let underWater = accessibility.underWater, underWater == true {
			access.append("underWater")
		}
		if let nfgc = accessibility.notForGeneralCleanup, nfgc == true {
			access.append("notForGeneralCleanup")
		} 
		params["trashAccessibility"] = access.joined(separator: ",")

		return params
	}
}


extension Networking {

	/**
	Get trash using id

	```
	GET /trash/:id
	```
	*/
	func trash(_ id: Int, callback: @escaping (Trash?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
		var params: Parameters = [:]
        //let testId = 31516
		params["attributesNeeded"] = ["id", "accessibility", "anonymous", "cleanedByMe", "created", "activityCreated" , "events", "gps", "images", "note", "size", "status", "types", "updateHistory", "updateNeeded", "url", "userInfo"].joined(separator: ",")
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/trash/\(id)", parameters: params, encoding: URLEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(withId: id, response: response, callback: callback)
			}
		}
	}

	/**
	Get trashes by user position

	```
	GET /trash/ ?
		position = :userPosition
	```
	*/
    func trashes(position: CLLocationCoordinate2D, status: [String]?, size: String?, type: [String]?, timeTo: String?, timeFrom: String?, limit: Int, page: Int, callback: @escaping ([Trash]?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
		let cacheKey = "trash/"
		// TODO: add parameters also to cache KEY, ignore location
		let positionString = "\(position.latitude),\(position.longitude)"
        var params: Parameters = [:]
        params["userPosition"] = positionString
        params["orderBy"] = "gps"
        params["attributesNeeded"] = ["id", "gpsShort", "types", "created", "status", "images"].joined(separator: ",")
        params["trashSize"] = size
        params["trashType"] = type?.joined(separator: ",")
        params["trashStatus"] = status
        params["timeBoundaryTo"] = timeTo
        params["timeBoundaryFrom"] = timeFrom
        params["limit"] = limit
        params["page"] = page
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/trash/", parameters: params, encoding: URLEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, cacheKey: cacheKey, callback: callback)
			}
		}
    }

	func trashes(position: CLLocationCoordinate2D, filter: TrashFilter, limit: Int, page: Int, callback: @escaping ([Trash]?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
		let cacheKey = "trash/"
		// TODO: add parameters also to cache KEY, ignore location
		let positionString = "\(position.latitude),\(position.longitude)"
		var params: Parameters = [:]
		params["userPosition"] = positionString
		params["orderBy"] = "gps"
        params["attributesNeeded"] = ["id", "accessibility", "anonymous", "cleanedByMe", "created", "events","gpsShort", "images", "note", "size", "status", "types", "updateHistory", "updateNeeded", "url", "userInfo"].joined(separator: ",")
		//params["attributesNeeded"] = ["id", "gpsShort", "types", "created", "status", "images", "updateNeeded", "updateHistory", "anonymous", "cleanedByMe", "userInfo"].joined(separator: ",")
		filter.filter(to: &params)
		params["limit"] = limit
		params["page"] = page
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/trash/", parameters: params, encoding: URLEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, cacheKey: cacheKey, callback: callback)
			}
		}
	}

	/**
	Get trash list in position with given distance
	*/
	func trashes(position: CLLocationCoordinate2D, area: CLLocationDistance, filter: TrashFilter?, limit: Int, page: Int, callback: @escaping ([Trash]?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
		let cacheKey = "trash/"
		// TODO: add parameters also to cache KEY, ignore location
		let positionString = "\(position.latitude),\(position.longitude)"
		var params: Parameters = [:]
		params["userPosition"] = positionString
		params["orderBy"] = "gps"
		params["attributesNeeded"] = ["id", "gpsShort", "types", "created", "status", "images"].joined(separator: ",")
		let area = LocationManager.manager.area(around: position, withDistance: area/1000)
		params["area"] = "\(area.topLeft.latitude),\(area.topLeft.longitude),\(area.bottomRight.latitude),\(area.bottomRight.longitude)"
		filter?.filter(to: &params)
		params["limit"] = limit
		params["page"] = page
		UserManager.instance.tokenHeader { tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/trash/", parameters: params, encoding: URLEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, cacheKey: cacheKey, callback: callback)
			}
		}
	}


	/**
	Get trashes count in area around position

	```
	GET /trash/count/ ?
     position = :userPosition
	```
	*/
	func trashesCount(position: CLLocationCoordinate2D, distance: CLLocationDistance, callback: @escaping (Int?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        let positionString = "\(position.latitude),\(position.longitude)"
        var params: Parameters = [:]
		let area = LocationManager.manager.area(around: position, withDistance: distance/1000)
        params["userPosition"] = positionString
		params["area"] = "\(area.topLeft.latitude),\(area.topLeft.longitude),\(area.bottomRight.latitude),\(area.bottomRight.longitude)"
		UserManager.instance.tokenHeader { tokenHeader in
            Networking.manager.request("\(self.apiBaseUrl)/trash/count/", parameters: params, encoding: URLEncoding.default, headers: tokenHeader).responseJSON { (response) in
                print(response.debugDescription)
                if response.result.isFailure {
                    callback(nil, response.result.error)
                }
                else if let data = response.result.value as? [String: AnyObject] {
                    callback(data["count"] as? Int, nil)
                } else {
                    callback(nil, nil)
                }
            }
		}
	}

	/**
	Get trashes count in area with status
	
	```
	GET /trash/count/ ? :area.type = :area.typeValue & trashStatus = :status
	```
	*/
	func trashesCount(area: Area?, status: [String], callback: @escaping (Int?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
		var params: Parameters = [:]
		if let area = area {
			params["geoArea" + area.type.rawValue.uppercaseFirst] = area.typeValue
		}
		params["trashStatus"] = status.joined(separator: ",")
        UserManager.instance.tokenHeader { [unowned self] tokenHeader in
            Networking.manager.request("\(self.apiBaseUrl)/trash/count/", parameters: params, encoding: URLEncoding.default, headers: tokenHeader).responseJSON { (response) in
                print(response.debugDescription)
                if response.result.isFailure {
                    callback(nil, response.result.error)
                }
                else if let data = response.result.value as? [String: AnyObject] {
                    callback(data["count"] as? Int, nil)
                } else {
                    callback(nil, nil)
                }
            }
        }
	}


    /*
    User creates trash
    */
    func createTrash(_ images: [DumpsImages], gps: Coordinates, size: String, type: [String], note: String?, anonymous: Bool, userId: Int, accessibility: DumpsAccessibility, callback: @escaping (Trash?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        var params: Parameters = [:]

        var image = [Parameters]()
        for i in 0...images.count - 1 {
            image.append(["fullDownloadUrl": images[i].fullDownloadUrl, "fullStorageLocation": images[i].storageLocation, "thumbDownloadUrl": images[i].thumbDownloadUrl, "thumbStorageLocation": images[i].thumbStorageLocation ])
        }
        params["images"] = image
        params["gps"] = ["lat": gps.lat, "long": gps.long, "accuracy": gps.accuracy, "source": gps.source]
        params["size"] = size
        params["types"] = type
        params["note"] = note
        params["anonymous"] = anonymous
        params["userId"] = userId
        params["accessibility"] = ["byCar": accessibility.byCar, "inCave": accessibility.inCave, "underWater": accessibility.underWater, "notForGeneralCleanup": accessibility.notForGeneralCleanup]

		UserManager.instance.tokenHeader { [unowned self] tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/trash/", method: .post, parameters: params, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, callback: callback)
			}
		}
    }

    /*
    User updates trash
    */
    func updateTrash(_ trashId: Int, images: [DumpsImages], gps: Coordinates, size: String, type: [String], note: String?, anonymous: Bool, userId: Int, accessibility: DumpsAccessibility, status: String, cleanedByMe: Bool, callback: @escaping (Trash?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        var params: Parameters = [:]
        var image = [Parameters]()
        for i in 0...images.count - 1 {
             image.append(["fullDownloadUrl": images[i].fullDownloadUrl, "fullStorageLocation": images[i].storageLocation, "thumbDownloadUrl": images[i].thumbDownloadUrl, "thumbStorageLocation": images[i].thumbStorageLocation ])
        }
        params["images"] = image
        params["gps"] = ["lat": gps.lat, "long": gps.long, "accuracy": gps.accuracy, "source": gps.source]
        params["size"] = size
        params["types"] = type
        params["note"] = note
        params["anonymous"] = anonymous
        params["userId"] = userId
        params["accessibility"] = ["byCar": accessibility.byCar, "inCave": accessibility.inCave, "underWater": accessibility.underWater, "notForGeneralCleanup": accessibility.notForGeneralCleanup]
        params["status"] = status
        params["cleanedByMe"] = cleanedByMe
		UserManager.instance.tokenHeader { [unowned self] tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/trash/\(trashId)", method: .put, parameters: params, encoding: JSONEncoding.default, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, callback: callback)
			}
		}
    }

    /*
    Send report about dumps spam
    */
    func reportSpam(_ trashId: Int, userId: Int, callback: @escaping (Trash?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        var params: Parameters = [:]
        params["trashPointActivityId"] = trashId
        //params["userId"] = userId
		UserManager.instance.tokenHeader { [unowned self] tokenHeader in
			Networking.manager.request("\(self.apiBaseUrl)/spam/trash", method: .post, parameters: params, headers: tokenHeader).responseJSON { [weak self] (response) in
				self?.callbackHandler(response: response, callback: callback)
			}
		}
    }

	/**
	Zoom point for trash map with zoomlevel <= 9

	Doesn't cache content, should implement cache in higher level
	*/
	func zoompoints(geocells: [String], zoom: Int, filter: TrashFilter, callback: @escaping ([GeoCell]?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        var params: Parameters = [:]
        params["zoomLevel"] = zoom
        params["geocells"] = geocells.joined(separator: ",")
		filter.filter(to: &params)
        UserManager.instance.tokenHeader { [unowned self] tokenHeader in
            Networking.manager.request("\(self.apiBaseUrl)/trash/zoom-point/", parameters: params, encoding: URLEncoding.default, headers: tokenHeader).responseJSON { (response) in
                self.logLongResponseTime(response)
                self.callbackHandler(response: response, cachingEnabled: false, callback: callback)
            }
        }
	}

	/**
	Trashes for geocells with zoom > 9

	Doesn't cache content, should implement cache in higher level
	*/
	func trashes(for geocells: [String], zoomLevel: Int, filter: TrashFilter, callback: @escaping ([TrashPoint]?, Error?) -> ()) {
        guard Networking.isConnectedToInternet else {
            callback(nil, NetworkingError.noInternetConnection)
            return
        }
        
        var params: Parameters = [:]
		params["zoomLevel"] = zoomLevel
        params["geocells"] = geocells.joined(separator: ",")
        params["attributesNeeded"] = ["id", "gpsShort", "updateNeeded", "status"].joined(separator: ",")
		filter.filter(to: &params)
        UserManager.instance.tokenHeader { [unowned self] tokenHeader in
            Networking.manager.request("\(self.apiBaseUrl)/trash/", parameters: params, encoding: URLEncoding.default,  headers: tokenHeader).responseJSON { (response) in
                self.logLongResponseTime(response)
                self.callbackHandler(response: response, cachingEnabled: false, callback: callback)
            }
        }
	}
    
}
