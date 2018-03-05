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


protocol CountryPickerDelegate: class {

	func countryPicker(_ countryPicker: CountryPickerViewController, didSelect country: Area?)
}

class CountryPickerViewController: ViewController,
	UITableViewDelegate, UITableViewDataSource {

	@IBOutlet var tableView: UITableView!

	weak var delegate: CountryPickerDelegate?

	var countries: [Area] = [] {
		didSet {
			tableView.reloadData()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "statistics.countryPicker.header".localized

		self.loadData()
	}

	func loadData() {
		LoadingView.show(on: self.view, style: .white)
		Networking.instance.areas(type: .country) { [weak self] (countries, error) in
			LoadingView.hide()
			if let error = error {
				self?.show(error: error)
				return
			}
			self?.countries = countries ?? []
		}
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return countries.count + 1
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell") as! CountryTableViewCell
		if indexPath.row == 0 {
			cell.lblName.text = "global.worldwide".localized
		} else {
			let country = countries[indexPath.row - 1]
			cell.lblName.text = country.country
		}
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.row == 0 {
			self.delegate?.countryPicker(self, didSelect: nil)
		} else {
			let country = countries[indexPath.row - 1]
			self.delegate?.countryPicker(self, didSelect: country)
		}
		_ = self.navigationController?.popViewController(animated: true)
	}

}

class CountryTableViewCell: UITableViewCell {

	@IBOutlet var lblName: UILabel!


}
