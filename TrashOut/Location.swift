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

	/// Singleton for resolving user locationb
    public static var manager = LocationManager()

	/**
	Default location to use if user's cannot be determined
	*/
	open var defaultLocation: CLLocation = CLLocation.init(latitude: 0, longitude: 0) // Center of universe?

	/// Just marks flag, no timer is set
    open var refreshInterval: TimeInterval = 60
	open var locationNeedsRefresh: Bool {
        (lastFetchedLocation?.timestamp ?? Date.distantPast) < Date().addingTimeInterval(-refreshInterval)
	}

	/**
	Current user location last fetched, or use default location if not determined
	*/
	open var currentLocation: CLLocation {
		get { lastFetchedLocation ?? defaultLocation }
		set { lastFetchedLocation = newValue }
	}

	/**
	Any location was already received (location was set any time in past)
	*/
	open var fetchedAnyLocation: Bool {
		lastFetchedLocation != nil
	}

	/**
	Reload current user location if needed, callback is alwayes called
	*/
	open func refreshCurrentLocationIfNeeded(desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters, _ callback: @escaping (CLLocation) -> Void) {
        if locationNeedsRefresh || (lastFetchedLocation?.horizontalAccuracy ?? .infinity) > desiredAccuracy {
            refreshCurrentLocation(desiredAccuracy: desiredAccuracy, callback)
		} else {
            let location = currentLocation
            DispatchQueue.main.async {
                callback(location)
            }
		}
	}

	/**
	Reload current user location, callback is alwayes called
	*/
    open func refreshCurrentLocation(desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters, _ callback: @escaping (CLLocation) -> Void) {
        self.desiredAccuracy = desiredAccuracy
		self.callback = callback
		startManagerForLocationUpdates()
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
            DispatchQueue.main.async {
                callback(mark)
            }
        }
    }

	// MARK: - CoreLocation processing

	/// CoreLocation manager for location updates
	private let locationManager: CLLocationManager = CLLocationManager()
	/// Callback for granting permissions to use location
	private var authorizationBlock: ((_ status: CLAuthorizationStatus) -> Void)?
	/// Last resolved location
	private var lastFetchedLocation: CLLocation?
	/// If there was error resolving location, there it is
	private var lastError: NSError?
	/// Callback for refresh method to be called after location is defined
	private var callback: ((CLLocation)->Void)?
    /// Accuracy desired by caller
    private var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    /// Start time of location refresh
    private var locationRefreshStartTime = Date.distantPast

	private override init() {
		super.init()
		locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = false
	}

	/**
	Do the callback when location was found (or not)
	*/
	private func processCallback() {
		if let callback = self.callback {
			self.callback = nil
            let location = currentLocation
            DispatchQueue.main.async {
                callback(location)
            }
		}
	}

	/**
	Start to listen for location changes
	*/
	private func startManagerForLocationUpdates() {
		self.processLocationUsageAuthorization( { [weak self] in
            self?.locationRefreshStartTime = Date()
            self?.locationManager.startUpdatingLocation()
        }, failure: { [weak self] in
            self?.processCallback()
        })
	}

	/**
	Request authorization to use location
	*/
	private func processLocationUsageAuthorization(_ success: @escaping () -> Void, failure: @escaping () -> Void) {
		// set location manager params according to the best presition of all requests
		if CLLocationManager.authorizationStatus() == .notDetermined {
			// check which perms should ask according to the plist config
            // NSLocationAlwaysAndWhenInUseUsageDescription
            // NSLocationWhenInUseUsageDescription
            // NSLocationAlwaysUsageDescription
			if (Bundle.main.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") != nil) {
                requestAlwaysAuthorization({ (status) in
                    if status == .authorizedAlways {
                        success()
                    } else {
                        failure()
                    }
                })
			} else if (Bundle.main.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") != nil) {
                requestWhenInUseAuthorization({ (status) in
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
	private func requestWhenInUseAuthorization(_ block: @escaping (_ status: CLAuthorizationStatus) -> Void) {
		authorizationBlock = block
		locationManager.requestWhenInUseAuthorization()
	}

	/**
	Ask user for location traking while the app is in use or in background, when the user answer, the AuthorizationBlock is executed

	- parameter block: blok Instance of AuthorizationBlock
	*/
	private func requestAlwaysAuthorization(_ block: @escaping (_ status: CLAuthorizationStatus) -> Void) {
		authorizationBlock = block
		locationManager.requestAlwaysAuthorization()
	}

	/**
	When authorization status change, report using the AuthorizationBlock
	
	- parameter manager: instance of CLLocationManager
	- parameter status:  CLAuthorizationStatus status
	*/
	open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationBlock?(status)
	}

	/**
	Report failure to all active location request

	- parameter manager: instance of CLLocationManager
	- parameter error:   instance of NSError
	*/
	open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		lastError = error as NSError?
		print(error.localizedDescription)
	}

	/**
	Report location update to all active request, if all request are finished stop the location tracking
	
	- parameter manager:   instance of CLLocationManager
	- parameter locations: array of CLLocation
	*/
	open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastFetchedLocation = location
        if location.horizontalAccuracy <= desiredAccuracy || location.timestamp.timeIntervalSince(locationRefreshStartTime) > 2 {
            processCallback()
            locationManager.stopUpdatingLocation()
        }
	}
}

extension CLPlacemark {
    
    var formattedAddressLines: [String]? {
        self.addressDictionary?["FormattedAddressLines"] as? [String]
    }
    
    var shortName: String? {
        if let street = self.thoroughfare, let number = self.subThoroughfare {
            return "\(street) \(number)"
        }
        let components: [String?] = [
            self.name,
            self.thoroughfare,
            self.subLocality,
            self.locality,
            self.subAdministrativeArea,
            self.administrativeArea,
            self.country,
            self.inlandWater,
            self.ocean
        ]
        return components.compactMap { $0 }.first { !$0.isEmpty }
    }
}
