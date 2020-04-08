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
import UIKit
import SwiftDate


class TrashHunterError: Error {

	var isCritical: Bool = false
	var repeatBlock: (() -> ())? = nil
	var message: String?

	var actions: [UIAlertAction] = []

}

class TrashHunter: NSObject, CLLocationManagerDelegate {

	static var hunter: TrashHunter?

	static let kNotificationCategoryName = "TrashHunter"

	var config: TrashHunterConfig
	weak var container: TrashHunterContainerViewController?

	var startTime: Date?

	var locationManager: CLLocationManager?

	var error: TrashHunterError? {
		didSet {
			guard let error = error else {
				return
			}
			if let handler = self.errorHandler {
				handler(error)
			}
		}
	}


	var errorHandler: ((TrashHunterError) -> ())?

	var lastTrashes: [Trash] {
		guard let lastKey = trashesLog.keys.sorted(by: {$0 < $1}).last else { return [] }
		return trashesLog[lastKey]!
	}

	var trashesLog: [Date: [Trash]] = [:]


	init(_ config: TrashHunterConfig) {
		self.config = config
	}

	static func start(with config: TrashHunterConfig, container: TrashHunterContainerViewController, errorHandler: @escaping (TrashHunterError) -> ()) {
		hunter = TrashHunter(config)
		hunter?.container = container
		hunter?.errorHandler = errorHandler
		hunter?.start()
	}

	func start() {
		startTime = Date()
		locationManager = CLLocationManager()
		guard let locationManager = locationManager else { return }
		locationManager.delegate = self
		if CLLocationManager.authorizationStatus() != .authorizedAlways {
			let error = TrashHunterError()
			error.isCritical = true
			error.message = "Location services are disabled, enable them in settings by choosing Always option.".localized
			error.repeatBlock = { [weak self] in
				LocationManager.manager.refreshCurrentLocation { (_) in
					self?.start()
				}
			}
            
			if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
				let settingsAction = UIAlertAction(title: "Settings".localized, style: .default, handler: { (_) in
					if UIApplication.shared.canOpenURL(settingsUrl) {
						UIApplication.shared.open(settingsUrl)
					}
				})
				error.actions.append(settingsAction)
			}


			self.error = error
			return
		}
        
