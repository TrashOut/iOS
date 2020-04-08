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
import CoreLocation

class TrashHunterListViewController: ViewController, UITableViewDataSource, UITableViewDelegate {


	@IBOutlet var tableView: UITableView!
	@IBOutlet var vNoTrashes: UIView!
	@IBOutlet var btnAddDump: UIButton!


	var trashes: [Trash] = [] {
		didSet {
			self.tableView.reloadData()
			if trashes.count == 0 {
				self.showNoTrashes()
			} else {
				self.hideNoTrashes()
			}
		}
	}

	var isWaitingForData: Bool = false

	override func viewDidLoad(){
		super.viewDidLoad()
		self.title = "trashHunter".localized
		self.vNoTrashes.isHidden = true


		let btnClose = UIBarButtonItem.init(title: "global.close".localized, style: .plain, target: self, action: #selector(close))
		self.navigationItem.leftBarButtonItem = btnClose


		tableView.tableFooterView = UIView()
		//self.refresh()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		btnAddDump.layer.cornerRadius = 0.5 * btnAddDump.bounds.height
		btnAddDump.layer.masksToBounds = true
	}



	@objc func close() {
		TrashHunter.hunter?.dismissed()
		self.dismiss(animated: true, completion: nil)
	}

    func refresh() {
		self.isWaitingForData = true
		let filter = TrashFilter()
		filter.status[.reported] = true
		filter.status[.cleaned] = nil
		filter.status[.updateNeeded] = true
		guard let distance = TrashHunter.hunter?.config.distance.meters else { return }
		LocationManager.manager.refreshCurrentLocationIfNeeded { (loc) in
			Networking.instance.trashes(position: loc.coordinate, area: CLLocationDistance(distance), filter: filter, limit: 100, page: 1, callback: { [weak self] (trashes, error) in
				guard error == nil else {
					print(error?.localizedDescription ?? "")
					self?.isWaitingForData = false
					return
				}
				self?.trashes = trashes ?? []
				self?.isWaitingForData = false
			})
		}
	}


	func showNoTrashes() {
		vNoTrashes.isHidden = false
		vNoTrashes.alpha = 0
		UIView.animate(withDuration: 0.35) { 
			self.vNoTrashes.alpha = 1
		}

	}

	func hideNoTrashes() {
		UIView.animate(withDuration: 0.35, animations: { 
			self.vNoTrashes.alpha = 0
			}) { (_) in
			self.vNoTrashes.isHidden = true
		}
	}

	/**
	Add new dump
	*/
	@IBAction func addNewDump(_ sender: Any) {
        guard Reachability.isConnectedToNetwork() else {
            self.show(error: NetworkingError.noInternetConnection)
            return
        }
        
		let storyboard = UIStoryboard.init(name: "Report", bundle: Bundle.main)
		let vc = storyboard.instantiateViewController(withIdentifier: "Report")
		present(vc, animated: true, completion: nil)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return trashes.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrashCell", for: indexPath) as? TrashTableViewCell else { fatalError("Could not dequeue cell with identifier: TrashCell") }

		let trash = trashes[indexPath.row]
		let status = Trash.DisplayStatus.getStatus(trash: trash)

		cell.ivStatus.image = status.image

		// Dumps distance from user
		if let gps = trash.gps {
			let trashLocation = CLLocation.init(latitude: gps.lat, longitude: gps.long)
			let distance = LocationManager.manager.currentLocation.distance(from: trashLocation)
			let distanceInM = Int(round(distance))
			cell.lblDistance.text = DistanceRounding.shared.localizedDistance(meteres: distanceInM)
		}

		// Dumps photo
		if let image = trash.images.first?.optimizedDownloadUrl {
			cell.ivPhoto.remoteImage(id: image)
		}

		// Types of trash
		cell.lblType.text = trash.types.map({$0.localizedName}).joined(separator: ", ").uppercaseFirst


		// Date of dumps update
		if let updateTime = trash.created { // FIXME: change to updated when available at api
			cell.lblTime.text = DateRounding.shared.localizedString(for: updateTime)
		}

		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let trash = trashes[indexPath.row]
		let st = UIStoryboard.init(name: "Dumps", bundle: Bundle.main)
		guard let vc = st.instantiateViewController(withIdentifier: "DumpsDetailViewController") as? DumpsDetailViewController else { return }
		vc.id = trash.id
		navigationController?.pushViewController(vc, animated: true)

	}

}
