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

    /**
     Show alert dialog with message and cancel button
     
     - Warning: avoid using this method
     */
    func show(message:String , okAction: ((UIAlertAction) -> Swift.Void)? = nil, cancelAction: ((UIAlertAction) -> Swift.Void)? = nil ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "global.yes".localized, style: .default, handler: okAction)
        let cancel = UIAlertAction.init(title: "global.cancel".localized, style: .cancel, handler: cancelAction)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func show(message:String , okActionTitle: String ,okAction: ((UIAlertAction) -> Swift.Void)? = nil, cancelAction: ((UIAlertAction) -> Swift.Void)? = nil ) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: okActionTitle, style: .default, handler: okAction)
        let cancel = UIAlertAction.init(title: "global.cancel".localized, style: .cancel, handler: cancelAction)
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
    
    func setAddress(gps: GPS, input: inout String?) {
        input = "global.noAddress".localized
        if let zip = gps.zip, let street = gps.street, let country = gps.country {
            input = "\(zip) " + street + ", " + country
        } else if gps.zip == nil, let street = gps.street, let country = gps.country {
            input = street + ", " + country
        } else {
            input = gps.locality
        }
    }
    
    
    /**
     Set the most accurate address
     */
    func setAddress(gps: GPS, label: UILabel) {
        label.text = "global.noAddress".localized
        if let zip = gps.zip, let street = gps.street, let country = gps.country {
            label.text = "\(zip) " + street + ", " + country
        } else if gps.zip == nil, let street = gps.street, let country = gps.country {
            label.text = street + ", " + country
        } else {
            label.text = gps.locality
        }
        
        /*
        if let zip = gps.zip, let street = gps.street {
            label.text =  label.text! + "\(zip) " + street
        } else if gps.zip == nil, let street = gps.street {
            label.text = label.text! + street
        } else if let subLocality = gps.subLocality {
            label.text = subLocality
        } else if let locality = gps.locality {
            label.text = label.text! + locality
        } else if let aa3 = gps.aa3 {
            label.text = aa3
        } else if let aa2 = gps.aa2 {
            label.text = aa2
        } else if let aa1 = gps.aa1 {
            label.text = aa1
        } else if let country = gps.country {
            label.text = label.text! + country
        } else if let continent = gps.continent {
            label.text = continent
        } else {
            label.text = "No address"
        }
        */
    }
    
}
