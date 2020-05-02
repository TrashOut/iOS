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

class TabbarViewController: UITabBarController, UITabBarControllerDelegate {

	var loggedInControllers: [UIViewController]?
	var unloggedControllers: [UIViewController]?

	var signIn: Bool = false

	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.delegate = self
        
        for vc in viewControllers ?? [] {
            vc.tabBarItem.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 11, weight: .medium)], for: .normal)
        }

		var lvcs = super.viewControllers
		lvcs?.remove(at: 5)
		loggedInControllers = lvcs
		var uvcs = super.viewControllers
		uvcs?.remove(at: 4)
		unloggedControllers = uvcs

		if UserManager.instance.isLoggedIn == true {
			showLoggedTabbar()
		} else {
			showUnloggedTabbar()
		}

		self.viewControllers?[0].title = "tab.home".localized
		self.viewControllers?[1].title = "tab.dumps".localized
		self.viewControllers?[2].title = "tab.news".localized
		self.viewControllers?[3].title = "tab.recycling".localized
        
        openDashboard()
	}
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if UserManager.instance.user == nil {
            UserManager.instance.createAnonymousUser {[weak self] (user, error) in
                self?.selectedViewController = viewController
            }
            return false
        } else {
            return true
        }
    }

	func showLoggedTabbar () {
		super.viewControllers = loggedInControllers
		self.viewControllers?[4].title = "tab.profile".localized
	}

	func showUnloggedTabbar () {
		super.viewControllers = unloggedControllers
		self.viewControllers?[4].title = "global.login".localized
	}

    func openDashboard(refresh:Bool = false, completion: ((UINavigationController) -> Void)? = nil) {
        guard let nc = self.viewControllers?[0] as? UINavigationController else { return }
        nc.popToRootViewController(animated: false)
        self.selectedIndex = 0
        
        guard let db = nc.viewControllers[0] as? DashboardViewController else { return }
        db.dataDidLoadHandler = { [weak self] in
            self?.coordinateAfterReceiveNotification()
        }
        
        if refresh == true {
            db.loadData(reload: true)
        }
        
        completion?(nc)
    }
    

	func openDumps() {
		guard let nc = self.viewControllers?[1] as? UINavigationController else { return }
		nc.popToRootViewController(animated: false)
		self.selectedIndex = 1
	}

	func openArticles() {
		guard let nc = self.viewControllers?[2] as? UINavigationController else { return }
		nc.popToRootViewController(animated: false)
		self.selectedIndex = 2
	}

	func openJunkyards() {
		guard let nc = self.viewControllers?[3] as? UINavigationController else { return }
		nc.popToRootViewController(animated: false)
		self.selectedIndex = 3

	}

	func openProfile(_ completion: @escaping (UIViewController)->()) {
		guard let nc = self.viewControllers?[4] as? UINavigationController else { return }
		nc.popToRootViewController(animated: false)
		self.selectedIndex = 4
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { // wait some time to load view
			guard let vc = self.viewControllers?[4] as? UINavigationController else { return }
			guard let root = vc.viewControllers.first else { return }
			completion(root)
		}
	}
}

extension TabbarViewController {
    func coordinateAfterReceiveNotification() {
        
        // Show detail if needed
        if case let .pushNotification(data)? = NotificationsManager.AppOpen.shared.mode {
            NotificationsManager.handleNotificationData(data) { [weak self] notificationData in
                if case .report = notificationData.type {
                    switch notificationData.reportType! {
                    case .event:
                        NotificationsManager.showEventAfterReceiveNotification(tabBarController: self, id: notificationData.id)
                        break
                    case .news:
                        NotificationsManager.showNewsAfterReceiveNotification(tabBarController: self, id: notificationData.id)
                        break
                    case .trash:
                        NotificationsManager.showDumpsAfterReceiveNotification(tabBarController: self, id: notificationData.id)
                        break
                    }
                }
            }
        }
        
        // Remove state for app open mode
        NotificationsManager.AppOpen.shared.mode = nil
    }
}
