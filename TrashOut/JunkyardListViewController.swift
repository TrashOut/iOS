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

protocol ShowFilterData {
    func showFilterData(value: [Junkyard])
}

protocol SendDataForJunkyardFilter {
    func sendDataForJunkyardFilter(size: String, type: [String])
}

class JunkyardListViewController: ViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var btnAdd: UIButton!

    // MARK: - Internals

    var junkyards: [Junkyard] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    fileprivate var page = 1
    fileprivate var filterSize: String!
    fileprivate var filterTypes: [String]!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "tab.recycling".localized

        // Setup the dynamic cell height.
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        
        btnAdd.layer.cornerRadius = btnAdd.bounds.height / 2
        btnAdd.layer.masksToBounds = true
        btnAdd.superview?.circleButtonShadow = true
        
        // Set filter size
        if let filterSize = UserDefaults.standard.object(forKey: "FilterSize") as? String {
            self.filterSize = filterSize
        }
        
        // Set filter types
        if let filterTypes = UserDefaults.standard.object(forKey: "FilterTypes") as? [String] {
            self.filterTypes = filterTypes
        }
        
        LocationManager.manager.refreshCurrentLocationIfNeeded { [weak self] (location) in
            self?.loadData(page: 1)
        }
        

        let filter = UIBarButtonItem(image: UIImage(named: "Filter"), style: .plain, target: self, action: #selector(goToFilter))
        navigationItem.rightBarButtonItem = filter
        
        self.addPullToRefresh(into: tableView)
    }

    /**
     Pull to refresh
     */
    func addPullToRefresh(into scrollView: UIScrollView) {
        scrollView.addPullToRefreshHandler { [weak self] in
            self?.page = 1
            self?.isLastPage = false
            self?.junkyards.removeAll()
            
            LocationManager.manager.refreshCurrentLocation { [weak self] _ in
                self?.loadData(page: 1)
            }
        }
    }
    
    /**
    Go to filter
    */
    @objc func goToFilter() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "JunkyardFiltViewController") as? JunkyardFiltViewController else { fatalError("Could not dequeue storyboard with identifier: JunkyardFiltViewController") }
        vc.ShowFilterDataDelegate = self
        vc.SendDataForJunkyardFilterDelegate = self
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true, completion: nil)
    }

    // MARK: - Networking

    var isLastPage: Bool = false
    
    fileprivate func loadData(page: Int) {
        guard isLastPage == false else { return }
        
        let locationPoint = LocationManager.manager.currentLocation.coordinate
        // if reload == false { LoadingView.show(on: self.view, style: .white) }
        Networking.instance.junkyards(position: locationPoint, size: filterSize, type: filterTypes, page: page) { [weak self] (junkyards, error) in
            // if reload == false { LoadingView.hide() }
            guard error == nil else {
                print(error?.localizedDescription as Any)
                DispatchQueue.main.async {
                    self?.tableView.pullToRefreshView?.stopAnimating()
                    
                    if case NetworkingError.noInternetConnection = error! {
                        self?.show(error: NetworkingError.custom("global.internet.offline".localized))
                    } else {
                        self?.show(message: "global.fetchError".localized)
                    }
                    
                }
                return
            }
            
            guard let newJunkyards = junkyards else { return }
            if newJunkyards.isEmpty {
                self?.isLastPage = true
                if self?.junkyards.count == 0 {
                    DispatchQueue.main.async {
                        if case NetworkingError.noInternetConnection = error! {
                            self?.show(error: NetworkingError.custom("global.internet.offline".localized))
                        } else {
                            self?.show(message: "global.filter.noResult".localized)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.tableView.pullToRefreshView?.stopAnimating()
                self?.junkyards += newJunkyards
            }
        }
    }

    // MARK: - Table view Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return junkyards.count > 0 ? 1 : 0
		} else {
			return junkyards.count > 0 ? junkyards.count - 1 : 0
		}
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell: JunkyardTableViewCell
		if indexPath.section == 1 {
        	cell = tableView.dequeueReusableCell(withIdentifier: "JunkyardCell", for: indexPath) as! JunkyardTableViewCell
		} else {
			cell = tableView.dequeueReusableCell(withIdentifier: "JunkyardTopCell", for: indexPath) as! JunkyardTableViewCell
		}
		let junkyard: Junkyard = indexPath.section == 1 ? junkyards[indexPath.row + 1] : junkyards.first!

		cell.size = junkyard.size
		cell.name = junkyard.name
		cell.gps = junkyard.gps
		cell.types = junkyard.types
        
		// When there is no row, load another trashes
        // When there is no row, load another trashes
        if indexPath.row + 1 == junkyards.count - 1 && junkyards.count >= 20 {
            page += 1
            loadData(page: page)
		}

        return cell
    }

    /**
    Return all types of trash in junkyard
    */
    fileprivate func showAllTypesOfTrash(junkyard: Junkyard, type: [Junkyard.JunkyardType]) -> String {
		let types: [String] = junkyard.types.map({$0.localizedName})
        let allTypes = types.joined(separator: ", ").uppercaseFirst
        return allTypes
    }

    // MARK: - Table view Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let junkyard = junkyards[indexPath.row + indexPath.section]

        guard let vc = storyboard?.instantiateViewController(withIdentifier: "JunkyardsDetailViewController") as? JunkyardsDetViewController else { return }
        vc.junkyard = junkyard
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }

		header.textLabel?.text = section == 0 ? "home.nearestRecyclingPoints".localized : "collectionPoint.other".localized
        header.textLabel?.textColor = Theme.current.color.green
        header.textLabel?.font = Theme.current.font.boldText
        header.textLabel?.textAlignment = .center
        header.backgroundView?.backgroundColor = .white
    }

    @IBAction func addJunkyard() {
        show(title: "home.recycling_point_add_new_tittle".localized, message: "home.recycling_point_add_new_redirect".localized, okAction: { _ in
            UIApplication.shared.open(Link.addJunkyard.url)
            FirebaseAnalytics.log(.addJunkyard)
        })
    }
}

