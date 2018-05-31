//
//  TutorialViewController.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 29.03.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit

class TutorialViewController: ViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {

	var pageVC: UIPageViewController!
	let tutorial = Tutorial()

	override func viewDidLoad() {
		super.viewDidLoad()
        // when tutorial is shown - logout old user
        UserManager.instance.logoutOldUser()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "embed" {
			if let pvc = segue.destination as? UIPageViewController {
				self.pageVC = pvc
				pvc.dataSource = self
				pvc.delegate = self
				pvc.setViewControllers([self.page(for: 0) ?? UIViewController()], direction: .forward, animated: false, completion: nil)
			}
		}
	}

	func page(for index: Int) -> UIViewController? {
		guard index >= 0 else { return nil }
		guard index < tutorial.pages.count else { return nil }
		if index == tutorial.pages.count - 1 {
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "TutorialLastPageViewController") as? TutorialLastPageViewController
			vc?.index = index
			vc?.page = tutorial.pages.last
			return vc
		} else {
			let vc = self.storyboard?.instantiateViewController(withIdentifier: "TutorialPageViewController") as? TutorialPageViewController
			vc?.index = index
			vc?.page = tutorial.pages[index]
			return vc
		}
	}


	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		guard let current = viewController as? TutorialPageViewController else { return nil }
		let vc = page(for: current.index + 1)
		return vc
	}

	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		guard let current = viewController as? TutorialPageViewController else {
			if let c = viewController as? TutorialLastPageViewController {
				return page(for: c.index - 1)
			}
			return nil
		}
		return page(for: current.index - 1)
	}

	func skip() {
		self.pageVC.setViewControllers([self.page(for: tutorial.pages.count - 1) ?? UIViewController()], direction: .forward, animated: true, completion: nil)
	}



}
