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

protocol AreaPickerDelegate: class {

    func areaPicker(_ areaPicker: AreaPickerViewController, didSelect areas: [Area])
}

class AreaPickerViewController: ViewController,
    UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!

    var areas: [Area] = []
    var selectedAreas: [Area] = []

    var expandedAreas: [Area] = []

    weak var delegate: AreaPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44

        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = nil

        self.loadData()
    }

    // Load continents at first
    func loadData() {
        Networking.instance.areas(type: .continent) { [weak self] areas, error in
            if let error = error {
                self?.show(error: error)
            }
            self?.areas = areas ?? []
            self?.tableView.reloadData()
        }
    }

    // MARK: - Expand & Collapse area for subareas

    /**
     Expand area for subareas
     */
    func expand(area: Area) {
        guard let subtype = area.subtype else { return }
        Networking.instance.areas(type: subtype, parent: area) { [weak self] areas, error in
            if let error = error {
                self?.show(error: error)
                return
            }
            guard let areas = areas else { return }
            self?.expandedAreas.append(area)
            self?.appendSubareas(areas, of: area)
        }
    }

    /**
     Insert subareas of area into table
     */
    func appendSubareas(_ areas: [Area], of area: Area) {
        guard let index = self.areas.index(where: { (a) -> Bool in
            return a.id == area.id
        }) else { return }
        self.tableView.beginUpdates()
        var ips: [IndexPath] = []
        let nextIndex = self.areas.index(after: index)
        for i in nextIndex ..< (nextIndex + areas.count) {
            ips.append(IndexPath(row: i, section: 0))
        }
        self.areas.insert(contentsOf: areas, at: nextIndex)
        self.tableView.insertRows(at: ips, with: .automatic)
        self.tableView.endUpdates()
    }

    /**
     Find indexpaths for all subareas of area
     */
    func indexPaths(forSubareasOf area: Area) -> [IndexPath] {
        guard let tablePosition = self.areas.index(where: { (a) -> Bool in
            return a.id == area.id
        }) else { return [] }

        var ips: [IndexPath] = []
        for i in (tablePosition + 1) ..< self.areas.count {
            let a = self.areas[i]
            if a.type.isSubtype(of: area.type) {
                ips.append(IndexPath(row: i, section: 0))
            } else {
                break
            }
        }
        return ips
    }

    /**
     Remove areas by rows
     */
    func removeAreas(atIndexPaths ips: [IndexPath]) {
        self.tableView.beginUpdates()
        for ip in ips.reversed() {
            self.areas.remove(at: ip.row)
        }
        self.tableView.deleteRows(at: ips, with: .automatic)
        self.tableView.endUpdates()
    }

    /**
     Collapse subareas of area
     */
    func collapse(area: Area) {
        // Mark as collapsed
        guard let index = self.expandedAreas.index(where: { (a) -> Bool in
            return a.id == area.id
        }) else { return }
        self.expandedAreas.remove(at: index)

        // remove subs
        let ips = self.indexPaths(forSubareasOf: area)
        self.removeAreas(atIndexPaths: ips)
    }

    // MARK: - Table view datasource & delegate

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return areas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AreaCell", for: indexPath) as! AreaCell
        let area = areas[indexPath.row]
        cell.lblName.text = area.shortName
        cell.swJoined.isOn = isSelected(area: area)
        cell.onSwitch = { [weak self] isSelected in
			self?.switchSelected(area: area, selected: isSelected)
        }
        return cell
    }

	func switchSelected(area: Area, selected: Bool) {
		if selected {
			self.selectedAreas.append(area)
		} else {
			if let index = self.selectedAreas.index(where: { (a) -> Bool in
				return a.id == area.id
			}) {
				self.selectedAreas.remove(at: index)
			}
		}
	}

    func isSelected(area: Area) -> Bool {
        return selectedAreas.contains { (a) -> Bool in
            return a.id == area.id
        }
    }

    func isExpanded(area: Area) -> Bool {
        return self.expandedAreas.contains { (a) -> Bool in
            return a.id == area.id
        }
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let area = areas[indexPath.row]
        if isExpanded(area: area) {
            self.collapse(area: area)
        } else {
            self.expand(area: area)
        }
    }

    // MARK: - Actions

    func done() {
        _ = self.navigationController?.popViewController(animated: true)
        self.delegate?.areaPicker(self, didSelect: selectedAreas)
    }
}

class AreaCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!

    @IBOutlet var swJoined: UISwitch!

    var onSwitch: ((Bool) -> Void)?

    @IBAction func switched() {
        if let cb = onSwitch {
            cb(swJoined.isOn)
        }
    }
}
