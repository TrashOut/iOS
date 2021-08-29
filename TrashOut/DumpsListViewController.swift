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

protocol ShowTrashFilterData {
    func showFilterData(value: [Trash])
}

protocol SendDataForTrashFilter {
    func sendDataForTrashFilter(status: [String], update: Bool, size: String, type: [String], timeTo: String, timeFrom: String)
}

class DumpsListViewController: ViewController, UITableViewDataSource, UITableViewDelegate,
	TrashFilterDelegate {

	// MARK: - UI

	@IBOutlet var tableView: UITableView!

    @IBOutlet var loadingView: UIView!

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBOutlet var btnAddDumpWrapper: UIView!
    @IBOutlet var btnAddDump: UIButton!

	// MARK: - Internals

	var trashes: [Trash] = [] {
		didSet {
			tableView.reloadData()
            loadingView.isHidden = true
            activityIndicator.stopAnimating()
		}
	}

    var trash: Trash?
	var filter: TrashFilter = TrashFilter.cachedFilter

    fileprivate var page = 1
    fileprivate var images: [String]?
    fileprivate var trashStatus: [String]!
    fileprivate var trashTypes: [String]!
    fileprivate var trashSize: String!
    fileprivate var updateNeeded = true
    fileprivate var timeBoundaryTo: String!
    fileprivate var timeBoundaryFrom: String!

	// MARK: - Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)

		LocationManager.manager.refreshCurrentLocationIfNeeded { [weak self] (location) in
			self?.isLastPage = false
            self?.loadData(page: 1)
        }

        let filter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(goToFilter))
        parent?.navigationItem.rightBarButtonItem = filter

        self.addPullToRefresh(into: tableView)
	}
 
    override func viewDidLayoutSubviews() {
        btnAddDumpWrapper.circleButtonShadow = true
        btnAddDump.layer.cornerRadius = 0.5 * btnAddDump.bounds.height
        btnAddDump.layer.masksToBounds = true
    }

    /**
     Pull to refresh
     */
    func addPullToRefresh(into scrollView: UIScrollView) {
        scrollView.addPullToRefreshHandler { [weak self] in
            self?.isLastPage = false
            self?.trashes.removeAll()
            LocationManager.manager.refreshCurrentLocation({ (_) in
                self?.loadData(page: 1)
            })
        }
    }

    /**
    Go to filter
    */
    @objc func goToFilter() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DumpsFilterViewController") as? DumpsFilterViewController else { fatalError("Could not dequeue storyboard with identifier: DumpsFilterViewController") }
//        vc.ShowTrashFilterDataDelegate = self
//        vc.SendDataForTrashFilterDelegate = self
		vc.delegate = self
		vc.filter = filter
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }

	func filterDidSet(filter: TrashFilter) {
		self.filter = filter
		self.trashes = []
		self.isLastPage = false
		self.loadData(page: 1)
	}

    /**
    Add new dump
    */
    @IBAction func addNewDump(_ sender: Any) {
        let storyboard = UIStoryboard.init(name: "Report", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "Report")
        present(vc, animated: true, completion: nil)
    }

	// MARK: - Networking

	var isLastPage: Bool = false

    fileprivate func loadData(page: Int) {
		guard isLastPage == false else {return}
		let locationPoint = LocationManager.manager.currentLocation.coordinate
		Networking.instance.trashes(position: locationPoint, filter: filter, limit: 20, page: page) { [weak self] (trashes, error) in
			guard error == nil else {
                DispatchQueue.main.async {
                    if case NetworkingError.noInternetConnection = error! {
                        self?.show(error: NetworkingError.custom("global.internet.offline".localized))
                    } else {
                        self?.show(error: error!)
                    }
                    
                    self?.loadingView.isHidden = true
                    self?.tableView.pullToRefreshView?.stopAnimating()
                }
				return
			}
			guard let newTrashes = trashes else { return }
			if newTrashes.count == 0 {
				self?.isLastPage = true
				if self?.trashes.count == 0 {
                    DispatchQueue.main.async {
                        self?.show(message: "global.filter.noResult".localized)
                    }
				}
			}
            DispatchQueue.main.async {
                self?.trashes += newTrashes
                self?.tableView.pullToRefreshView?.stopAnimating()
            }
		}
	}

	// MARK: - Table view Data Source

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return trashes.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrashCell", for: indexPath) as? TrashTableViewCell else { fatalError("Could not dequeue cell with identifier: TrashCell") }

        let trash = trashes[indexPath.row]

        // Status
        let status = Trash.DetailStatus.getStatus(in: trash)
		cell.ivStatus.image = status.image
		cell.gps = trash.gps

        // Dumps photo
        if let image = trash.images.first?.optimizedDownloadUrl {
            cell.ivPhoto.remoteImage(id: image, placeholder: #imageLiteral(resourceName: "No image square"), animate: true)
        }

        // Types of trash
		cell.lblType.text = trash.types.map { $0.localizedName }.joined(separator: ", ").uppercaseFirst

        if let ut = trash.activityCreated {
            cell.lblTime.text = DateRounding.shared.localizedString(for: ut).uppercaseFirst
        } else {
            cell.lblTime.text = "global.unknow".localized
        }
        
        // When there is no row, load another trashes
        if indexPath.row == trashes.count - 1 && trashes.count >= 20 {
            page += 1
            loadData(page: page)
        }
		return cell
    }

    /**
    Setting for user location button
    */
    fileprivate func setMapButton(image: String, button: UIButton) {
        let origImage = UIImage(named: image)
        let tintedImage = origImage?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = Theme.current.color.green
    }

