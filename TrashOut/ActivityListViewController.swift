//
//  TrashOut
//  Copyright 2017 TrashOut NGO. All rights reserved.
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

class ActivityListViewController: ViewController,
    UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!

    var user: User?

    var activities: [Activity] = []

	let pageLimit: Int = 20
	var end: Bool = false
	var page: Int = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "profile.activity.mobileHeader".localized
        self.loadData(page: 1, loadingView: true)
        self.addPullToRefresh(into: tableView)
    }

    /**
     Pull to refresh
     */
    func addPullToRefresh(into scrollView: UIScrollView) {
        scrollView.addPullToRefreshHandler { [weak self] in
            self?.end = false
            self?.activities.removeAll()
            self?.loadData(page: 1, loadingView: true)
        }
    }
    
    func loadData(page: Int = 1, loadingView:Bool = false) {
        if loadingView == true { LoadingView.show(on: self.view, style: .white) }
		guard self.end == false else { return }
        guard let userId = user?.id else { return }
        Networking.instance.userActivity(user: userId, page: page, limit: pageLimit) { [weak self] activities, _ in
            DispatchQueue.main.async {
                self?.addActivities(activities ?? [])
                self?.tableView.pullToRefreshView?.stopAnimating()
                if loadingView == true { LoadingView.hide() }
                if (activities?.count == 0) {
                     self?.end = true
                }
                if (self?.activities.count == 0) {
                    NoDataView.show(over: self?.view, text: "home.noUserActivities".localized)
                }
            }
        }
    }

	func addActivities(_ activities: [Activity]) {
		self.activities.append(contentsOf: activities)
		self.tableView.reloadData()
	}

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell
        if (indexPath.row > self.activities.count) { return cell }
        let activity = self.activities[indexPath.row]
        cell.lblName.text = activity.user?.displayName ?? "trash.anonymous".localized
        cell.date = activity.created
		cell.gps = activity.gps
        // Dump photo
        if let photo = activity.trashUpdate?.images.last?.optimizedDownloadUrl {
            cell.imgvPhoto.remoteImage(id: photo, placeholder: #imageLiteral(resourceName: "No image square"), animate: true)
        }
        if let update = activity.trashUpdate, let action = activity.action {
            let status = TrashUpdate.ActivityStatus.getStatus(trashUpdate: update, action: action)
            cell.imgvStatusIcon.image = status.image
            cell.lblName.text = TrashUpdate.ActivityStatus.getActivityCellTitle(trashUpdate: update, action: action, for: "home.recentActivity.you".localized)
            if let gps = activity.gps {
                setDistance(gps: gps, label: cell.lblDistance)
                setAddress(gps: gps, label: cell.lblLocation)
            } else {
                cell.lblDistance.text = ""
                cell.lblLocation.text = ""
            }
        }
        
		if indexPath.row == activities.count - 1 && activities.count >= pageLimit {
			page += 1
			loadData(page: page)
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
        
    // MARK: - Navigaton
    
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

class ActivityCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var tvCoordinates: UITextView!
    @IBOutlet var imgvPhoto: UIImageView!
    @IBOutlet var lblDistance: UILabel!
    @IBOutlet var distanceLblWrapper: UIView!
    @IBOutlet var imgvStatusIcon: UIImageView!

    /*
    enum ActivityCell {
        
        case reported(value: Int)
        case updated(value: Int)
        case cleaned(value: Int)
        
        var icon: UIImage? {
            get {
                switch self {
                case .reported:
                    return UIImage(named: "Reported")
                case .updated:
                    return UIImage(named: "Updated")
                case .cleaned:
                    return UIImage(named: "Cleaned")
                }
            }
        }
    }
    
    func setup(_ type: ActivityCell) {
        imgvStatusIcon.image = type.icon
    }
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        distanceLblWrapper.layer.cornerRadius = distanceLblWrapper.frame.size.height / 2
        distanceLblWrapper.layer.borderColor = UIColor.darkGray.cgColor
        distanceLblWrapper.layer.borderWidth = 1 / UIScreen.main.scale
        distanceLblWrapper.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgvPhoto.image = #imageLiteral(resourceName: "No image square")
        imgvPhoto.cancelRemoteImageRequest()
    }
    
	var date: Date? {
		didSet {
			guard let date = date else {
				self.lblDate.text = "global.unknow".localized
				return
			}
			let df = DateFormatter()
			df.timeStyle = .none
			df.dateStyle = .medium
			self.lblDate.text = df.string(from: date)
		}
	}

	var gps: GPS? {
		didSet {
            /*
			guard let gps = gps else {
				self.tvCoordinates.text = "Unknown".localized
				return
			}
			self.tvCoordinates.text = GpsFormatter.instance.string(from: gps)
             */
		}
	}
    
}
