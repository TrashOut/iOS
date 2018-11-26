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

class LoginSignupViewController: ViewController {

	@IBOutlet var segmentControl: UISegmentedControl!

	var currentVC: UIViewController?

	override func viewDidLoad() {
		super.viewDidLoad()

		loadLogin()

		segmentControl.setTitle("global.login".localized, forSegmentAt: 0)
		segmentControl.setTitle("global.register".localized, forSegmentAt: 1)

		segmentControl.layer.cornerRadius = segmentControl.bounds.height / 2
		segmentControl.layer.masksToBounds = true
		segmentControl.layer.borderColor = UIColor.white.cgColor
		segmentControl.layer.borderWidth = 1
	}

	// MARK: - Actions

	@IBAction func segmentValueChanged() {
		currentVC?.view.removeFromSuperview()
		currentVC?.removeFromParent()
		if segmentControl.selectedSegmentIndex == 0 {
			loadLogin()
		} else {
			loadSignup()
		}
	}

	// MARK: - Childs

	func loadSignup() {
		guard let vc = storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController else { fatalError("Could not dequeue storyboard with identifier: SignupViewController") }
		addController(vc)
	}

	func loadLogin() {
		guard let vc = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { fatalError("Could not dequeue storyboard with identifier: LoginViewController") }
		addController(vc)
	}

	func addController(_ vc: UIViewController) {
		addChild(vc)
		currentVC = vc

		vc.didMove(toParent: self)
		view.addSubview(vc.view)
		vc.view.translatesAutoresizingMaskIntoConstraints = false
		vc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		vc.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		vc.view.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
	}

}
