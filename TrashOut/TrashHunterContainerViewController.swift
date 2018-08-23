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

class TrashHunterContainerViewController: UIViewController {

	@IBOutlet var container: UIView!
	weak var controller: UIViewController?


	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.translatesAutoresizingMaskIntoConstraints = false
		self.switchControllers()
	}

	func errorHandler(_ error: TrashHunterError) {
		print(error.localizedDescription)
		print(error.message)

		let alert = UIAlertController(title: "TrashHunter", message: error.message, preferredStyle: .alert)

//		let cancel = UIAlertAction(title: "global.cancel".localized, style: .cancel) { (_) in
//		}
		for action in error.actions {
			alert.addAction(action)
		}
		if let retryBlock = error.repeatBlock {
			let retry = UIAlertAction(title: "Retry".localized, style: .default) { (_) in
				retryBlock()
			}
			alert.addAction(retry)
		}
		let ok = UIAlertAction(title: "global.ok".localized, style: .default) { (_) in
		}
		alert.addAction(ok)


		DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
			UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
		}
	}

//	override func viewWillAppear(_ animated: Bool) {
//		super.viewWillAppear(animated)
//
//	}

	func refresh() {
		if let c = self.controller as? TrashHuntingViewController {
			c.refresh()
		}
	}

	func switchControllers() {
		if let hunter = TrashHunter.hunter {
			hunter.container = self
			if controller is TrashHuntingViewController {
				return
			} else {
				let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrashHuntingViewController") as! TrashHuntingViewController
				self.present(vc: vc)
			}

		} else {
			if controller is TrashHunterStartViewController {
				return
			} else {
				let vc = self.storyboard?.instantiateViewController(withIdentifier: "TrashHunterStartViewController") as! TrashHunterStartViewController
				self.present(vc: vc)
			}
		}
	}

	func present(vc: UIViewController) {
		guard let oldController = self.controller else { return }
		oldController.willMove(toParentViewController: nil)
		self.addChildViewController(vc)

		self.container.addSubview(vc.view)
		vc.view.leadingAnchor.constraint(equalTo: self.container.leadingAnchor).isActive = true
		vc.view.trailingAnchor.constraint(equalTo: self.container.trailingAnchor).isActive = true
		vc.view.topAnchor.constraint(equalTo: self.container.topAnchor).isActive = true
		vc.view.bottomAnchor.constraint(equalTo: self.container.bottomAnchor).isActive = true

		vc.didMove(toParentViewController: self)
		oldController.view.removeFromSuperview()
		oldController.removeFromParentViewController()


		self.view.setNeedsLayout()
		self.view.layoutIfNeeded()
		self.controller = vc
	}


	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "Start" {
			self.controller = segue.destination
		}
	}


}
