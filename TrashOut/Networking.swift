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
import Cache
import FirebaseAnalytics

/**
Create object from json dictionary

Give id if specified for request, nil otherwise
*/
public protocol JsonDecodable {

	static func create (from json: [String: AnyObject], usingId id: Int?) -> AnyObject

	func dictionary() -> [String: AnyObject]

}

/**
Access trashout API at api.trashout.ngo

API documentation is at http://docs.trashout.apiary.io
*/
class Networking {

	#if STAGE
		var apiBaseUrl = "https://dev-api.trashout.ngo/v1"
	#else
		var apiBaseUrl = "https://api.trashout.ngo/v1"
	#endif

	static var instance: Networking = {
		return Networking()
	} ()

    internal static var manager: Alamofire.SessionManager = {
        
        // Create the server trust policies
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            "dev-api.trashout.ngo": .pinCertificates(
//                certificates: ServerTrustPolicy.certificates(in: Bundle.main),
//                validateCertificateChain: true,
//                validateHost: true),
            "dev-api.trashout.ngo": .disableEvaluation,
            "api.trashout.ngo": .disableEvaluation
        ]
        
        // Create custom manager
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 10
        
        let manager = Alamofire.SessionManager(
                        configuration: configuration,
                        serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        
        return manager
    }()
    
    /// Is device connected to Internet
    internal static var isConnectedToInternet: Bool {
        return Reachability.isConnectedToNetwork() || Reachability.isConnectedToCellularNetwork()
    }
    
	init() {
		setupCache()
		// Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10

	}

	// MARK: - Helpers


	/**
	Error for unexpected data response
	*/
	static var parseError: Error {
		get {
			let error = NSError.init(domain: "trashout", code: 500, userInfo: [
				NSLocalizedDescriptionKey: "API Error".localized
				])
			return error
		}
	}
    
	// MARK: - Cache

	var cache : HybridCache?

	func setupCache() {
		let expiryDays: Double = 28
		let size: UInt = 10000000
		let config = Config.init(
			frontKind: .memory,
			backKind: .disk,
			expiry: .seconds(60*60*24*expiryDays),
			maxSize: size,
			maxObjects: Int(size)
		)
		cache = HybridCache(name: "NetworkCache", config: config)
	}
	
	/**
	Load object from cache
	*/
	func loadFromCache<T>
		(key: String, dueTo error: Error?, callback: @escaping (T?, Error?)->())
		where T: Cachable {
			#if DEBUG
				print("Loading from cache using: \(key)")
			#endif
			cache?.object(key, completion: { (object: T?) -> () in
				if let value = object {
					DispatchQueue.main.async(execute: {
						callback(value, nil)
					})
				}
				else {
					DispatchQueue.main.async(execute: {
						callback(nil, error)
					})
				}
			})
	}

	/**
	Load list of object from cache
	*/
	func loadFromCache<T>
        (key: String, dueTo error: Error?, callback: @escaping ([T]?, Error?)->())
		where T: Cachable, T: JsonDecodable {
			#if DEBUG
			print("Loading from cache using: \(key)")
			#endif
			cache?.object(key, completion: { (json: JSON?) -> () in
				if let list = json?.object as? [[String: AnyObject]] {
					var objects : [T] = []
					for dict in list {
						if let obj = T.create(from: dict, usingId: nil) as? T {
							objects.append(obj)
						}
					}
					DispatchQueue.main.async(execute: {
						callback(objects, nil)
					})
				}
				else {
					DispatchQueue.main.async(execute: {
						callback(nil, error)
					})
				}
			})
	}

	/**
	Store list into cache
	*/
	func cacheList<T>
		(key: String, list: [T])
		where T: Cachable, T: JsonDecodable {

        var dataList: [[String: AnyObject]] = []
		for obj in list {
			let dict = obj.dictionary()
			dataList.append(dict)
		}
		cache?.add(key, object: JSON.array(dataList) )
	}

	// MARK: - Error handling

	/**
	Load from cache for network error, else propagate error
	*/
	func resolveFailure<T>
		(response: DataResponse<Any>,
		 cachingEnabled: Bool = true,
		 cacheKey: String? = nil,
		 callback: @escaping (T?, Error?)->()
		) where T: Cachable {

		if cachingEnabled, let error = response.result.error, error.isNetworkConnectionError {
			if let cacheKey = (cacheKey ?? response.request?.url?.absoluteString) {
				self.loadFromCache(key: cacheKey, dueTo: response.result.error, callback: callback)
				return
			}
		}
		callback(nil, response.result.error)
	}

	/**
	Load from cache for network error, else propagate error
	*/
	func resolveFailure<T>
		(response: DataResponse<Any>,
		 cachingEnabled: Bool = true,
		 cacheKey: String? = nil,
		 callback: @escaping ([T]?, Error?)->()
		) where T: Cachable, T:JsonDecodable {

			if cachingEnabled, let error = response.result.error, error.isNetworkConnectionError {
				if let cacheKey = (cacheKey ?? response.request?.url?.absoluteString) {
					self.loadFromCache(key: cacheKey, dueTo: response.result.error, callback: callback)
					return
				}
			}
            if let error = response.result.error as NSError?, error.code == 1009 {
                callback(nil, NSError.fetch)
            } else {
                callback(nil, response.result.error)
            }
	}
	
	// MARK: - Default Callbacks
	
	/**
	Callback to create Object from response
	*/
	func callbackHandler<T>
		(withId id: Int? = nil,
		 response: DataResponse<Any>,
		 cachingEnabled: Bool = true,
		 cacheKey: String? = nil,
		 callback: @escaping (T?, Error?)->()
		) where  T: JsonDecodable, T: Cachable {

		#if DEBUG
			self.showRawData(response)
		#endif
		if response.result.isFailure {
			self.resolveFailure(response: response, cacheKey: cacheKey, callback: callback)
		} else {
			guard let json = response.result.value as? [String: AnyObject] else {

				#if DEBUG
					self.debugPrint(response)
				#endif
				let error = Networking.parseError
				callback(nil, error)
				return
			}
			if let errorJson = json["error"] as? [String: AnyObject] {
				#if DEBUG
					print(errorJson)
				#endif
				let error = NSError.init(domain: "cz.trashout", code: 500, userInfo: [
					NSLocalizedDescriptionKey: "global.error.api.text".localized
					])
				callback(nil, error as Error)
				return
			}
			guard let obj = T.create(from: json, usingId: id) as? T else {
				let error = Networking.parseError
				callback(nil, error)
				return
			}
			if cachingEnabled {
				if let cacheKey = (cacheKey ?? response.request?.url?.absoluteString) {
					cache?.add(cacheKey, object: obj)
				}
			}
			callback(obj, nil)
		}
	}

	/**
	Callback to create list of objects from reponse
	*/
	func callbackHandler<T>
		(response: DataResponse<Any>,
		 cachingEnabled: Bool = true,
		 cacheKey: String? = nil,
		 callback: @escaping ([T]?, Error?)->()
		) where  T: JsonDecodable, T: Cachable {

		#if DEBUG
			self.showRawData(response)
		#endif
		if response.result.isFailure {
			self.resolveFailure(response: response, cachingEnabled: cachingEnabled, cacheKey: cacheKey, callback: callback)
		} else {
			if let json = response.result.value as? [String: AnyObject] {
				if let errorJson = json["error"] as? [String: AnyObject] {
					#if DEBUG
					print(errorJson)
					#endif
					let error = NSError.init(domain: "cz.trashout", code: 500, userInfo: [
						NSLocalizedDescriptionKey: "global.error.api.text".localized
						])
					callback(nil, error as Error)
					return
				}
			}
			guard let json = response.result.value as? [AnyObject] else {
				#if DEBUG
					self.debugPrint(response)
				#endif
				let error = Networking.parseError
				callback(nil, error)
				return
			}
			var list: [T] = []
			for data in json {
				if let dataAsJson = data as? [String: AnyObject] {
					if let obj = T.create(from: dataAsJson, usingId: nil) as? T {
						list.append(obj)
					}
				}
			}
			if cachingEnabled {
				if let cacheKey = (cacheKey ?? response.request?.url?.absoluteString) {
					self.cacheList(key: cacheKey, list: list)
				}
			}
			callback(list, nil)
		}

	}

    // MARK: - Debug helpers

	/**
	Print out response.data to console as raw string,
 	suggested use in `#if DEBUG` section only
	*/
	func showRawData(_ response: DataResponse<Any>) {
		print(response.debugDescription)
		guard let _ = response.result.value as? [String: AnyObject] else {
			if let data = response.data {
				guard let string = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue) else { return }
				
				print(string)
			}
			return
		}
	}