		self.prepareNotifications(success: { [weak self] in
			self?.startMonitoring()
			}, failure: {
				let error = TrashHunterError()
				error.isCritical = true
				error.message = "Notifications are disabled, enable them in setting".localized
				error.repeatBlock = { [weak self] in
					self?.start()
				}
                
				if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
					let settingsAction = UIAlertAction(title: "Settings".localized, style: .default, handler: { (_) in
						if UIApplication.shared.canOpenURL(settingsUrl) {
							UIApplication.shared.open(settingsUrl)
						}
					})
					error.actions.append(settingsAction)
				}

				self.error = error
		})

	}

	func startMonitoring() {
		guard let locationManager = locationManager else { return }
		if self.isSignificantLocationChangeMode {
			locationManager.startMonitoringSignificantLocationChanges()
		} else {
			locationManager.allowsBackgroundLocationUpdates = true
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.distanceFilter = CLLocationDistance(config.minimumMovement)
			locationManager.activityType = .other
			locationManager.pausesLocationUpdatesAutomatically = true
			locationManager.startUpdatingLocation()
		}
        
		container?.switchControllers()
	}


	// MARK: - Prepare notifications

	var notificationRegistered: (()->())?
	var notificationFailedToRegister: (()->())?

	func prepareNotifications(success: @escaping ()->(), failure: @escaping ()->()) {
		self.notificationRegistered = success
		self.notificationFailedToRegister = failure

		let category = UIMutableUserNotificationCategory()
		category.identifier = TrashHunter.kNotificationCategoryName
		let openAction = UIMutableUserNotificationAction()
		openAction.identifier = "open"
		openAction.title = "Show".localized
		openAction.activationMode = .foreground
		openAction.isDestructive = false
		openAction.isAuthenticationRequired = false
		category.setActions([openAction], for: .minimal)
		category.setActions([openAction], for: .default)
		let settings = UIUserNotificationSettings.init(types: [.alert], categories: Set([category]))
		UIApplication.shared.registerUserNotificationSettings(settings)
	}

	func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
		if application.currentUserNotificationSettings?.types.contains(.alert) == true {
			if let registered = self.notificationRegistered {
				self.notificationRegistered = nil
				registered()
			}
		} else {
			if let failed = self.notificationFailedToRegister {
				self.notificationFailedToRegister = nil
				failed()
			}
		}
	}


	// MARK: - Location changes

	var lastNotificationTime: Date? = nil
	var lastLocation: CLLocation? = nil
	var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid


	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard bgTask == UIBackgroundTaskIdentifier.invalid else {
			print("There is running task in background")
			return
		}

        bgTask = UIApplication.shared.beginBackgroundTask(withName: "TrashHunterDownloadData", expirationHandler: { [weak self] in
            print("TrashHunterDownloadData background time expired")
            self?.endBgTask()
        })

		print("Fetched locations: \(locations.count)")
		let location = locations
			.filter { (loc) -> Bool in
				return loc.horizontalAccuracy < 100
			}
			.sorted { (l1, l2) -> Bool in
			l1.timestamp > l2.timestamp
		}.first
		guard let loc = location else {
			self.endBgTask()
			return
		}
		// Just memorize location in global for future use
		LocationManager.manager.currentLocation = loc
		print("\(GpsFormatter.instance.string(fromLat: loc.coordinate.latitude, lng: loc.coordinate.longitude))")

		guard let startTime = startTime else {
			self.endBgTask()
			return
		}

		if startTime + Int(config.duration.duration).seconds < Date() {
			self.end()
			self.endBgTask()
			return
		}

		if isSignificantLocationChangeMode { // just process location
			self.processLocation(loc)
		} else { // throw notification each 5 mins
			if let last = lastNotificationTime, last > Date() - Int(self.config.timeFilter).seconds {
				self.endBgTask()
				return
			} else {
				// filter by distance
				if let lastLocation = self.lastLocation {
					if lastLocation.distance(from: loc) <= Double(config.minimumMovement) {
						self.endBgTask()
						return
					}
				}
				self.processLocation(loc)
			}
		}
	}

	func end() {
		if isSignificantLocationChangeMode {
			self.locationManager?.stopMonitoringSignificantLocationChanges()
		} else {
			self.locationManager?.stopUpdatingLocation()
		}
		self.locationManager?.delegate = nil
		self.locationManager = nil
		TrashHunter.hunter = nil
		container?.switchControllers()
	}

	/// Mode for significant location changes (ignores time interval for distance in config)
	var isSignificantLocationChangeMode: Bool {
		return config.distance != .m500
	}


	func processLocation(_ location: CLLocation) {

		let filter = TrashFilter()
		filter.status[.reported] = true
		filter.status[.cleaned] = nil
		filter.status[.updateNeeded] = true
		Networking.instance.trashes(position: location.coordinate, area: CLLocationDistance(config.distance.meters), filter: filter, limit: 1000, page: 1) { [weak self] (trashes, error) in
			if let error = error {
				print(error.localizedDescription)
				self?.endBgTask()
				return
			}
			guard let trashes = trashes else { return }
			print("Found dumps: \(trashes.count)")
			let stamp = Date()
			self?.trashesLog[stamp] = trashes
			if trashes.count > 0 {
				self?.localNotification(trashes: trashes, stamp: stamp, location: location)
			}
			self?.endBgTask()
		}
	}

	func endBgTask() {
		if  bgTask != UIBackgroundTaskIdentifier.invalid {
			UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(bgTask.rawValue))
			self.bgTask = UIBackgroundTaskIdentifier.invalid
			print("background task ended")
		}
	}


	func localNotification(trashes: [Trash], stamp: Date, location: CLLocation) {
		// mark current location for filter
		self.lastLocation = location

		// check if there are any new dumps
		var logs = trashesLog.keys.sorted(by: {$0 < $1})
		logs.removeLast()
		var count = trashes.count
		if let previous = logs.last {
			let previousTrashes = trashesLog[previous]!
			let newTrashes = trashes.filter { (trash) -> Bool in
				return previousTrashes.contains(where: { (t) -> Bool in
					t.id == trash.id
				}) == false
			}
			count = newTrashes.count
		}
		if count == 0 {
			return
		}

		// mark notification
		if let last = lastNotificationTime, last > Date() - Int(self.config.timeFilter).seconds {
			return
		}
		if !isSignificantLocationChangeMode {
			self.lastNotificationTime = Date()
		}

		// create notification (2 seconds delay for better debug)
		let notif = UILocalNotification()
		notif.category = TrashHunter.kNotificationCategoryName
		notif.alertTitle = "New dumps found: %d".localized(count)
		notif.alertBody = "Check them out".localized
		notif.fireDate = Date() + 2.seconds
		notif.timeZone = TimeZone.current
		notif.hasAction = true
		notif.userInfo = ["trashesStamp": stamp.timeIntervalSince1970]
		UIApplication.shared.scheduleLocalNotification(notif)
	}

	func appWillResignActive(_ app: UIApplication) {

	}

	weak var controller: TrashHunterListViewController?

	func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
		let state = application.applicationState
		if state == .inactive {
			if controller == nil {
				let stampValue: Double = notification.userInfo?["trashesStamp"] as? Double ?? 0
				let stamp = Date.init(timeIntervalSince1970: stampValue)
				let trashes = trashesLog[stamp]
				self.openList(trashes: trashes)
			} else {
				self.refreshList()
			}
		}
		self.container?.refresh()
	}

	func openList() {
		self.openList(trashes: self.lastTrashes)
	}

	func openList(trashes: [Trash]?) {
		guard let rvc = UIApplication.shared.keyWindow?.rootViewController else { return }
		let st = UIStoryboard(name: "TrashHunter", bundle: Bundle.main)
		let vc = st.instantiateViewController(withIdentifier: "TrashHunterListController")
		let nc = vc as? UINavigationController
		guard let thlvc = nc?.viewControllers.first as? TrashHunterListViewController else { return }

		rvc.present(vc, animated: true, completion: {
			if let trashes = trashes {
				thlvc.trashes = trashes
			} else {
				thlvc.refresh()
			}
		})
	}

	func refreshList() {
		self.controller?.refresh()
	}

	func dismissed() {
		self.controller = nil
	}

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
