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

protocol OrganizationPickerDelegate: class {

    func organizationPicker(_ organizationPicker: OrganizationPickerViewController, didSelect organizations: [Organization])
}

class OrganizationPickerViewController: ViewController,
    UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var tableView: UITableView!

    var organizations: [Organization] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var selectedOrganizations: [Organization] = []

    weak var delegate: OrganizationPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44

        Networking.instance.organizations(page: 1, limit: 20) { [weak self] organizations, _ in
            if let o = organizations {
                self?.organizations.append(contentsOf: o)
            }
        }

        let doneButton = UIBarButtonItem.init(title: "global.done".localized, style: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = doneButton
        self.navigationItem.leftBarButtonItem = nil
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return organizations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrganizationCell") as! OrganizationCell

        let organization = organizations[indexPath.row]

        cell.lblName.text = organization.name

        cell.swJoined.isOn = isSelected(organization: organization)

        cell.onSwitch = { [weak self] isSelected in
            if isSelected {
                self?.selectedOrganizations.append(organization)
            } else {
                if let index = self?.selectedOrganizations.index(where: { (o) -> Bool in
                    return o.id == organization.id
                }) {
                    self?.selectedOrganizations.remove(at: index)
                }
            }
        }

        return cell
    }

    func isSelected(organization: Organization) -> Bool {
        return selectedOrganizations.contains { (o) -> Bool in
            return o.id == organization.id
        }
    }

    @objc func done() {
        _ = self.navigationController?.popViewController(animated: true)
        self.delegate?.organizationPicker(self, didSelect: selectedOrganizations)
    }
}

class OrganizationCell: UITableViewCell {

    @IBOutlet var lblName: UILabel!

    @IBOutlet var swJoined: UISwitch!


	var onSwitch: ((Bool) -> Void)?

    @IBAction func switched() {
        if let cb = onSwitch {
            cb(swJoined.isOn)
        }
    }

//	override func didMoveToSuperview() {
//		super.didMoveToSuperview()
//		self.layoutIfNeeded()
//	}
}
