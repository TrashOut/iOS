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
import CoreLocation

/**
Single access class for user location

Requests authorization if needed and loads current location on refresh call

Last fetched location is stored in `currentLocation` property

If location cannot be determined uses `defaultLocation` as current
*/
open class LocationManager: NSObject, CLLocationManagerDelegate {

	// MARK: - Public methods

	/// Singleton for resolving user location
	open static var manager = LocationManager()

	/**
	Default location to use if user's cannot be determined
	*/
	open var defaultLocation: CLLocation = CLLocation.init(latitude: 0, longitude: 0) // Center of universe?

    var locationTimestamp: Date?

	/// Needs refresh after 5 minutes by default
	///
	/// Just marks flag, no timer is set
	open var refreshInterval: TimeInterval = 5*60
	open var locationNeedsRefresh: Bool {
		get {
			guard let lastTimestamp = locationTimestamp else { return true }
			return lastTimestamp.addingTimeInterval(60*10) < Date()
		}
	}

	/**
	Current user location last fetched, or use default location if not determined
	*/
	open var currentLocation: CLLocation {
		get {
			if let location = lastFethedLocation {
				return location
			} else {
				return defaultLocation
			}
		}
		set (newValue) {
			self.lastFethedLocation = newValue
			self.locationTimestamp = newValue.timestamp
		}
	}

	/**
	Any location was already received (location was set any time in past)
	*/
	open var fetchedAnyLocation: Bool {
		return locationTimestamp != nil
	}

	/**
	Reload current user location if needed, callback is alwayes called
	*/
	open func refreshCurrentLocationIfNeeded(_ callback: @escaping (CLLocation) -> Void) {
		if locationNeedsRefresh {
			//self.processCallback()
			self.callback = callback
			self.startManagerForLocationUpdates()
		} else {
			callback(self.currentLocation)
		}
	}

	/**
	Reload current user location, callback is alwayes called
	*/
	open func refreshCurrentLocation(_ callback: @escaping (CLLocation) -> Void) {
		//self.processCallback()
		self.callback = callback
		self.startManagerForLocationUpdates()
	}

	/**
	Get area rect (top left and bottom right points)

	Approximation according:
	http://stackoverflow.com/questions/1253499/simple-calculations-for-working-with-lat-lon-km-distance

	The approximate conversions are:
	Latitude: 1 deg = 110.574 km
	Longitude: 1 deg = 111.320*cos(latitude) km

	- Parameter distance: distance in km
	*/
	open func area(around point: CLLocationCoordinate2D, withDistance distance: Double) -> (topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) {
		let latitude = point.latitude
		let longitude = point.longitude
		
		let latOneDgrDist: Double = 110.574
		let lngOneDgrDist: Double = 111.320*cos(latitude)
		
		let topLeft = CLLocationCoordinate2DMake(latitude - distance/latOneDgrDist, longitude - distance/lngOneDgrDist)
		let bottomRight = CLLocationCoordinate2DMake(latitude + distance/latOneDgrDist, longitude + distance/lngOneDgrDist)
		
		return (topLeft: topLeft, bottomRight: bottomRight)
	}

	open func area(around point: CLLocationCoordinate2D, withSpan span: (lat: Double, lng: Double)) -> (topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D) {
		let latitude = point.latitude
		let longitude = point.longitude
		let topLeft = CLLocationCoordinate2DMake(latitude - span.lat, longitude - span.lng)
		let bottomRight = CLLocationCoordinate2DMake(latitude + span.lat, longitude + span.lng)
		
		return (topLeft: topLeft, bottomRight: bottomRight)
	}

