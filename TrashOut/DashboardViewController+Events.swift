//
//  DashboardViewController+Events.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 24.03.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

extension DashboardViewController {

	/**
	Load nearest event
	*/
	func loadEvents(completion: @escaping () -> (), failure: @escaping (Error) -> ()) {
		let locationPoint = LocationManager.manager.currentLocation.coordinate
		Networking.instance.events(position: locationPoint, limit: 3, page: 1) { [weak self] (events, error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
				NoDataView.show(over: self?.vEvents, text: "global.fetchError".localized)
				completion()
				return
			}
			NoDataView.hide(from: self?.vEvents)
			guard let events = events else {
				completion()
				return
			}
			self?.events = events.filter { (event) -> Bool in
				guard let gps = event.gps else { return false }
				let loc = CLLocation.init(latitude: gps.lat, longitude: gps.long)
				let dist = LocationManager.manager.currentLocation.distance(from: loc)
				return dist < 50000
			}.filter { (event) -> Bool in
				guard let start = event.start else { return false }
				let now = try! Date().atTime(hour: 0, minute: 0, second: 0)
				return start >= now
			}.sorted { (e1, e2) -> Bool in
				guard let start2 = e2.start else { return true }
				guard let start1 = e1.start else { return false }
				return start1 < start2
			}

			completion()
		}
	}



	func eventsTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tableView === tblEvents {
			return self.events.count
		}
		return 0
	}

	func eventsTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell: DashboardEventCell = tableView.dequeueReusableCell(withIdentifier: "DashboardEventCell") as? DashboardEventCell else { return UITableViewCell() }

		let event = events[indexPath.row]
		cell.lblHelpUsToCleanIt.text = event.name

		let df = DateFormatter()
		df.timeStyle = .none
		df.dateStyle = .long
		if let start = event.start {
			cell.lblEventsTime.text = df.string(from: start)
		} else {
			cell.lblEventsTime.text = ""
		}
        
        // Join button
        eventManager.joinButtonTest(event) { (show) in
            DispatchQueue.main.async {
                if show {
                    // Save the date
                    cell.btnJoinEvent.isHidden = false
                    cell.btnJoinEvent.setTitle("event.join".localized.uppercased(with: .current), for: .normal)
                    cell.btnJoinEvent.theme()
                } else {
                    cell.btnJoinEvent.isHidden = true
                }
            }
        }
        cell.joinAction = { [unowned self] _ in
            self.joinEvent(event)
        }
        
		return cell
	}

	func eventsTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let event = events[indexPath.row]
		self.openEvent(event)
	}

	func openEvent(_ event: Event) {
		let st = UIStoryboard(name: "Event", bundle: Bundle.main)
		guard let vc = st.instantiateViewController(withIdentifier: "EventDetailViewController") as? EventDetailViewController else {return}
		vc.showJoinButton = event.showJoinButton
        vc.id = event.id
		self.navigationController?.pushViewController(vc, animated: true)
	}

    func joinEvent(_ event: Event) {
        eventManager.joinEvent(event, controller: self) { [weak self, weak event] (error) in
            DispatchQueue.main.async {
                if let error = error as? NSError {
                    if error.code == 300 {
                        self?.showWithSettings(message: error.localizedDescription)
                    } else {
                        self?.show(message: error.localizedDescription)
                    }
                    event?.showJoinButton = true
                } else {
                    event?.showJoinButton = false
                }
            }
		}
	}

}


class DashboardEventCell: UITableViewCell {

	@IBOutlet var lblHelpUsToCleanIt: UILabel!
	@IBOutlet var lblEventsTime: UILabel!
	@IBOutlet var btnJoinEvent: UIButton!

	var joinAction: (() -> ())?

	override func awakeFromNib() {
		super.awakeFromNib()
		lblEventsTime.textColor = Theme.current.color.lightGray
	}

	override func prepareForReuse() {
		super.prepareForReuse()
		lblHelpUsToCleanIt.text = ""
		lblEventsTime.text = ""
	}

	@IBAction func join() {
		joinAction?()
	}
}


