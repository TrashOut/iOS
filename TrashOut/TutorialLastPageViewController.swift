//
//  TutorialLastPageViewController.swift
//  TrashOut
//
//  Created by Tomáš Zrůst on 29.03.17.
//  Copyright © 2017 TrashOut NGO. All rights reserved.
//

import Foundation
import UIKit

class TutorialLastPageViewController: ViewController {

	@IBOutlet var ivImage: UIImageView!
	@IBOutlet var lblTitle: UILabel!
	@IBOutlet var lblText: UILabel!

	@IBOutlet var btnSignin: UIButton!
	@IBOutlet var btnFacebook: UIButton!
	@IBOutlet var lblProcess: UILabel!

	var page: TutorialPage?
	var index: Int = 0


	override func viewDidLoad() {
		super.viewDidLoad()
		ivImage.image = page?.image
		lblTitle.text = page?.title
		lblText.text = page?.content

		btnSignin.setTitle("tutorial.register".localized, for: .normal)
		btnFacebook.setTitle("global.facebookLogin".localized, for: .normal)
		lblProcess.attributedText = NSAttributedString.init(string: "tutorial.signup.withoutSignIn".localized, attributes: [
			NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue
		])

		btnSignin.layer.cornerRadius = 35 / 2
		btnSignin.layer.masksToBounds = true
		btnSignin.backgroundColor = UIColor.theme.button
		btnSignin.setTitleColor(UIColor.white, for: UIControlState())

		btnFacebook.layer.cornerRadius = 35 / 2
		btnFacebook.layer.masksToBounds = true
		btnFacebook.backgroundColor = UIColor.theme.facebook
		btnFacebook.setTitleColor(UIColor.white, for: UIControlState())
	}

	@IBAction func signIn() {
		self.askPermissions { [weak self] _ in
			guard let main = self?.loadSignIn() else { return }
			self?.changeRoot(viewController: main)
		}
	}

	@IBAction func process() {
		self.askPermissions { _ in
            UserManager.instance.createAnonymousUser { [weak self] (user, error) in
                guard let main = self?.main() else { return }
                self?.changeRoot(viewController: main)
                
                // Register notifications.
                NotificationsManager.registerNotifications()
            }
		}
	}

	@IBAction func facebookSignIn() {
		UserManager.instance.loginWithFacebook(self) { [weak self] (error) in
			guard error == nil else {
				print(error?.localizedDescription as Any)
				self?.show(error: error!)
				return
			}
			guard let user = UserManager.instance.user else { return }
			print("Successful logged as \(user.email ?? "no email")")

			self?.askPermissions { [weak self] _ in
				guard let main = self?.main() else { return }
				self?.changeRoot(viewController: main)
			}
            
            // Register notifications.
            NotificationsManager.registerNotifications()
		}
	}


	var trashHunter: TrashHunter? {
		didSet {
			TrashHunter.hunter = trashHunter
		}
	}
	func askPermissions(completion: @escaping ()->()) {
		Async.waterfall([
		                  { [weak self] (completion: @escaping ()->(), _) in

				let config = TrashHunterConfig()
				self?.trashHunter = TrashHunter.init(config)
				self?.trashHunter?.prepareNotifications(success: {
					self?.trashHunter = nil
					completion()
				}, failure: completion)
			}, { (completion: @escaping ()->(), _) in
				LocationManager.manager.refreshCurrentLocation({ (_) in // TODO: wait for it
					completion()
				})
			}, { (c, _) in
				completion()
				c()
			}
			], failure: { (_) in
			completion()
		})
	}


	func loadSignIn() -> UIViewController? {
		guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as? TabbarViewController else { return nil }
		vc.signIn = true
		return vc
	}

	func main() -> UIViewController? {
		guard let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() else { return nil }
		return vc
	}

	func changeRoot(viewController: UIViewController) {
		guard let window = UIApplication.shared.keyWindow else { return }
		guard let snapshot = window.snapshotView(afterScreenUpdates: true) else { return }
		viewController.view.addSubview(snapshot)
		window.rootViewController = viewController
		UIView.animate(withDuration: 0.35, animations: {
			snapshot.layer.opacity = 0
			snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
		}) { (_) in
			snapshot.removeFromSuperview()
		}
	}

}
