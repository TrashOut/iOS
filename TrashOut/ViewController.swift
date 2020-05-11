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
import UIKit
import Firebase
import CoreLocation

/**
Abstract class for controllers

Implementing:

 - global navigation buttons
 - analytics
 - helper methods
*/
class ViewController: UIViewController {

	/// Data for analytics
	var analyticsData: [String: NSObject]? // who left there this odd type?

	/**
	Added analitycs logging and back button fix
	*/
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		var screenName: String = "\(type(of: self))"
		if screenName.hasSuffix("ViewController") {
			screenName = screenName.replacingOccurrences(of: "ViewController", with: "")
		}
        Analytics.logEvent("open_\(screenName)", parameters: analyticsData)
		navigationItem.title = title        
	}

	/**
	Removed back button label
	*/
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationItem.title = "" // Do not show 'Back' title
	}

	// MARK: - Helpers

	/**
	Show alert dialog with error

	 - Warning: avoid using this method
	*/
	func show(error: Error, completion: (() -> ())? = nil) {
		let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
		let ok = UIAlertAction.init(title: "global.ok".localized, style: .default, handler: { _ in
			completion?()
		})
		alert.addAction(ok)
		present(alert, animated: true, completion: nil)
	}

	/**
	Show alert dialog with message

	- Warning: avoid using this method
	*/
	func show(message: String, completion: (() -> ())? = nil) {
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		let ok = UIAlertAction.init(title: "global.ok".localized, style: .default, handler: { _ in
			completion?()
		})
		alert.addAction(ok)
		present(alert, animated: true, completion: nil)
	}

    /**
    Show alert dialog with message and option to go directly to app settings
     
    - Warning: avoid using this method
    */
    func showWithSettings(message: String) {
        let alert = UIAlertController(title: nil, message: message.localized, preferredStyle: .alert)
        let settings = UIAlertAction.init(title: "global.settings".localized, style: .default) { (alertAction) in
            guard let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(appSettings)
        }
        let ok = UIAlertAction.init(title: "global.ok".localized, style: .default, handler: nil)
        alert.addAction(settings)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    
    func show(
        title: String? = nil,
        message: String,
        okActionTitle: String? = nil,
        cancelActionTitle: String? = nil,
        okAction: ((UIAlertAction) -> Swift.Void)? = nil,
        cancelAction: ((UIAlertAction) -> Swift.Void)? = nil ) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: okActionTitle ?? "global.yes".localized, style: .default, handler: okAction)
        let cancel = UIAlertAction.init(title: cancelActionTitle ?? "global.cancel".localized, style: .cancel, handler: cancelAction)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    /**
     Set distance from user
     */
    func setDistance(gps: GPS, label: UILabel) {
        let collection = CLLocation.init(latitude: gps.lat, longitude: gps.long)
        let distance = LocationManager.manager.currentLocation.distance(from: collection)
        let distanceInM = Int(round(distance))
        label.text = DistanceRounding.shared.localizedDistance(meteres: distanceInM)
    }
    
    /**
    Formats address from GPS object or by reverse-geocoding location coordinates.
    */
    func setAddress(gps: GPS, completion: @escaping (String) -> ()) {
        if let address = gps.address {
            completion(address)
        } else {
            completion(" ")
            LocationManager.manager.resolveName(for: CLLocation(latitude: gps.lat, longitude: gps.long)) { placemark in
                let address = placemark?.formattedAddressLines?.joined(separator: ", ")
                DispatchQueue.main.async {
                    completion(address ?? "global.noAddress".localized)
                }
            }
        }
    }
    
    func setAddress(gps: GPS, label: UILabel) {
        setAddress(gps: gps) { [weak label] in label?.text = $0 }
    }
    
    func setAddress(gps: GPS, textView: UITextView) {
        setAddress(gps: gps) { [weak textView] in textView?.text = $0 }
    }
}