//    /**
//    Show all types of trash
//    */
//    fileprivate func showAllTypesOfTrash(trash: Trash, type: [Trash.TrashType], cell: TrashTableViewCell) {
//        var types = [String]()
//
//        for i in 0...trash.types.count - 1 {
//            if type[i].rawValue.lowercased() == "deadanimals" {
//                types.append("dead animals")
//            } else {
//                types.append(type[i].rawValue.lowercased())
//            }
//        }
//        cell.lblType.text = types.joined(separator: ", ").uppercaseFirst
//    }

//    /**
//    Show created or updated date of trash
//    */
//    fileprivate func showDate(date: Date) -> String {
//        let formatter = DateFormatter.utc
//        formatter.dateStyle = .short
//        let stringFromDate = formatter.string(from: date)
//        let formattedString = stringFromDate.replacingOccurrences(of: "/", with: ". ")
//
//        return formattedString
//    }

	// MARK: - Table view Delegate

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let trashId = trashes[indexPath.row]

        guard let vc = storyboard?.instantiateViewController(withIdentifier: "DumpsDetailViewController") as? DumpsDetailViewController else { return }
        vc.id = trashId.id
		navigationController?.pushViewController(vc, animated: true)
	}

}

class TrashTableViewCell: UITableViewCell {

	@IBOutlet var ivPhoto: UIImageView!
    @IBOutlet var ivStatus: UIImageView!
	@IBOutlet var lblDistance: UILabel!
    @IBOutlet var lblType: UILabel!
    @IBOutlet var lblTime: UILabel!

	var gps: GPS? {
		didSet {
			guard let gps = gps else {
				self.lblDistance.text = ""
				return
			}
			let trashLocation = CLLocation.init(latitude: gps.lat, longitude: gps.long)
			let distance = LocationManager.manager.currentLocation.distance(from: trashLocation)
			let distanceInM = Int(round(distance))
			self.lblDistance.text = "~" + DistanceRounding.shared.localizedDistance(meteres: distanceInM)
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
        //lblTime.textColor = Theme.current.color.lightGray
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		ivPhoto.cancelRemoteImageRequest()
        ivStatus.backgroundColor = .none
        lblDistance.text = ""
        lblType.text = ""
        lblTime.text = ""
	}

}

extension DumpsListViewController: ShowTrashFilterData {

    /**
    Set trashes according filtered data
    */
    func showFilterData(value: [Trash]) {
        if !value.isEmpty {
            trashes = value
        }
    }

}

extension DumpsListViewController: SendDataForTrashFilter {

    /**
    Set data for lazy loading when filter was set
    */
    func sendDataForTrashFilter(status: [String], update: Bool, size: String, type: [String], timeTo: String, timeFrom: String) {
        trashStatus = status
        trashTypes = type
        trashSize = size
        updateNeeded = update
        timeBoundaryFrom = timeFrom
        timeBoundaryTo = timeTo
    }

}
