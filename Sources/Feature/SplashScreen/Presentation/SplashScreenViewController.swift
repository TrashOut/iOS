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

class SplashScreenViewController: ViewController {

	let version =  { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""}()
	let tutorialShownKey: String = "TutorialShown"

	override func viewDidLoad() {
        super.viewDidLoad()
        let key = self.tutorialShownKey
        let shown = UserDefaults.standard.bool(forKey: key)
        if shown {
            //self.openTutorial()
            UserManager.instance.createAnonymousUser { [weak self] (user, error) in
                print(user?.id as Any)
                self?.openMain()
            }
        } else {
            self.openTutorial()
            UserDefaults.standard.set(true, forKey: key)
        }
	}

	func openMain() {
		guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() else { return }
		guard let view = self.navigationController?.view else { return }
		UIView.transition(with: view, duration: 0.35, options: [.transitionCrossDissolve], animations: { 
			self.navigationController?.viewControllers = [vc]
			}, completion: nil)
	}

	func openTutorial() {
		guard let vc = UIStoryboard(name: "Tutorial", bundle: Bundle.main).instantiateInitialViewController() else { return }
		guard let view = self.navigationController?.view else { return }
		UIView.transition(with: view, duration: 0.35, options: [.transitionCrossDissolve], animations: {
			self.navigationController?.viewControllers = [vc]
		}, completion: nil)

	}

}

