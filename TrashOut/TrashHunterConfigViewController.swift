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

class TrashHunterConfigViewController: ViewController,
	UITableViewDataSource, UITableViewDelegate {
    
	@IBOutlet var lblArea: UILabel!
	@IBOutlet var lblDuration: UILabel!
	@IBOutlet var tblDistance: UITableView!
	@IBOutlet var tblDuration: UITableView!

	@IBOutlet var cnsDistanceTableHeight: NSLayoutConstraint!
	@IBOutlet var cnsDurationTableHeight: NSLayoutConstraint!

	@IBOutlet var btnStart: UIButton!

	var config: TrashHunterConfig = TrashHunterConfig()

	weak var container: TrashHunterContainerViewController?

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "trashHunter.startHunting".localized

		lblArea.text = "trashHunter.huntingArea".localized
		lblArea.textColor = Theme.current.color.green
		lblDuration.text = "event.duration".localized
		lblDuration.textColor = Theme.current.color.green

		cnsDistanceTableHeight.constant = 44 * CGFloat(TrashHunterDistance.allValues.count)
		cnsDurationTableHeight.constant = 44 * CGFloat(TrashHunterDuration.allValues.count)

		btnStart.setTitle("trashHunter.startHunting".localized, for: .normal)
		btnStart.theme()

		let btnClose = UIBarButtonItem.init(title: "global.cancel".localized, style: .plain, target: self, action: #selector(close))
		self.navigationItem.leftBarButtonItem = btnClose

		tblDistance.tableFooterView = UIView()
		tblDuration.tableFooterView = UIView()
	}

	@IBAction func close() {
		self.dismiss(animated: true, completion: nil)
	}

	@IBAction func start() {
		guard let container = self.container else { return }
		TrashHunter.start(with: self.config, container: container, errorHandler: container.errorHandler)
		self.dismiss(animated: true, completion: nil)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView == tblDistance {
			return TrashHunterDistance.allValues.count
		}
		if tableView == tblDuration {
			return TrashHunterDuration.allValues.count
		}
		return 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if tableView == tblDistance {
			let cell = tableView.dequeueReusableCell(withIdentifier: "TrashHunterDistanceCell") as! TrashHunterDistanceCell
			let distance = TrashHunterDistance.allValues[indexPath.row]

			cell.lblTitle.text = distance.localizedName
			cell.ivChecked.image = UIImage(named: "Checked")?.withRenderingMode(.alwaysTemplate)
			cell.ivChecked.tintColor = Theme.current.color.green

			if self.config.distance == distance {
				cell.ivChecked.isHidden = false
			} else {
				cell.ivChecked.isHidden = true
			}

			return cell
		}
		if tableView == tblDuration {
			let cell = tableView.dequeueReusableCell(withIdentifier: "TrashHunterDurationCell") as! TrashHunterDurationCell
			let duration = TrashHunterDuration.allValues[indexPath.row]

			cell.lblTitle.text = duration.localizedName

			cell.ivChecked.image = UIImage(named: "Checked")?.withRenderingMode(.alwaysTemplate)
			cell.ivChecked.tintColor = Theme.current.color.green

			if self.config.duration == duration {
				cell.ivChecked.isHidden = false
			} else {
				cell.ivChecked.isHidden = true
			}

			return cell
		}
		return UITableViewCell()
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if tableView == tblDistance {
			let distance = TrashHunterDistance.allValues[indexPath.row]
			config.distance = distance
			UIView.transition(with: tableView, duration: 0.2, options: [.transitionCrossDissolve], animations: { 
				tableView.reloadData()
			}, completion: nil)

		}
		if tableView == tblDuration {
			let duration = TrashHunterDuration.allValues[indexPath.row]
			config.duration = duration
			UIView.transition(with: tableView, duration: 0.2, options: [.transitionCrossDissolve], animations: {
				tableView.reloadData()
			}, completion: nil)
		}
	}

}

class TrashHunterDistanceCell: UITableViewCell {

	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var ivChecked: UIImageView!

}

class TrashHunterDurationCell: UITableViewCell {

	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var ivChecked: UIImageView!

}

