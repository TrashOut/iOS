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

class DashboardActivityViewController: ViewController,
	UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var tableView: UITableView!

	var activities: [Activity] = [] {
		didSet {
			tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.translatesAutoresizingMaskIntoConstraints = false

	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return activities.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
		let activity = activities[indexPath.row]
		cell.date = activity.created
		cell.gps = activity.gps
        // Dump photo
        if let photo = activity.trashUpdate?.images.last?.optimizedDownloadUrl {
            cell.imgvPhoto.remoteImage(id: photo, placeholder: #imageLiteral(resourceName: "No image square"), animate: true)
        }
        if let update = activity.trashUpdate, let action = activity.action {
            let status = TrashUpdate.ActivityStatus.getStatus(trashUpdate: update, action: action)
            cell.imgvStatusIcon.image = status.image
            
            var name = activity.user?.displayFirstName ?? "trash.anonymous".localized
            if (activity.trashUpdate?.anonymous == true) {
                name = "trash.anonymous".localized
            } else {
                if let user = UserManager.instance.user, let updateUser = activity.user {
                    if  updateUser.id == user.id && UserManager.instance.isAnonymous == false {
                        name = "home.recentActivity.you".localized
                    }
                }
            }
              
            cell.lblName.text = TrashUpdate.ActivityStatus.getActivityCellTitle(trashUpdate: update, action: action, for: name)
            
            if let gps = activity.gps {
                setDistance(gps: gps, label: cell.lblDistance)
                setAddress(gps: gps, label: cell.lblLocation)
            } else {
                cell.lblDistance.text = ""
                cell.lblLocation.text = ""
            }
        }
		return cell
	}
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let activity = activities[indexPath.row]
        switch activity.type {
        case .trashPoint:
            openDumpDetail(activity.id)
        default:
            break
        }
    }
        
    // MARK: - Navigation
    
    func openDumpDetail(_ id:Int) {
        performSegue(withIdentifier:"openDumpDetail", sender: id)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openDumpDetail" {
            if let ddvc = segue.destination as? DumpsDetailViewController {
                ddvc.id = sender as? Int ?? 0
            }
        }
    }
    
}