class JunkyardTableViewCell: UITableViewCell {

    @IBOutlet var lblJunkyardName: UILabel!
    @IBOutlet var lblJunkyardType: UILabel!
    @IBOutlet var lblJunkyardDistance: UILabel!
    
	var size: String?

	/// Name of junkyard (set size first for empty name)
	var name: String? {
		didSet {
			guard let name = name else {
				if size == "dustbin" {
					lblJunkyardName.text = "collectionPoint.size.recyclingBin".localized
				} else {
					lblJunkyardName.text = "collectionPoint.size.recyclingCenter".localized
				}
				return
			}
            if size == "dustbin" {
                lblJunkyardName.text = "collectionPoint.size.recyclingBin".localized
            } else {
                lblJunkyardName.text = name
            }
		}
	}

	var gps: GPS? {
		didSet {
			guard let gps = gps else {
				self.lblJunkyardDistance.text = "global.unknow".localized
				return
			}
			let junkyardCollection = CLLocation.init(latitude: gps.lat, longitude: gps.long)
			let distance = LocationManager.manager.currentLocation.distance(from: junkyardCollection)
			let distanceInM = Int(round(distance))
			self.lblJunkyardDistance.text = DistanceRounding.shared.localizedDistance(meteres: distanceInM)
		}
	}

	var types: [Junkyard.JunkyardType] = [] {
		didSet {
			let allTypes = types.map { $0.localizedName }.joined(separator: ", ").uppercaseFirst
			self.lblJunkyardType.text = allTypes
		}
	}



    override func awakeFromNib() {
        super.awakeFromNib()

        lblJunkyardType.textColor = Theme.current.color.lightGray
        lblJunkyardDistance.textColor = Theme.current.color.lightGray
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        lblJunkyardName.text = ""
        lblJunkyardType.text = ""
        lblJunkyardDistance.text = ""
    }

}

class JunkyardTopTableViewCell: JunkyardTableViewCell {

	override var types: [Junkyard.JunkyardType] {
		didSet {
			let allTypes = types.map { $0.localizedName }.joined(separator: ", ").uppercaseFirst
			if allTypes.count > 0 {
                let mutableString = NSMutableAttributedString(string: "collectionPoint.detail.mobile.recycable".localized + ": ")
				mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: Theme.current.color.lightGray, range: NSRange(location: 0, length: mutableString.length))
				mutableString.append(NSMutableAttributedString.init(string: allTypes, attributes: convertToOptionalNSAttributedStringKeyDictionary([
					convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.black
					])))
				self.lblJunkyardType.attributedText = mutableString
			} else {
				self.lblJunkyardType.text = ""
			}
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func prepareForReuse() {
		super.prepareForReuse()
	}

}

extension JunkyardListViewController: ShowFilterData {

    /**
    Set junkyards according filtered data
    */
    func showFilterData(value: [Junkyard]) {
        if !value.isEmpty {
            junkyards = value
        }
    }

}

extension JunkyardListViewController: SendDataForJunkyardFilter {

    /**
    Set data for lazy loading when fitler was set
    */
    func sendDataForJunkyardFilter(size: String, type: [String]) {
        filterSize = size
        filterTypes = type
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}