	#if DEBUG
	func debugPrint(_ response: DataResponse<Any>) {
		print("-------")
		print("Failed to parse data for: \n\(response.request.debugDescription)\n\n")
		print(response.debugDescription)
		print("-------")
	}
	#endif

	func logLongResponseTime(_ response: DataResponse<Any>) {
		print(response.timeline)
		let duration = response.timeline.requestDuration
		guard duration > 0.5 else {return}

		let coords = LocationManager.manager.currentLocation.coordinate
		let loc = "\(coords.longitude),\(coords.latitude)"
		let request = response.request.debugDescription

        Analytics.logEvent("Long_request_duration", parameters: [
			"location": loc as NSString,
			"request": request as NSString,
			"duration": "\(duration)" as NSString,
			"response": "\(response.response?.statusCode ?? 0)" as NSString
		])
	}
	
}

extension Error {

	/**
	Check if error network connection problem case
	*/
	var isNetworkConnectionError: Bool {
		let networkErrors = [
			NSURLErrorNetworkConnectionLost,
			NSURLErrorNotConnectedToInternet,
			NSURLErrorCannotFindHost,
			NSURLErrorTimedOut,
			NSURLErrorCannotConnectToHost,
			NSURLErrorInternationalRoamingOff,
			NSURLErrorHTTPTooManyRedirects
		]
		let e = self as NSError
		if e.domain == NSURLErrorDomain && networkErrors.contains(e.code) {
			return true
		}
		return false
	}

}
