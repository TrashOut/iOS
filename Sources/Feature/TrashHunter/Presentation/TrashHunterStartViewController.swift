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

class TrashHunterStartViewController: UIViewController {


	@IBOutlet var lblTrashHunter: UILabel!
	@IBOutlet var lblTrashHunterInfo: UILabel!
	@IBOutlet var btnStartHunting: UIButton!
	
	override func viewDidLoad() {
		 super.viewDidLoad()
		 self.view.translatesAutoresizingMaskIntoConstraints = false

		lblTrashHunter.text = "trashHunter".localized
		lblTrashHunter.textColor = Theme.current.color.green
		lblTrashHunterInfo.text = "trashHunter.text".localized
		lblTrashHunterInfo.textColor = Theme.current.color.lightGray
		btnStartHunting.setTitle("trashHunter.startHunting".localized.uppercased(with: .current), for: .normal)
		btnStartHunting.theme()

	}

	@IBAction func startHunting() {
		guard let container = self.parent as? TrashHunterContainerViewController else {return}
		let nc = self.storyboard?.instantiateViewController(withIdentifier: "TrashHunterConfigController") as! UINavigationController
		let vc = nc.children.first as! TrashHunterConfigViewController
		vc.container = container
		self.present(nc, animated: true, completion: nil)
	}
	
}