	/**
	Resolve area names for location
	*/
    func resolveName(for location: CLLocation, callback: @escaping (CLPlacemark?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(location) { (marks, error) in
            guard let mark = marks?.first else {
				callback(nil)
				return
			}

            // mark.country
            // mark.administrativeArea
            // mark.locality
            // mark.name

            callback(mark)
        }
    }

	// MARK: - CoreLocation processing

	/// CoreLocation manager for location updates
	fileprivate let locationManager: CLLocationManager = CLLocationManager()
	/// Callback for granting permissions to use location
	fileprivate var authorizationBlock: ((_ status: CLAuthorizationStatus) -> Void)?
	/// Last resolved location
	fileprivate var lastFethedLocation: CLLocation?
	/// If there was error resolving location, there it is
	fileprivate var lastError: NSError?
	/// Accuracy needed for resolving location
	fileprivate var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyThreeKilometers
	/// Callback for refresh method to be called after location is defined
	fileprivate var callback: ((CLLocation)->Void)?

	fileprivate override init() {
		super.init()
		locationManager.delegate = self
	}

	/**
	Do the callback when location was found (or not)
	*/
	fileprivate func processCallback() {
		if let callback = self.callback {
			self.callback = nil
			callback(currentLocation)
		}
	}

	/**
	Start to listen for location changes
	*/
	fileprivate func startManagerForLocationUpdates() {
		self.processLocationUsageAuthorization( { [weak self] _ in
            
			self?.locationManager.startUpdatingLocation()

			}, failure: { [weak self] _ in
				self?.processCallback()
            })
	}

	/**
	Request authorization to use location
	*/
	fileprivate func processLocationUsageAuthorization(_ success: @escaping () -> Void, failure: @escaping () -> Void) {
		// set location manager params according to the best presition of all requests
		if CLLocationManager.authorizationStatus() == .notDetermined {
			// check which perms should ask according to the plist config
            // NSLocationAlwaysAndWhenInUseUsageDescription
            // NSLocationWhenInUseUsageDescription
            // NSLocationAlwaysUsageDescription
			if (Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil) {
                self.requestAlwaysAuthorization({ (status) in
                    if status == .authorizedAlways {
                        success()
                    } else {
                        failure()
                    }
                })
			} else if (Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil) {
                self.requestWhenInUseAuthorization({ (status) in
                    if status == .authorizedWhenInUse {
                        success()
                    } else {
                        failure()
                    }
                })
			}

		} else if (CLLocationManager.authorizationStatus() == .denied)||(CLLocationManager.authorizationStatus() == .restricted) {
			failure()
		} else {
			success()
		}
	}

	/**
	Ask user for location traking while the app is in use, when the user answer, the AuthorizationBlock is executed

	- parameter block: blok Instance of AuthorizationBlock
	*/
	fileprivate func requestWhenInUseAuthorization(_ block: @escaping (_ status: CLAuthorizationStatus) -> Void) {
		self.authorizationBlock = block
		self.locationManager.requestWhenInUseAuthorization()
	}

	/**
	Ask user for location traking while the app is in use or in background, when the user answer, the AuthorizationBlock is executed

	- parameter block: blok Instance of AuthorizationBlock
	*/
	fileprivate func requestAlwaysAuthorization(_ block: @escaping (_ status: CLAuthorizationStatus) -> Void) {
		self.authorizationBlock = block
		self.locationManager.requestAlwaysAuthorization()
	}

	/**
	When authorization status change, report using the AuthorizationBlock
	
	- parameter manager: instance of CLLocationManager
	- parameter status:  CLAuthorizationStatus status
	*/
	open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if let block: (_ status: CLAuthorizationStatus) -> Void = self.authorizationBlock {
			block(status)
		}
	}

	/**
	Report failure to all active location request

	- parameter manager: instance of CLLocationManager
	- parameter error:   instance of NSError
	*/
	open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		self.lastError = error as NSError?

		print(error.localizedDescription)
	}

	/**
	Report location update to all active request, if all request are finished stop the location tracking
	
	- parameter manager:   instance of CLLocationManager
	- parameter locations: array of CLLocation
	*/
	open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		// Get first location element
		let location = locations.last

		lastFethedLocation = location
		locationTimestamp = location?.timestamp

		if let l = location , l.horizontalAccuracy <= self.desiredAccuracy {
			self.processCallback()
			self.locationManager.stopUpdatingLocation()
		}
	}

}
