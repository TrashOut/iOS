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
    open var refreshInterval: TimeInterval = 2 * 60
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
	open func refreshCurrentLocationIfNeeded(_ callback: @escaping (CLLocation) -> Void) {
        if locationNeedsRefresh {
            refreshCurrentLocation(callback)
		} else {
            DispatchQueue.main.async {
                callback(self.currentLocation)
            }
		}
	}

	/**
	Reload current user location, callback is alwayes called
	*/
    open func refreshCurrentLocation(calibrationTime: TimeInterval = 0.5, _ callback: @escaping (CLLocation) -> Void) {
        self.calibrationTime = calibrationTime
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
            DispatchQueue.main.async {
                callback(marks?.first)
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
    /// Time interval determining how long to wait for new location updates
    private var calibrationTime: TimeInterval = 0
    /// Timer for calibrating measured location
    private var calibrationTimer: Timer?

	private override init() {
		super.init()
		locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .other
        locationManager.pausesLocationUpdatesAutomatically = false
	}

	/**
	Do the callback when location was found (or not)
	*/
	private func processCallback() {
        DispatchQueue.main.async {
            self.callback?(self.currentLocation)
            self.callback = nil
        }
	}

	/**
	Start to listen for location changes
	*/
	private func startManagerForLocationUpdates() {
		self.processLocationUsageAuthorization( { [weak self] in
            self?.locationManager.startUpdatingLocation()
        }, failure: { [weak self] in
            self?.processCallback()
        })
	}

	/**
	Request authorization to use location
	*/
	private func processLocationUsageAuthorization(_ success: @escaping () -> Void, failure: @escaping () -> Void) {
        let handleStatus: (CLAuthorizationStatus) -> () = { status in
            switch status {
            case .authorizedAlways, .authorizedWhenInUse: success()
            default: failure()
            }
        }
        DispatchQueue.main.async {
            let status = CLLocationManager.authorizationStatus()
            if status == .notDetermined {
                self.authorizationBlock = handleStatus
                self.locationManager.requestWhenInUseAuthorization()
            } else {
                handleStatus(status)
            }
        }
	}

	/**
	When authorization status change, report using the AuthorizationBlock
	
	- parameter manager: instance of CLLocationManager
	- parameter status:  CLAuthorizationStatus status
	*/
	open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationBlock?(status)
        }
	}

	/**
	Report failure to all active location request

	- parameter manager: instance of CLLocationManager
	- parameter error:   instance of NSError
	*/
	open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.lastError = error as NSError?
        }
	}

	/**
	Report location update to all active request, if all request are finished stop the location tracking
	
	- parameter manager:   instance of CLLocationManager
	- parameter locations: array of CLLocation
	*/
	open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        DispatchQueue.main.async { [weak self] in
            self?.processLocation(location)
        }
	}
    
    private func processLocation(_ location: CLLocation) {
        if callback != nil {
            if calibrationTimer == nil {
                lastFetchedLocation = location
                calibrationTimer = Timer.scheduledTimer(withTimeInterval: calibrationTime, repeats: false) { [weak self] _ in
                    self?.locationManager.stopUpdatingLocation()
                    self?.processCallback()
                    self?.calibrationTimer = nil
                }
            } else {
                if currentLocation.timestamp < Date().addingTimeInterval(-calibrationTime)
                    || location.horizontalAccuracy <= currentLocation.horizontalAccuracy {
                    lastFetchedLocation = location
                }
            }
        } else {
            lastFetchedLocation = location
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
